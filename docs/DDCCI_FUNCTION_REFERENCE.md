# DDC/CI Function Reference

## 1. 文档目的
这份文档用于交接给新的 UI 设计与实现。

目标不是描述现有界面，而是描述当前代码里已经存在的功能能力：

- 应用能识别哪些设备级信息
- 每个显示器可以读取哪些参数
- 每个显示器可以写入哪些参数
- 已知 VCP 功能 ID 分别属于哪些分类
- 各个 VCP 功能的推荐控件形态是什么

代码来源主要是：

- `lib/src/ddcci/windows_ddcci.dart`
- `lib/src/ddcci/models.dart`
- `lib/src/ddcci/vcp_catalog.dart`

## 2. 服务层能力

### 2.1 设备级接口

#### `loadMonitors()`
用途：扫描当前系统中的物理显示器，并返回每台显示器的完整快照。

返回结果：`List<MonitorSnapshot>`

会尝试读取：

- 显示器内部 ID
- 显示器描述文本
- capabilities 原始字符串
- capabilities 解析结果
- 已知 VCP 功能列表
- 未知 VCP 功能列表
- 当前水平频率
- 当前垂直频率

#### `refreshMonitor(monitorId)`
用途：只刷新某一台已打开显示器的快照。

返回结果：`MonitorSnapshot`

会重新读取：

- capabilities
- capabilities 解析结果
- 该显示器的已知/未知 VCP 状态
- 当前水平/垂直频率

#### `readFeatureValue(monitorId, code)`
用途：读取指定 VCP 功能当前值。

返回结果：`VcpReadResult`

可读字段：

- `success`
- `currentValue`
- `maximumValue`
- `codeType`
- `windowsError`

#### `setFeatureValue(monitorId, code, value)`
用途：向显示器写入指定 VCP 值。

输入参数：

- `monitorId`
- `code`
- `value`

注意：

- 底层允许对任意 VCP code 发起写入
- 真正是否支持，取决于显示器实现
- 写入失败会抛出异常并带 Win32 错误码

#### `saveSettings(monitorId)`
用途：请求显示器持久化当前设置。

这不是 VCP 通用字段写入，而是显示器级保存动作。

### 2.2 设备级数据模型

#### `MonitorSnapshot`
一台显示器的完整状态快照。

字段：

- `id`: 应用内部稳定 ID，用于后续读写接口
- `description`: 显示器描述文本
- `capabilities`: 原始 MCCS capabilities 字符串
- `capabilitiesData`: 解析后的结构化结果
- `features`: 已知 VCP 功能列表
- `unknownFeatures`: capabilities 声明支持，但 catalog 未命名的 VCP 列表
- `horizontalFrequency`: 当前水平频率，单位 Hz
- `verticalFrequency`: 当前垂直频率，单位 Hz
- `errorMessage`: 扫描或读取过程中产生的错误说明

#### `ParsedCapabilities`
`capabilities` 的结构化结果。

字段：

- `raw`: 原始 capabilities 文本
- `model`: 型号
- `displayType`: 显示类型
- `mccsVersion`: MCCS 版本
- `supportedCommands`: 声明支持的 DDC/CI command 集合
- `supportedVcpCodes`: 声明支持的 VCP code 集合
- `supportedVcpValues`: 某些离散 VCP 的可选值集合

#### `MonitorFeatureState`
单个 VCP 功能的 UI 侧聚合模型。

字段：

- `code`: VCP ID
- `definition`: 如果该 code 在 catalog 中已知，则有定义
- `supported`: capabilities 或实际探测认为该功能受支持
- `supportedValues`: capabilities 声明的可选值
- `readResult`: 最近一次读取结果

派生字段：

- `name`
- `category`
- `description`
- `kind`
- `isMomentary`
- `canRead`
- `currentValue`
- `maximumValue`

### 2.3 通用读写语义

#### 所有 VCP 功能通用的可读信息
对一个功能执行读取后，UI 可以展示：

- 当前值 `currentValue`
- 最大值 `maximumValue`
- 读取是否成功 `success`
- 读取失败时的 `windowsError`
- `codeType`，可辅助判断它是动作型还是普通值型

#### 所有 VCP 功能通用的可写信息
对一个功能执行写入时，UI 需要提交：

- `code`
- `value`

不同功能的差异主要在于：

- `value` 是连续值、枚举值、开关值还是动作触发值
- 是否常见为只写或读常失败

## 3. VCP 分类总览

当前 catalog 中的已知大类：

- 系统
- 亮度与对比度
- 色彩
- 几何
- 输入与电源
- 音频
- OSD 与图像
- 厂商扩展

## 4. VCP 功能目录

说明：

- “类型” 对应 `VcpControlKind`
- “读取” 表示是否适合做读取展示
- “写入” 表示当前代码允许发起写入
- “读常失败” 表示 catalog 已标注 `readOftenUnsupported = true`

### 4.1 系统

| ID | 十进制 | 名称 | 类型 | 读取 | 写入 | 参数/说明 |
| --- | ---: | --- | --- | --- | --- | --- |
| `0x04` | 4 | 恢复出厂设置 | `action` | 可尝试读，但更偏动作 | 是 | 写入固定值 `1` 触发 |
| `0x52` | 82 | 激活控制 | `numeric` | 是 | 是 | 数值型，具体语义依赖厂商 |
| `0xB0` | 176 | 设置保存 | `action` | 常见读失败 | 是 | 写入固定值 `1` 触发 |

### 4.2 亮度与对比度

| ID | 十进制 | 名称 | 类型 | 读取 | 写入 | 参数/说明 |
| --- | ---: | --- | --- | --- | --- | --- |
| `0x05` | 5 | 恢复亮度/对比度 | `action` | 可尝试读，但更偏动作 | 是 | 写入固定值 `1` 触发 |
| `0x10` | 16 | 亮度 | `continuous` | 是 | 是 | 连续值，通常展示 `current/max` |
| `0x12` | 18 | 对比度 | `continuous` | 是 | 是 | 连续值 |
| `0x6C` | 108 | 黑电平 | `continuous` | 是 | 是 | 连续值 |

### 4.3 色彩

| ID | 十进制 | 名称 | 类型 | 读取 | 写入 | 参数/说明 |
| --- | ---: | --- | --- | --- | --- | --- |
| `0x08` | 8 | 恢复色彩设置 | `action` | 可尝试读，但更偏动作 | 是 | 写入固定值 `1` 触发 |
| `0x0B` | 11 | 色温增量 | `numeric` | 是 | 是 | 数值型 |
| `0x0C` | 12 | 色温请求 | `numeric` | 是 | 是 | 数值型 |
| `0x14` | 20 | 色彩预设 | `discrete` | 是 | 是 | 枚举值，见下方选项 |
| `0x16` | 22 | 红色增益 | `continuous` | 是 | 是 | 连续值 |
| `0x18` | 24 | 绿色增益 | `continuous` | 是 | 是 | 连续值 |
| `0x1A` | 26 | 蓝色增益 | `continuous` | 是 | 是 | 连续值 |
| `0x6E` | 110 | 红色黑电平 | `continuous` | 是 | 是 | 连续值 |
| `0x70` | 112 | 绿色黑电平 | `continuous` | 是 | 是 | 连续值 |
| `0x72` | 114 | 蓝色黑电平 | `continuous` | 是 | 是 | 连续值 |

`0x14` 色彩预设枚举：

- `0x01` sRGB
- `0x02` Display Native
- `0x03` 4000K
- `0x04` 5000K
- `0x05` 6500K
- `0x06` 7500K
- `0x07` 8200K
- `0x08` 9300K
- `0x09` 10000K
- `0x0A` 11500K
- `0x0B` 用户 1
- `0x0C` 用户 2
- `0x0D` 用户 3

### 4.4 几何

| ID | 十进制 | 名称 | 类型 | 读取 | 写入 | 参数/说明 |
| --- | ---: | --- | --- | --- | --- | --- |
| `0x06` | 6 | 恢复几何设置 | `action` | 可尝试读，但更偏动作 | 是 | 写入固定值 `1` 触发 |
| `0x20` | 32 | 水平位置 | `continuous` | 是 | 是 | 连续值 |
| `0x22` | 34 | 水平尺寸 | `continuous` | 是 | 是 | 连续值 |
| `0x30` | 48 | 垂直位置 | `continuous` | 是 | 是 | 连续值 |
| `0x32` | 50 | 垂直尺寸 | `continuous` | 是 | 是 | 连续值 |

### 4.5 输入与电源

| ID | 十进制 | 名称 | 类型 | 读取 | 写入 | 参数/说明 |
| --- | ---: | --- | --- | --- | --- | --- |
| `0x60` | 96 | 输入源 | `discrete` | 可读，但常见读失败 | 是 | 枚举值，见下方选项 |
| `0xD6` | 214 | 电源模式 | `discrete` | 可读，但常见读失败 | 是 | 枚举值，见下方选项 |

`0x60` 输入源枚举：

- `0x01` VGA-1
- `0x02` VGA-2
- `0x03` DVI-1
- `0x04` DVI-2
- `0x05` Composite-1
- `0x06` Composite-2
- `0x07` S-Video-1
- `0x08` S-Video-2
- `0x09` Tuner-1
- `0x0A` Tuner-2
- `0x0B` Tuner-3
- `0x0C` Component-1
- `0x0D` Component-2
- `0x0E` Component-3
- `0x0F` DisplayPort-1
- `0x10` DisplayPort-2
- `0x11` HDMI-1
- `0x12` HDMI-2
- `0x13` USB-C

`0xD6` 电源模式枚举：

- `0x01` 开机
- `0x02` 待机
- `0x03` 挂起
- `0x04` 关机
- `0x05` 软关机

### 4.6 音频

| ID | 十进制 | 名称 | 类型 | 读取 | 写入 | 参数/说明 |
| --- | ---: | --- | --- | --- | --- | --- |
| `0x62` | 98 | 音量 | `continuous` | 是 | 是 | 连续值 |
| `0x8D` | 141 | 静音 | `toggle` | 是 | 是 | 开关值，常见值为 `1/2` |
| `0x8F` | 143 | 音频高音 | `continuous` | 是 | 是 | 连续值 |
| `0x90` | 144 | 音频低音 | `continuous` | 是 | 是 | 连续值 |

`0x8D` 静音枚举：

- `0x01` 开
- `0x02` 关

### 4.7 OSD 与图像

| ID | 十进制 | 名称 | 类型 | 读取 | 写入 | 参数/说明 |
| --- | ---: | --- | --- | --- | --- | --- |
| `0x86` | 134 | 显示缩放 | `discrete` | 是 | 是 | 枚举值，具体值通常依厂商而定 |
| `0x87` | 135 | 锐度 | `continuous` | 是 | 是 | 连续值 |
| `0xAA` | 170 | 屏幕方向 | `discrete` | 是 | 是 | 枚举值，具体值依厂商而定 |
| `0xAC` | 172 | 水平翻转 | `toggle` | 是 | 是 | 开关值 |
| `0xAE` | 174 | 垂直翻转 | `toggle` | 是 | 是 | 开关值 |
| `0xCA` | 202 | OSD 开关 | `toggle` | 可读，但常见读失败 | 是 | 开关值 |
| `0xCC` | 204 | OSD 语言 | `discrete` | 可读，但常见读失败 | 是 | 枚举值，见下方选项 |
| `0xDC` | 220 | 显示模式 | `discrete` | 是 | 是 | 枚举值依厂商而定 |
| `0xDE` | 222 | 扫描模式 | `discrete` | 可读，但常见读失败 | 是 | 枚举值依厂商而定 |

`0xCC` OSD 语言枚举：

- `0x01` 中文
- `0x02` 英语
- `0x03` 法语
- `0x04` 德语
- `0x05` 意大利语
- `0x06` 西班牙语
- `0x07` 日语
- `0x08` 韩语
- `0x09` 俄语
- `0x0A` 葡萄牙语

### 4.8 厂商扩展

来源：`MonitorSnapshot.unknownFeatures`

说明：

- 这些 VCP code 在 capabilities 中声明支持
- 但当前本地 catalog 没有命名定义
- 仍然可以：
  - 展示 code
  - 展示是否支持
  - 展示当前值/最大值
  - 允许做直接读写

建议 UI 提供：

- 原始 `code`
- `currentValue`
- `maximumValue`
- `windowsError`
- 手动写入入口

## 5. 类型到控件的推荐映射

这是基于当前数据模型的推荐，不代表强制 UI 方案。

### `continuous`
适用：

- 亮度
- 对比度
- 音量
- 锐度
- RGB 增益
- 几何位置/尺寸

推荐控件：

- 单行布局
- 左侧标签
- 右侧滑杆
- 滑杆右侧数值输入框

### `discrete`
适用：

- 输入源
- 色彩预设
- 电源模式
- OSD 语言

推荐控件：

- 单行布局
- 左侧标签
- 右侧下拉框

### `toggle`
适用：

- 静音
- OSD 开关
- 水平翻转
- 垂直翻转

推荐控件：

- 单行布局
- 左侧标签
- 右侧开关控件

### `action`
适用：

- 恢复出厂设置
- 恢复亮度/对比度
- 恢复几何设置
- 恢复色彩设置
- 设置保存

推荐控件：

- 单行布局
- 左侧标签
- 右侧按钮
- 危险动作加确认

### `numeric`
适用：

- 色温增量
- 色温请求
- 激活控制

推荐控件：

- 单行布局
- 左侧标签
- 右侧整数输入框 + 提交按钮

## 6. 设计时最值得保留的字段

如果你只想画一版高效工具 UI，而不是把所有原始字段都塞进去，建议最少保留：

### 设备概览层

- `description`
- `model`
- `mccsVersion`
- `displayType`
- `horizontalFrequency`
- `verticalFrequency`
- `errorMessage`

### 控制层

- `code`
- `name`
- `category`
- `kind`
- `currentValue`
- `maximumValue`
- `supported`
- `supportedValues`

### 诊断层

- `capabilities`
- `supportedVcpCodes`
- `supportedVcpValues`
- `windowsError`
- `unknownFeatures`

## 7. 仍然存在的不确定性

这些不是文档遗漏，而是显示器协议本身或厂商实现导致的：

- 某些功能虽然 catalog 中已知，但具体可选值仍依厂商而变
- 某些功能可写但不可读
- 某些功能 capabilities 中声明支持，但实际读写会失败
- 某些未知功能只能通过手动试探理解

因此重新画 UI 时，建议把“字段定义”和“设备实际响应”分开显示：

- 定义层：来自 catalog / capabilities
- 实际层：来自当前读写结果
