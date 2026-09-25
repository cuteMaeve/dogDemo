# Dog Demo

一款使用 Godot 4.6 制作的本地双人非对称对战小游戏原型。

一名玩家扮演小狗，利用嗅觉和冲刺寻找隐藏目标；另一名玩家扮演主人，使用捕网阻止小狗，并尝试抢先清理目标。双方起初都不知道目标位置。

## 游戏规则

- 每局时长为 120 秒。
- 小狗找到目标，并在目标附近持续完成进食，即可获胜。
- 主人可以通过以下任一方式获胜：
  - 坚持到倒计时结束；
  - 用捕网抓住小狗 3 次；
  - 找到目标并持续完成清理。
- 地板、障碍物、花草和目标位置会按受控规则随机生成。
- 摄像机会自动跟随并缩放，保证两名玩家尽量同时处于画面内。

## 操作方式

### 小狗玩家

| 操作 | 按键 |
| --- | --- |
| 移动 | `W` `A` `S` `D` |
| 嗅觉探测 | `Q` |
| 冲刺 | `E` |
| 长按进食 | `F` |

### 主人玩家

| 操作 | 按键 |
| --- | --- |
| 移动 | 方向键 |
| 发射捕网 | `J` |
| 长按清理 | `K` |

### 通用与调试

| 操作 | 按键 |
| --- | --- |
| 快速重新开始 | `R` |
| 显示调试信息 | 按住 `Tab` |

## 运行项目

1. 安装 [Godot Engine 4.6](https://godotengine.org/)。
2. 使用 Godot 导入仓库根目录中的 `project.godot`。
3. 在编辑器中运行主场景，或按 `F6` / `F5` 启动游戏。

项目使用 Compatibility 渲染器，设计视口为 1280×720。

## 当前版本

`v0.1.0` 是第一版可玩原型，包含：

- 完整的双人移动、嗅觉、冲刺、捕网、进食和清理流程；
- 三种主人获胜条件与一种小狗获胜条件；
- 受控随机地图、障碍物与植被；
- 双人动态摄像机；
- 基础像素美术、音效、音乐和游戏内反馈；
- 五阶段自动测试与随机地图稳定性检查。

当前版本尚未提供独立的 Windows 可执行文件、在线联机、手柄支持或完整菜单系统。

## 自动测试

测试脚本位于 `tests/`。可以使用 Godot 控制台版本分别运行：

```powershell
Godot_v4.6.3-stable_win64_console.exe --headless --path . --script res://tests/phase1_smoke.gd
Godot_v4.6.3-stable_win64_console.exe --headless --path . --script res://tests/phase2_smoke.gd
Godot_v4.6.3-stable_win64_console.exe --headless --path . --script res://tests/phase3_smoke.gd
Godot_v4.6.3-stable_win64_console.exe --headless --path . --script res://tests/phase4_smoke.gd
Godot_v4.6.3-stable_win64_console.exe --headless --path . --script res://tests/phase5_stability.gd
```

第五阶段测试会连续生成并检查 100 个随机回合。

## 素材来源

项目使用 [Ninja Adventure Asset Pack](https://pixel-boy.itch.io/ninja-adventure-asset-pack) 中的像素美术与音频素材，作者为 [Pixel-boy](https://pixel-boy.itch.io/) 和 [AAA](https://www.instagram.com/challenger.aaa/)。素材以 CC0 1.0 发布，原始说明和许可证保留在：

- `assets/sprites/Ninja Adventure - Asset Pack/README.md`
- `assets/sprites/Ninja Adventure - Asset Pack/LICENSE.txt`

除上述第三方素材许可证外，本仓库暂未为项目代码声明额外的开源许可证。
