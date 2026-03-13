#!/bin/bash

# Claude Skills 项目初始化脚本
# 用途：在新项目中设置项目配置和 .ai-configs 目录结构
# 注意：skill 系统不需要软链接，所有命令通过 /skill-name 直接调用

set -e  # 遇到错误立即退出

PROJECT_DIR=${1:-.}
cd "$PROJECT_DIR"

echo "初始化 Claude 项目配置..."
echo "项目目录: $(pwd)"
echo ""

# 1. 创建 .claude 目录（如果不存在）
echo "创建 .claude 目录..."
mkdir -p .claude

# 2. 检测项目技术栈
echo "检测项目技术栈..."
REACT_VERSION="unknown"
ANTD_VERSION="unknown"
ROUTER_TYPE="unknown"
STATE_MANAGEMENT="unknown"

if [ -f "package.json" ]; then
  if command -v jq > /dev/null 2>&1; then
    REACT_VERSION=$(jq -r '.dependencies.react // .devDependencies.react // "unknown"' package.json 2>/dev/null)
    ANTD_VERSION=$(jq -r '.dependencies.antd // .devDependencies.antd // "unknown"' package.json 2>/dev/null)

    # 检测路由类型
    if jq -e '.dependencies["react-router"] // .dependencies["react-router-dom"]' package.json > /dev/null 2>&1; then
      ROUTER_TYPE="React Router"
    elif jq -e '.dependencies["@tanstack/react-router"]' package.json > /dev/null 2>&1; then
      ROUTER_TYPE="TanStack Router"
    fi

    # 检测状态管理
    if jq -e '.dependencies.redux // .dependencies["react-redux"]' package.json > /dev/null 2>&1; then
      STATE_MANAGEMENT="Redux"
    elif jq -e '.dependencies.zustand' package.json > /dev/null 2>&1; then
      STATE_MANAGEMENT="Zustand"
    fi
  else
    echo "   未安装 jq，无法自动检测版本信息"
    echo "   提示：brew install jq (macOS) 或 apt-get install jq (Linux)"
  fi

  echo "   React: $REACT_VERSION"
  echo "   Ant Design: $ANTD_VERSION"
  echo "   Router: $ROUTER_TYPE"
  echo "   State: $STATE_MANAGEMENT"
else
  echo "   未找到 package.json"
fi
echo ""

# 3. 创建项目上下文模板
if [ -f ".claude/project-context.md" ]; then
  echo "project-context.md 已存在，跳过创建"
else
  echo "创建 project-context.md 模板..."
  cat > .claude/project-context.md <<'CONTEXT_EOF'
# 项目上下文配置

## 项目信息
- **项目名称**：[填写项目名称]
- **项目类型**：[React/Vue/Angular/其他]
- **业务领域**：[简要描述项目的业务领域]

## 技术栈

### 主要框架
- **前端框架**：React [版本]
- **UI 库**：Ant Design [版本]
- **路由管理**：React Router / TanStack Router [版本]
- **状态管理**：Redux / Zustand / Context API [版本]
- **构建工具**：Webpack / Vite / Rsbuild

### 其他依赖
- **数据可视化**：ECharts / D3.js / 其他
- **HTTP 请求**：axios / fetch / 自定义封装
- **日期处理**：Day.js / Moment.js / date-fns
- **样式方案**：Less / Sass / CSS-in-JS / Tailwind CSS

## 目录结构

```
src/
├── components/     # 公共组件
├── pages/          # 页面组件
├── utils/          # 工具函数
├── services/       # API 服务
├── store/          # 状态管理
├── hooks/          # 自定义 Hooks
├── constants/      # 常量定义
└── styles/         # 全局样式
```

## 开发规范

### 命名规范
- **组件**：PascalCase（如：`UserProfile.jsx`）
- **文件**：kebab-case 或 PascalCase
- **变量/函数**：camelCase
- **常量**：UPPER_SNAKE_CASE

### 代码规范
- 使用 ESLint / Biome 进行代码检查
- 使用 Prettier / Biome 进行代码格式化
- TypeScript / JavaScript
- 函数式组件 + Hooks

### 样式规范
- CSS Modules / Less / Sass
- BEM 命名规范 / 或其他
- 避免全局样式污染

## API 规范

### 接口约定
- **Base URL**：[API 基础地址]
- **认证方式**：Token / Cookie / 其他
- **错误处理**：统一错误码和错误提示

### 数据格式
```javascript
// 成功响应
{
  code: 0,
  data: {},
  message: "success"
}

// 错误响应
{
  code: 1001,
  data: null,
  message: "错误信息"
}
```

## 特殊约定

### 浏览器兼容性
- 支持的浏览器：Chrome、Firefox、Safari、Edge
- 最低版本要求：[具体版本]

### 性能要求
- 首屏加载时间：< 3s
- 路由切换时间：< 500ms
- 列表渲染：支持虚拟滚动（超过 100 条数据）

### 其他约定
- [填写项目特有的约定和规范]

---

## 填写说明

1. 请根据实际项目情况填写以上信息
2. 删除不相关的内容
3. 添加项目特有的规范和约定
4. 这个文件会被各 skill 命令读取（/prd、/create-plan、/review 等）
5. 建议提交到 git，团队共享
CONTEXT_EOF
  echo "   已创建模板，请根据项目实际情况编辑"
fi
echo ""

# 4. 创建 .ai-configs 目录结构
echo "创建 .ai-configs 目录结构..."

CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)

mkdir -p .ai-configs/analysis/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/brainstorm/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/design/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/prd/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/plan/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/progress/$CURRENT_YEAR/$CURRENT_MONTH

echo "   .ai-configs/analysis/    (需求分析报告)"
echo "   .ai-configs/brainstorm/  (脑暴记录)"
echo "   .ai-configs/design/      (设计方案)"
echo "   .ai-configs/prd/         (PRD 文档)"
echo "   .ai-configs/plan/        (编码计划)"
echo "   .ai-configs/progress/    (执行进度)"
echo ""

# 5. 完成提示
echo "初始化完成！"
echo ""
echo "后续步骤："
echo "   1. 编辑 .claude/project-context.md 填写项目信息"
echo "   2. 使用 skill 命令（无需任何额外配置）："
echo "      /brainstorm [主题]        - 脑暴与方向探索"
echo "      /req-analyze [需求描述]   - 需求分析（推荐第一步）"
echo "      /prd [功能描述]           - 生成产品需求文档"
echo "      /design [功能描述]        - 生成设计方案"
echo "      /create-plan [功能描述]   - 生成编码计划"
echo "      /code-by-plan             - 按计划编码"
echo "      /update-prd               - 更新 PRD 文档"
echo "      /update-plan              - 更新编码计划"
echo "      /bug-fix [Bug 描述]       - Bug 修复"
echo "      /review                   - 代码审查"
echo ""
echo "目录结构："
echo "   .claude/"
echo "   └── project-context.md     # 项目配置（请编辑）"
echo ""
echo "   .ai-configs/"
echo "   ├── analysis/              # 需求分析报告（按年/月组织）"
echo "   ├── brainstorm/            # 脑暴记录"
echo "   ├── design/                # 设计方案"
echo "   ├── prd/                   # PRD 文档"
echo "   ├── plan/                  # 编码计划"
echo "   └── progress/              # 执行进度"
echo ""
echo "提示："
echo "   - project-context.md 建议提交到 git，团队共享"
echo "   - skill 系统全局可用，无需创建软链接"
echo ""
