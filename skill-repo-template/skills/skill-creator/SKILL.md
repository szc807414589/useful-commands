---
name: skill-creator
description: 创建有效技能的指南。当用户想要创建新技能（或更新现有技能）以通过专业知识、工作流程或工具集成扩展Claude的能力时，应使用此技能。
license: Complete terms in LICENSE.txt
---

# Skill Creator

创建有效技能的指南。

## About Skills

技能是模块化的、自包含的包，通过提供专业知识、工作流程和工具来扩展Claude的能力。可以把它们看作是特定领域或任务的“入职指南”——它们将Claude从通用型Agent转变为专业化Agent，配备专业知识，使其成为任何模型都无法完全拥有的能力。

### 技能提供什么

1. 专业化工作流 - 特定领域的多步骤流程
2. 工具集成 - 用于处理特定文件格式或API的说明
3. 领域专业知识 - 公司特定的知识、模式、业务逻辑
4. 捆绑资源 - 用于复杂和重复任务的脚本、参考资料和资产

### Anatomy of a Skill

每个技能都包含一个必需的SKILL.md文件和可选的捆绑资源：

```
skill-name/
├── SKILL.md (必需)
│   ├── YAML前言元数据 (必需)
│   │   ├── name: (必需)
│   │   └── description: (必需)
│   └── Markdown指令 (必需)
└── 捆绑资源 (可选)
    ├── scripts/          - 可执行代码 (Python/Bash/等)
    ├── references/       - 文档，按需加载到上下文中
    └── assets/           - 输出中使用的文件 (模板、图标、字体等)
```

#### SKILL.md (required)

**Metadata Quality:** YAML前言元数据中的`name`和`description`决定了Claude何时使用技能。具体说明技能的作用和使用时机。使用第三人称 (例如 "This skill should be used when..." 而不是 "Use this skill when...")。

#### 捆绑资源 (可选)

##### 脚本 (`scripts/`)

可执行代码 (Python/Bash/等) 用于需要确定性可靠性的任务或需要反复重写的任务。

##### 参考资料 (`references/`)

文档和参考资料，按需加载到上下文中，以指导Claude的思考和处理。

##### 资产 (`assets/`)

不打算加载到上下文中的文件，而是用于Claude的输出中。

### 渐进式披露设计原则

技能使用三级加载系统来高效管理上下文：

1. **元数据 (name + description)** - 始终在上下文中 (~100 words)
2. **SKILL.md 主体** - 当技能触发时 (<5k words) 
3. **捆绑资源** - 按需加载到上下文中 (无限制*)

*因为脚本可以执行而不需要读取到上下文窗口。

## 技能创建流程

要创建一个技能，按照 "技能创建流程" 的顺序进行，只有在有明确理由时才跳过步骤。

### 第一步: 理解技能的实际应用

当构建一个图像编辑器技能时，相关问题包括：

- "图像编辑器技能应该支持什么功能？编辑、旋转、其他功能？"
- "你能给出一些这个技能实际应用的例子吗？"
- "我想到用户可能会问类似 'Remove the red-eye from this image' 或 'Rotate this image' 的问题。还有其他想象这个技能被使用的方式吗？"
- "用户说什么应该触发这个技能？"

### 第二步: 规划可重用技能内容

将具体例子转化为有效技能，分析每个例子：

1. 考虑如何从头开始执行例子
2. 识别在重复执行这些工作流程时哪些脚本、参考资料和资产会有帮助

To establish the skill's contents, analyze each concrete example to create a list of the reusable resources to include: scripts, references, and assets.

### 第三步: 初始化技能

现在，是时候实际创建技能了。

只有在技能已经存在并且需要迭代或打包时才跳过这一步。在这种情况下，继续下一步。

当从头创建新技能时，总是运行 `init_skill.py` 脚本。该脚本方便地生成一个新的模板技能目录，自动包含技能所需的所有内容，使技能创建过程更高效、更可靠。

使用方法：

```bash
scripts/init_skill.py <skill-name> --path <输出目录>
```

脚本：

- 在指定路径创建技能目录
- 生成带有适当前言元数据和TODO占位符的SKILL.md模板
- 创建示例资源目录: `scripts/`, `references/`, and `assets/`
- 在每个目录中添加示例文件，可以自定义或删除

初始化后，根据需要自定义或删除生成的SKILL.md和示例文件。

### 第四步: 编辑技能

#### 从可重用技能内容开始

从上面识别的可重用资源开始：`scripts/`, `references/`, and `assets/` 文件。注意这步可能需要用户输入。例如，当实现一个 `brand-guidelines` 技能时，用户可能需要提供品牌资产或模板存储在 `assets/` 中，或文档存储在 `references/` 中。

删除不需要的示例文件和目录。初始化脚本在 `scripts/`, `references/`, and `assets/` 中创建示例文件以演示结构，但大多数技能不需要所有这些文件。

打包脚本将：

1. **验证** 技能自动检查：
   - YAML前言元数据格式和必填字段
   - 技能命名约定和目录结构
   - 描述完整性和质量
   - 文件组织和资源引用

2. **打包** 如果验证通过，创建一个名为技能名的zip文件 (例如 `my-skill.zip`) ，包含所有文件并保持适当的目录结构用于分发。

如果验证失败，脚本将报告错误并退出而不创建包。修复任何验证错误并再次运行打包命令。

测试技能后，用户可能会请求改进。通常发生在使用技能后，有新的上下文了解技能的表现。

**Iteration workflow:**
1. 在实际任务上使用技能
2. 注意困难或低效
3. 识别如何更新SKILL.md或捆绑资源
4. 实施更改并再次测试
