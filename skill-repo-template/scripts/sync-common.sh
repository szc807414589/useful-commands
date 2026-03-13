#!/bin/bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SKILLS_ROOT="${REPO_ROOT}/skills"
readonly PLUGINS_ROOT="${REPO_ROOT}/plugins"
readonly TEAM_ROOT="${REPO_ROOT}/team"
readonly GOVERNANCE_ROOT="${REPO_ROOT}/governance"
readonly REGISTRY_FILE="${GOVERNANCE_ROOT}/skills-registry.csv"
SYNC_PLUGINS=()
SYNC_DIRECT_SKILLS=()
SYNC_STATUSES=()

usage_sync_common() {
  cat <<'EOF'
用法：
  sync-*.sh [--plugin NAME]... [--skill NAME]... [--status STATUS]... [--target PATH] [--dry-run] [--clean]

参数：
  --plugin NAME   只同步某个 plugin 中列出的 skill，可重复传入
  --skill NAME    只同步指定 skill，可重复传入
  --status STATUS 只同步指定状态的 skill，可重复传入
  --target PATH   覆盖默认目标目录
  --dry-run       仅预览，不实际写入
  --clean         删除目标目录中不在本次同步集合中的旧 skill
  --help          显示帮助

说明：
  1. 如果不传 --plugin 和 --skill，默认同步 skills/ 下全部 skill。
  2. plugin 通过 plugins/<name>/ 下的软链解析。
  3. status 来自 governance/skills-registry.csv，可用值：team-shared / personal-only / experimental
  4. 默认是增量同步，不删除目标中其他目录；只有显式传 --clean 才会清理。
EOF
}

normalize_list_file() {
  local file="$1"
  sed 's/#.*$//' "$file" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | sed '/^$/d'
}

all_skills() {
  find "${SKILLS_ROOT}" -mindepth 1 -maxdepth 1 -type d -print | xargs -I{} basename "{}" | sort
}

skills_from_group_dir() {
  local dir="$1"
  [ -d "${dir}" ] || return 0
  find "${dir}" -mindepth 1 -maxdepth 1 \( -type l -o -type d \) -print | xargs -I{} basename "{}" | sort -u
}

skills_from_plugins() {
  local plugin
  for plugin in "$@"; do
    local plugin_dir="${PLUGINS_ROOT}/${plugin}"
    if [ ! -d "${plugin_dir}" ]; then
      echo "未找到 plugin 目录: ${plugin_dir}" >&2
      return 1
    fi
    skills_from_group_dir "${plugin_dir}"
  done | sort -u
}

ensure_skill_exists() {
  local skill="$1"
  local skill_dir="${SKILLS_ROOT}/${skill}"
  if [ ! -d "${skill_dir}" ]; then
    echo "skill 目录不存在: ${skill_dir}" >&2
    return 1
  fi
  if [ ! -f "${skill_dir}/SKILL.md" ]; then
    echo "缺少 SKILL.md: ${skill_dir}/SKILL.md" >&2
    return 1
  fi
}

ensure_registry_exists() {
  if [ ! -f "${REGISTRY_FILE}" ]; then
    echo "缺少状态清单: ${REGISTRY_FILE}" >&2
    return 1
  fi
}

filter_selection_by_status() {
  ensure_registry_exists
  local registry="${REGISTRY_FILE}"
  local selected_input
  selected_input="$(cat)"
  SELECTED_SKILLS_INPUT="${selected_input}" python3 - "$registry" "$@" <<'PY'
import csv
import pathlib
import os
import sys

registry_path = pathlib.Path(sys.argv[1])
allowed_statuses = set(sys.argv[2:])
selected = [line.strip() for line in os.environ.get("SELECTED_SKILLS_INPUT", "").splitlines() if line.strip()]

with registry_path.open(newline="") as fh:
    rows = {row["skill"]: row["status"] for row in csv.DictReader(fh)}

missing = [skill for skill in selected if skill not in rows]
for skill in missing:
    print(f"状态清单缺少 skill: {skill}", file=sys.stderr)

for skill in selected:
    status = rows.get(skill)
    if status in allowed_statuses:
        print(skill)
PY
}

resolve_selection() {
  local -a selection=()
  if [ "${#SYNC_PLUGINS[@]}" -eq 0 ] && [ "${#SYNC_DIRECT_SKILLS[@]}" -eq 0 ]; then
    while IFS= read -r line; do
      [ -n "${line}" ] || continue
      selection+=("${line}")
    done < <(all_skills)
  else
    while IFS= read -r line; do
      [ -n "${line}" ] || continue
      selection+=("${line}")
    done < <(
      {
        if [ "${#SYNC_PLUGINS[@]}" -gt 0 ]; then
          skills_from_plugins "${SYNC_PLUGINS[@]}"
        fi
        if [ "${#SYNC_DIRECT_SKILLS[@]}" -gt 0 ]; then
          printf '%s\n' "${SYNC_DIRECT_SKILLS[@]}"
        fi
      } | sort -u
    )
  fi

  if [ "${#SYNC_STATUSES[@]}" -gt 0 ]; then
    local -a filtered=()
    while IFS= read -r line; do
      [ -n "${line}" ] || continue
      filtered+=("${line}")
    done < <(printf '%s\n' "${selection[@]}" | filter_selection_by_status "${SYNC_STATUSES[@]}")
    if [ "${#filtered[@]}" -gt 0 ]; then
      selection=("${filtered[@]}")
    else
      selection=()
    fi
  fi

  if [ "${#selection[@]}" -eq 0 ]; then
    echo "没有可处理的 skill。" >&2
    return 1
  fi

  local skill
  for skill in "${selection[@]}"; do
    ensure_skill_exists "${skill}"
  done

  printf '%s\n' "${selection[@]}"
}

sync_selected_skills() {
  local target="$1"
  local dry_run="$2"
  local clean="$3"
  shift 3
  local skills=("$@")

  mkdir -p "${target}"

  local rsync_flags=(-a)
  if [ "${dry_run}" = "true" ]; then
    rsync_flags+=(-n -v)
  fi

  local skill
  for skill in "${skills[@]}"; do
    ensure_skill_exists "${skill}"
    echo "同步 ${skill} -> ${target}/${skill}"
    mkdir -p "${target}/${skill}"
    rsync "${rsync_flags[@]}" "${SKILLS_ROOT}/${skill}/" "${target}/${skill}/"
  done

  if [ "${clean}" = "true" ]; then
    echo "清理目标目录中未选中的 skill..."
    local existing
    while IFS= read -r existing; do
      [ -n "${existing}" ] || continue
      if ! printf '%s\n' "${skills[@]}" | grep -Fxq "${existing}"; then
        echo "删除 ${target}/${existing}"
        if [ "${dry_run}" != "true" ]; then
          rm -rf "${target:?}/${existing}"
        fi
      fi
    done < <(find "${target}" -mindepth 1 -maxdepth 1 -type d -print | xargs -I{} basename "{}" | sort)
  fi
}

run_sync() {
  local default_target="$1"
  shift

  local target="${default_target}"
  local dry_run="false"
  local clean="false"
  local -a plugins=()
  local -a direct_skills=()
  local -a statuses=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --plugin)
        plugins+=("$2")
        shift 2
        ;;
      --skill)
        direct_skills+=("$2")
        shift 2
        ;;
      --status)
        statuses+=("$2")
        shift 2
        ;;
      --target)
        target="$2"
        shift 2
        ;;
      --dry-run)
        dry_run="true"
        shift
        ;;
      --clean)
        clean="true"
        shift
        ;;
      --help)
        usage_sync_common
        return 0
        ;;
      *)
        echo "未知参数: $1" >&2
        usage_sync_common >&2
        return 1
        ;;
    esac
  done

  SYNC_PLUGINS=()
  SYNC_DIRECT_SKILLS=()
  SYNC_STATUSES=()
  if [ "${#plugins[@]}" -gt 0 ]; then
    SYNC_PLUGINS=("${plugins[@]}")
  fi
  if [ "${#direct_skills[@]}" -gt 0 ]; then
    SYNC_DIRECT_SKILLS=("${direct_skills[@]}")
  fi
  if [ "${#statuses[@]}" -gt 0 ]; then
    SYNC_STATUSES=("${statuses[@]}")
  fi
  local selection_output
  selection_output="$(resolve_selection)"
  local -a selection=()
  while IFS= read -r line; do
    [ -n "${line}" ] || continue
    selection+=("${line}")
  done <<< "${selection_output}"

  echo "仓库根目录: ${REPO_ROOT}"
  echo "目标目录: ${target}"
  echo "选择的 skill:"
  printf '  - %s\n' "${selection[@]}"

  sync_selected_skills "${target}" "${dry_run}" "${clean}" "${selection[@]}"
}
