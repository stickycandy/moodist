## ADDED Requirements

### Requirement: Now Playing 信息显示

系统 SHALL 在 iOS 锁屏界面和控制中心显示 Now Playing 媒体卡片，包含以下信息：
- 标题：当前预设名称（如已加载预设）或 "Ting"（如未加载预设）
- 封面图：App 图标
- 播放状态：播放/暂停

#### Scenario: 加载预设后显示预设名称
- **WHEN** 用户加载名为 "深夜森林" 的预设并开始播放
- **THEN** 锁屏和控制中心显示标题为 "深夜森林"

#### Scenario: 手动选择声音显示 Ting
- **WHEN** 用户手动选择声音（非通过预设加载）并开始播放
- **THEN** 锁屏和控制中心显示标题为 "Ting"

#### Scenario: 调整音量保持预设名称
- **WHEN** 用户加载预设后调整某个声音的音量
- **THEN** 锁屏和控制中心继续显示预设名称

#### Scenario: 选择新声音清空预设名称
- **WHEN** 用户加载预设后手动选择或取消某个声音
- **THEN** 锁屏和控制中心标题变为 "Ting"

### Requirement: 远程播放控制

系统 SHALL 响应 iOS 锁屏和控制中心的播放/暂停控制命令。

#### Scenario: 锁屏暂停
- **WHEN** 用户在锁屏界面点击暂停按钮
- **THEN** 所有正在播放的声音暂停

#### Scenario: 锁屏恢复播放
- **WHEN** 用户在锁屏界面点击播放按钮
- **THEN** 之前选中的声音恢复播放

#### Scenario: 控制中心控制
- **WHEN** 用户在控制中心点击播放/暂停按钮
- **THEN** 播放状态相应切换

### Requirement: 睡眠定时进度显示

当设置睡眠定时时，系统 SHALL 在 Now Playing 卡片中显示进度信息。

#### Scenario: 显示定时进度
- **WHEN** 用户设置 30 分钟睡眠定时并已过 10 分钟
- **THEN** 锁屏显示进度条，位置约在 1/3 处，总时长显示为 30:00

#### Scenario: 无定时不显示进度
- **WHEN** 用户未设置睡眠定时
- **THEN** 锁屏不显示进度条和时长信息

#### Scenario: 取消定时清除进度
- **WHEN** 用户取消睡眠定时
- **THEN** 锁屏进度条消失

### Requirement: Now Playing 生命周期管理

系统 SHALL 在适当时机更新或清除 Now Playing 信息。

#### Scenario: 开始播放时显示
- **WHEN** 用户开始播放声音
- **THEN** Now Playing 信息出现在锁屏和控制中心

#### Scenario: 暂停时保持显示
- **WHEN** 用户暂停播放
- **THEN** Now Playing 信息继续显示，状态更新为暂停

#### Scenario: 清空所有声音时清除
- **WHEN** 用户取消所有声音的选择
- **THEN** Now Playing 信息从锁屏和控制中心消失
