# 资产目录

该目录用于存放DripLix应用中使用的所有图片和Logo。

## 目录结构

- `logos/` - 应用Logo和品牌图片
  - `app_logo.png` - 主应用Logo (推荐: 512x512px)
  - `app_logo_small.png` - 导航栏小版本 (推荐: 64x64px)
  - `favicon.png` - Web favicon (推荐: 32x32px)

- `navigation/` - 导航栏特定图片
  - `search_icon.png` - 搜索按钮图标
  - `notification_icon.png` - 通知按钮图标
  - `profile_icon.png` - 个人中心按钮图标

- `icons/` - 通用应用图标
  - `explore_icon.png` - 探索功能图标
  - `save_icon.png` - 保存功能图标
  - `share_icon.png` - 分享功能图标

## 图片要求

- **格式**: PNG/SVG格式，支持透明度
- **分辨率**: 高分辨率 (2x或3x适用于Retina显示屏)
- **风格**: 黑白色主题，与应用设计匹配
- **背景**: 透明或白色背景

## 使用方法

将您的图片添加到适当的目录中，并更新`pubspec.yaml`文件以将它们包含在资产部分中。
