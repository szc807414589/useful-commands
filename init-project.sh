#!/bin/bash

# Claude Commands 项目初始化脚本
# 用途：在新项目中设置 Claude 命令和项目配置

set -e  # 遇到错误立即退出

PROJECT_DIR=${1:-.}
cd "$PROJECT_DIR"

echo "🎯 初始化 Claude 命令..."
echo "📁 项目目录: $(pwd)"
echo ""

# 1. 创建 .claude 目录（如果不存在）
echo "📂 创建 .claude 目录..."
mkdir -p .claude/commands

# 2. 创建软链接到全局命令
echo "🔗 创建命令软链接..."

# 需求分析和文档生成命令
ln -sf ~/.claude-commands/brainstorm.md .claude/commands/brainstorm.md
ln -sf ~/.claude-commands/req-analyze.md .claude/commands/req-analyze.md
ln -sf ~/.claude-commands/prd.md .claude/commands/prd.md
ln -sf ~/.claude-commands/update-prd.md .claude/commands/update-prd.md
ln -sf ~/.claude-commands/design.md .claude/commands/design.md

# 编码计划相关命令
ln -sf ~/.claude-commands/create-plan.md .claude/commands/create-plan.md
ln -sf ~/.claude-commands/update-plan.md .claude/commands/update-plan.md
ln -sf ~/.claude-commands/code-by-plan.md .claude/commands/code-by-plan.md

# 代码审查和 Bug 修复
ln -sf ~/.claude-commands/review.md .claude/commands/review.md
ln -sf ~/.claude-commands/bug-fix.md .claude/commands/bug-fix.md

echo "   ✅ brainstorm.md      (脑暴与方向探索)"
echo "   ✅ req-analyze.md     (需求分析)"
echo "   ✅ prd.md             (生成 PRD)"
echo "   ✅ update-prd.md      (更新 PRD)"
echo "   ✅ design.md          (生成设计方案)"
echo "   ✅ create-plan.md     (生成编码计划)"
echo "   ✅ update-plan.md     (更新编码计划)"
echo "   ✅ code-by-plan.md    (按计划编码)"
echo "   ✅ review.md          (代码审查)"
echo "   ✅ bug-fix.md         (Bug 修复)"
echo ""

# 3. 检测项目技术栈
echo "🔍 检测项目技术栈..."
REACT_VERSION="unknown"
ANTD_VERSION="unknown"
ROUTER_TYPE="unknown"
STATE_MANAGEMENT="unknown"

if [ -f "package.json" ]; then
  # 检测 React 版本
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
    echo "   ⚠️  未安装 jq，无法自动检测版本信息"
    echo "   💡 提示：brew install jq (macOS) 或 apt-get install jq (Linux)"
  fi
  
  echo "   React: $REACT_VERSION"
  echo "   Ant Design: $ANTD_VERSION"
  echo "   Router: $ROUTER_TYPE"
  echo "   State: $STATE_MANAGEMENT"
else
  echo "   ⚠️  未找到 package.json"
fi
echo ""

# 4. 创建项目上下文模板
if [ -f ".claude/project-context.md" ]; then
  echo "📝 project-context.md 已存在，跳过创建"
else
  echo "📝 创建 project-context.md 模板..."
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

## 设计规范

### 视觉语言
- **品牌调性**：[专业 / 稳重 / 轻量 / 数据感 / 其他]
- **主题风格**：[浅色 / 深色 / 混合]
- **主色 / 辅助色 / 危险色**：[填写色值或设计 token]
- **字体体系**：[主字体、数字字体、标题字体]
- **圆角 / 阴影 / 边框风格**：[简述]

### 交互约束
- **主要交互模式**：[表格页 / 表单页 / Dashboard / 向导式流程 / 其他]
- **常用容器**：[Page / Drawer / Modal / Tabs / Collapse]
- **反馈方式**：[Message / Notification / Inline Error / Toast]
- **高风险操作约束**：[二次确认、权限校验、危险色规则]

### 组件与设计系统
- **设计系统来源**：[Ant Design / 自研组件库 / 混合]
- **优先复用组件**：[列出公共组件、业务组件]
- **禁止模式**：[例如：避免新增平行组件、避免重复表单模式]
- **设计稿来源**：[Figma / 蓝湖 / 无]

### 可用性与无障碍
- **响应式断点**：[桌面端 / 平板 / 移动端范围]
- **最小可点击区域**：[例如 32px / 40px]
- **键盘可达性要求**：[有 / 无，补充说明]
- **对比度 / 可读性要求**：[补充说明]
- **空状态 / 错误态规范**：[补充说明]

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

## 📝 填写说明

1. 请根据实际项目情况填写以上信息
2. 删除不相关的内容
3. 添加项目特有的规范和约定
4. 这个文件会被 `/brainstorm`、`/req-analyze`、`/prd`、`/design`、`/create-plan`、`/review` 命令读取
5. 建议提交到 git，团队共享
CONTEXT_EOF
  echo "   ✅ 已创建模板，请根据项目实际情况编辑"
fi
echo ""

# 5. 创建 .ai-configs 目录结构
echo "📂 创建 .ai-configs 目录结构..."

# 获取当前年月
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)

mkdir -p .ai-configs/analysis/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/brainstorm/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/design/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/prd
mkdir -p .ai-configs/plan
mkdir -p .ai-configs/progress/$CURRENT_YEAR/$CURRENT_MONTH
mkdir -p .ai-configs/examples

echo "   ✅ .ai-configs/analysis/$CURRENT_YEAR/$CURRENT_MONTH/ (需求分析报告)"
echo "   ✅ .ai-configs/brainstorm/$CURRENT_YEAR/$CURRENT_MONTH/ (脑暴记录)"
echo "   ✅ .ai-configs/design/$CURRENT_YEAR/$CURRENT_MONTH/ (设计方案)"
echo "   ✅ .ai-configs/prd/                  (PRD 文档存储)"
echo "   ✅ .ai-configs/plan/                 (编码计划存储)"
echo "   ✅ .ai-configs/progress/$CURRENT_YEAR/$CURRENT_MONTH/ (执行进度)"
echo "   ✅ .ai-configs/examples/              (示例文档)"
echo ""

# 6. 更新 .gitignore
echo "📝 更新 .gitignore..."
if [ ! -f ".gitignore" ]; then
  touch .gitignore
fi

# 添加软链接到 .gitignore（软链接不提交，但配置文件要提交）
if ! grep -q "^.claude/commands$" .gitignore 2>/dev/null; then
  echo ".claude/commands" >> .gitignore
  echo "   ✅ 已添加 .claude/commands 到 .gitignore"
else
  echo "   ℹ️  .claude/commands 已在 .gitignore 中"
fi
echo ""

# 7. 完成提示
echo "✅ 初始化完成！"
echo ""
echo "📋 后续步骤："
echo "   1. 编辑 .claude/project-context.md 填写项目信息"
echo "   2. 查看示例文档："
echo "      .ai-configs/examples/README.md - 优化工作流程示例"
echo "   3. 使用命令："
echo "      /brainstorm [主题]             - 脑暴与方案探索"
echo "      /req-analyze [需求描述]      - 需求分析（推荐第一步）"
echo "      /prd [功能描述]             - 生成产品需求文档"
echo "      /update-prd                 - 更新 PRD 文档"
echo "      /design [功能描述]          - 生成设计方案"
echo "      /create-plan [功能描述]     - 生成编码计划"
echo "      /update-plan                - 更新编码计划"
echo "      /code-by-plan               - 按计划编码"
echo "      /bug-fix [Bug 描述]         - Bug 修复"
echo "      /review                     - 代码审查"
echo ""
echo "📁 目录结构："
echo "   .claude/"
echo "   ├── commands/              # 命令软链接（已添加到 .gitignore）"
echo "   │   ├── brainstorm.md"
echo "   │   ├── req-analyze.md"
echo "   │   ├── prd.md"
echo "   │   ├── update-prd.md"
echo "   │   ├── design.md"
echo "   │   ├── create-plan.md"
echo "   │   ├── update-plan.md"
echo "   │   ├── code-by-plan.md"
echo "   │   ├── bug-fix.md"
echo "   │   └── review.md"
echo "   └── project-context.md     # 项目配置（请编辑）"
echo ""
echo "   .ai-configs/"
echo "   ├── analysis/              # 需求分析报告（按年/月组织）"
echo "   ├── brainstorm/            # 脑暴记录"
echo "   ├── design/                # 设计方案"
echo "   ├── prd/                   # PRD 文档"
echo "   ├── plan/                  # 编码计划"
echo "   ├── progress/              # 执行进度"
echo "   └── examples/              # 示例文档（包含工作流程说明）"
echo ""
echo "💡 提示："
echo "   - project-context.md 建议提交到 git，团队共享"
echo "   - 命令软链接不会提交（已在 .gitignore 中）"
echo "   - 更新全局命令：编辑 ~/.claude-commands/*.md"
echo ""
