# 代码审查详细检查清单

## 一、样式覆盖检查

### 1.1 CSS/Less 全局污染
- [ ] **全局选择器**：是否使用了全局 class 名称可能污染其他组件
  ```less
  // 危险：全局样式
  .header { ... }
  .table { ... }

  // 安全：使用模块化或特定前缀
  .alert-history-header { ... }
  .monitor-table { ... }
  ```

- [ ] **样式权重**：是否使用了过高的选择器权重
  ```less
  // 避免：过高权重，难以覆盖
  #app .container div.box { ... }

  // 推荐：合理权重
  .alert-box { ... }
  ```

- [ ] **!important 滥用**：是否过度使用 !important

### 1.2 UI 库样式覆盖
- [ ] **正确的覆盖方式**：使用包裹类名限定范围
  ```less
  // 正确：限定范围
  .custom-modal {
    .ant-modal-header { ... }
  }

  // 错误：直接覆盖全局
  .ant-modal-header { ... }
  ```

- [ ] **主题变量使用**：是否正确使用主题变量而非硬编码颜色

### 1.3 CSS Module 检查
- [ ] 是否正确使用 CSS Module 语法
- [ ] :global() 的使用是否必要和安全

### 1.4 样式文件组织
- [ ] 样式文件是否放在正确的位置
- [ ] 是否有未使用的样式定义
- [ ] 是否有重复的样式代码

## 二、第三方库版本检查

### 2.1 版本识别
- [ ] 明确当前修改属于哪个版本（从 project-context.md 读取）
- [ ] 检查 package.json 中的依赖版本
- [ ] 确认使用的 API 与版本匹配

### 2.2 React 版本兼容性
**根据 project-context.md 中的 React 版本检查**：
- React 16.5.x：不能使用 Hooks
- React 16.8+：可以使用 Hooks
- React 18+：注意并发特性
- React 19+：注意最新 API 变化

### 2.3 UI 库版本差异
**根据 project-context.md 中的 UI 库版本检查**：
- Icon 使用方式是否正确
- Form API 是否匹配版本
- Table 分页 API
- Modal 方法调用
- Message/Notification API

### 2.4 路由库版本差异
- React Router 3.x：hashHistory/browserHistory
- React Router 5.x：useHistory hook
- React Router 6.x：useNavigate hook
- TanStack Router：类型安全路由

### 2.5 状态管理差异
- Redux：connect, mapStateToProps
- Zustand：create, useStore
- Context API：createContext, useContext

### 2.6 其他库版本检查
- [ ] 图表库 API 变化
- [ ] 日期处理库（Moment.js vs Day.js）
- [ ] 新增依赖的必要性

## 三、影响范围分析

### 3.1 文件依赖分析
使用 `rg` 搜索，分析影响范围：

```bash
# 如果修改了公共组件
rg "import.*CommonComponent" src/

# 如果修改了工具函数
rg "import.*utils" src/

# 如果修改了 Store
rg "useXXXStore" src/
```

**需要回答的问题**：
- [ ] 这个文件被哪些模块引用？
- [ ] 修改是否会破坏现有功能？
- [ ] 是否需要同步修改其他文件？

### 3.2 API 变更影响
- [ ] 如果修改了函数签名，列出所有调用点
- [ ] 如果修改了组件 Props，检查所有使用该组件的地方
- [ ] 如果修改了 Store 状态结构，检查所有消费者

### 3.3 全局影响
- [ ] 是否修改了全局配置文件？
- [ ] 是否影响路由结构？
- [ ] 是否影响权限控制？
- [ ] 是否影响主题样式？

### 3.4 跨版本影响
- [ ] 如果是公共代码，是否影响多个版本？
- [ ] 是否需要在多个版本中同步修改？

### 3.5 数据流影响
- [ ] 状态管理的变更影响哪些组件？
- [ ] API 数据结构变更的影响范围？
- [ ] LocalStorage/SessionStorage 变更的影响？

## 四、代码质量检查

### 4.1 React 最佳实践
- [ ] **Hooks 使用规范**：Hooks 在顶层，不在条件语句中
- [ ] **依赖项完整性**：useEffect 依赖项是否完整
- [ ] **Key 的正确使用**：使用唯一标识而非 index

### 4.2 性能问题
- [ ] 不必要的重渲染
- [ ] 大列表优化
- [ ] useCallback/useMemo 的合理使用

### 4.3 安全性检查
- [ ] **XSS 防护**
- [ ] **敏感信息**：是否暴露 API Key、密码等
- [ ] **输入验证**：是否验证用户输入
- [ ] **权限检查**：是否有权限控制漏洞

### 4.4 错误处理
- [ ] 是否有适当的错误边界（Error Boundary）
- [ ] 异步操作是否有错误处理（try-catch）
- [ ] 是否给用户友好的错误提示

### 4.5 代码规范
- [ ] 命名是否清晰
- [ ] 是否有过长的函数（超过 50 行）
- [ ] 是否有重复代码
- [ ] 注释是否必要和准确
- [ ] TypeScript 类型是否正确

## 五、测试相关

### 5.1 功能完整性
- [ ] 是否实现了所有需求点
- [ ] 边界情况是否考虑
- [ ] 异常情况是否处理

### 5.2 测试建议
- [ ] 是否需要添加单元测试
- [ ] 关键业务逻辑是否需要测试覆盖
- [ ] 提供测试用例建议
