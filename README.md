# WJPhotoPicker

一个功能强大、高度可定制的 iOS 相册选择器，支持 WebP 动图展示、示例图片（支持 URL）、单选/多选模式，提供两种交互模式。集成专业级 FloatingPanel 实现流畅的滚动联动效果和模态视图隐藏动画。

## ✨ 核心特性

### 🎯 双模式交互
- **滑动面板模式** ⭐ **全新升级**
  - 上部展示 WebP 动图（支持网络/本地）
  - 下部 FloatingPanel 滑动面板
  - **完美滚动联动**: CollectionView 滚动时面板自动响应
  - **模态视图隐藏效果**: 向下滑动时背景内容实时变化
  - **智能滑动关闭**: 多种关闭方式，符合iOS原生体验
  - 工具栏集成在滑动面板顶部
  - 支持自定义顶部区域高度比例
  
- **标准模式**
  - 传统导航栏交互方式
  - 支持自定义导航栏标题
  - 单选模式自动隐藏完成按钮
  - 简洁清晰的界面

### 📸 选择模式
- **多选模式**
  - 自定义最大选择数量
  - 实时显示选中状态
  - 完成按钮智能启用/禁用
  
- **单选模式**
  - 选择即回调，无需确认
  - 自动隐藏完成按钮（标准模式）
  - 只显示相册选择按钮（滑动面板模式）

### 🖼️ 示例图片支持
- **支持两种类型**
  - `.image(UIImage)`: 本地图片
  - `.url(URL)`: 网络图片（自动加载和缓存）
  
- **即时回调**
  - `onSampleImageSelected`: 单个示例图片选择回调
  - `onSampleImagesCompleted`: 完成时返回所有选中的示例图片

### 🎨 高度可定制
- ✅ 自定义导航栏标题（标准模式）
- ✅ 自定义滑动面板顶部高度比例
- ✅ 自定义权限提示（图标、文字、按钮）
- ✅ 自定义网格列数和间距
- ✅ 自定义最大选择数量
- ✅ 自定义 WebP 动图占位图

### 🔐 权限管理
- 智能权限检测
- 友好的权限引导页面
- 一键跳转系统设置
- 支持自定义权限提示内容

### ⚡ 性能优化
- 图片缓存管理（SDWebImage）
- 内存警告处理
- 异步加载
- WebP 渐进式加载

### 🏗️ 架构清晰
- MVC + Service Layer
- 易于集成和维护
- 无需 RxSwift 依赖
- 代码结构清晰

## 📦 依赖

- SnapKit ~> 5.7
- SDWebImage ~> 5.21
- SDWebImageWebPCoder ~> 0.14
- **FloatingPanel ~> 3.0** ⭐ **新增**

## 🚀 安装

### Swift Package Manager（推荐）

#### 方法 1: 作为本地 Package 使用

1. 在 Xcode 中打开你的项目
2. 选择 `File` > `Add Package Dependencies...`
3. 点击 `Add Local...`
4. 选择 `MFPhotoPicker` 文件夹
5. 点击 `Add Package`
6. 在 target 中添加 `MFPhotoPicker` 库

#### 方法 2: 直接添加依赖

在你的项目中添加以下 SPM 依赖：

```swift
dependencies: [
    .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
    .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.21.0"),
    .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.14.0"),
    .package(url: "https://github.com/SCENEE/FloatingPanel.git", from: "3.0.1"),
]
```

然后将 `Sources/MFPhotoPicker` 文件夹复制到你的项目中。

### CocoaPods（已弃用）

⚠️ 注意：本项目已迁移到 Swift Package Manager，不再推荐使用 CocoaPods。

### 手动集成

将以下文件夹复制到你的项目中：
- `Sources/MFPhotoPicker/Models/`
- `Sources/MFPhotoPicker/Managers/`
- `Sources/MFPhotoPicker/Services/`
- `Sources/MFPhotoPicker/Views/`
- `Sources/MFPhotoPicker/ViewControllers/`
- `Sources/MFPhotoPicker/Extensions/`

并在 Xcode 中添加 SPM 依赖（SnapKit、SDWebImage、SDWebImageWebPCoder、FloatingPanel）。

📖 **详细集成指南**: 请查看 [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)

## 📝 配置

### 1. Info.plist 权限配置

在 `Info.plist` 中添加相册和相机权限说明：

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问您的相册以选择照片</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存照片到您的相册</string>

<key>NSCameraUsageDescription</key>
<string>需要使用相机拍摄照片</string>
```

### 2. AppDelegate 配置

在 `AppDelegate.swift` 中初始化 WebP 支持：

```swift
import SDWebImage
import SDWebImageWebPCoder

func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 注册 WebP 解码器
    let webPCoder = SDImageWebPCoder.shared
    SDImageCodersManager.shared.addCoder(webPCoder)
    
    // 配置缓存
    SDImageCache.shared.config.maxMemoryCost = 100 * 1024 * 1024  // 100MB
    SDImageCache.shared.config.maxDiskSize = 200 * 1024 * 1024    // 200MB
    
    return true
}
```

## 💡 使用示例

### 示例 1: 滑动面板多选模式 + 网络 WebP 动图 + 网络示例图片

```swift
import UIKit
import MFPhotoPicker
import Photos

class ViewController: UIViewController {
    
    @IBAction func openSlidingPanelPicker(_ sender: UIButton) {
        // 配置
        let config = PhotoPickerConfiguration(
            type: .slidingPanel,
            animatedImageURL: URL(string: "https://res.cloudinary.com/demo/image/upload/w_150,h_100,q_80/bored_animation.webp"),
            animatedImageData: nil,
            animatedImagePlaceholder: UIImage(systemName: "photo.on.rectangle.angled"),
            sampleImages: [
                .url(URL(string: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4")!),
                .url(URL(string: "https://images.unsplash.com/photo-1469474968028-56623f02e42e")!),
                .image(UIImage(named: "localSample")!)
            ],
            maxSelectionCount: 9,
            allowsCamera: true,
            allowsMultipleSelection: true,
            numberOfColumns: 3,
            gridSpacing: 2,
            navigationTitle: nil,  // 滑动面板模式不使用
            slidingPanelTopHeightRatio: 0.33,  // 顶部占 1/3 高度
            permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
            permissionMessage: "需要访问您的照片",
            permissionButtonTitle: "前往设置"
        )
        
        // 创建选择器
        let picker = WJPhotoPickerViewController(configuration: config)
        
        // 照片选择回调
        picker.onPhotosSelected = { assets in
            print("选择了 \(assets.count) 张照片")
            self.handleSelectedPhotos(assets)
        }
        
        // 示例图即时选择回调
        picker.onSampleImageSelected = { item in
            print("选择了示例图片: \(item)")
        }
        
        // 示例图完成回调
        picker.onSampleImagesCompleted = { items in
            print("完成选择，共 \(items.count) 张示例图片")
            self.handleSampleImages(items)
        }
        
        // 相机按钮点击回调
        picker.onCameraSelected = {
            print("用户点击了相机按钮")
        }
        
        // 拍照完成回调 ⭐ 新增
        picker.onCameraImageCaptured = { image in
            print("拍照完成，图片尺寸: \(image.size)")
            self.handleCapturedImage(image)
        }
        
        // 取消回调
        picker.onCancel = {
            print("用户取消")
        }
        
        // 展示
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    private func handleSelectedPhotos(_ assets: [PHAsset]) {
        for asset in assets {
            asset.getOriginalImage { image in
                if let image = image {
                    print("图片尺寸: \(image.size)")
                }
            }
        }
    }
    
    private func handleSampleImages(_ items: [WJSampleImageItem]) {
        for item in items {
            switch item {
            case .image(let image):
                print("本地图片: \(image.size)")
            case .url(let url):
                print("网络图片: \(url)")
                // 使用 SDWebImage 加载
            }
        }
    }
    
    private func handleCapturedImage(_ image: UIImage) {
        print("处理拍摄的图片: \(image.size)")
        
        // 可以进行图片处理、压缩、上传等操作
        // 例如：保存到相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // 或者显示预览
        showImagePreview(image)
    }
}
```

### 示例 2: 标准单选模式 + 自定义标题

```swift
@IBAction func openStandardSinglePicker(_ sender: UIButton) {
    let config = PhotoPickerConfiguration(
        type: .standard,
        animatedImageURL: nil,
        animatedImageData: nil,
        animatedImagePlaceholder: nil,
        sampleImages: [
            .url(URL(string: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4")!)
        ],
        maxSelectionCount: 1,
        allowsCamera: true,
        allowsMultipleSelection: false,  // 单选模式
        numberOfColumns: 4,
        gridSpacing: 1,
        navigationTitle: "选择一张照片",  // 自定义标题
        slidingPanelTopHeightRatio: 0.33,
        permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
        permissionMessage: "需要访问您的照片",
        permissionButtonTitle: "前往设置"
    )
    
    let picker = WJPhotoPickerViewController(configuration: config)
    
    // 单选模式：选择即回调，自动关闭
    picker.onPhotosSelected = { assets in
        if let asset = assets.first {
            print("选择了照片")
            // 处理选中的照片
        }
    }
    
    picker.onSampleImagesCompleted = { items in
        if let item = items.first {
            print("选择了示例图片")
            // 处理示例图片
        }
    }
    
    let nav = UINavigationController(rootViewController: picker)
    present(nav, animated: true)
}
```

### 示例 3: 滑动面板单选模式

```swift
@IBAction func openSlidingPanelSinglePicker(_ sender: UIButton) {
    let config = PhotoPickerConfiguration(
        type: .slidingPanel,
        animatedImageURL: URL(string: "https://res.cloudinary.com/demo/image/upload/w_150,h_100,q_80/bored_animation.webp"),
        animatedImageData: nil,
        animatedImagePlaceholder: UIImage(systemName: "photo.on.rectangle.angled"),
        sampleImages: [],
        maxSelectionCount: 1,
        allowsCamera: true,
        allowsMultipleSelection: false,  // 单选
        numberOfColumns: 3,
        gridSpacing: 2,
        navigationTitle: nil,
        slidingPanelTopHeightRatio: 0.33,
        permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
        permissionMessage: "需要访问您的照片",
        permissionButtonTitle: "前往设置"
    )
    
    let picker = WJPhotoPickerViewController(configuration: config)
    picker.onPhotosSelected = { assets in
        // 选择即回调，自动关闭
        print("选择了照片")
    }
    
    let nav = UINavigationController(rootViewController: picker)
    nav.modalPresentationStyle = .fullScreen
    present(nav, animated: true)
}
```

### 示例 4: 自定义滑动面板高度

```swift
let config = PhotoPickerConfiguration(
    type: .slidingPanel,
    animatedImageURL: someURL,
    animatedImageData: nil,
    animatedImagePlaceholder: nil,
    sampleImages: [],
    maxSelectionCount: 9,
    allowsCamera: true,
    allowsMultipleSelection: true,
    numberOfColumns: 3,
    gridSpacing: 2,
    navigationTitle: nil,
    slidingPanelTopHeightRatio: 0.4,  // 顶部占 40% 高度
    permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
    permissionMessage: "需要访问您的照片",
    permissionButtonTitle: "前往设置"
)
```

## ⚙️ 配置选项

### PhotoPickerConfiguration

| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `type` | `PhotoPickerType` | 选择器类型（`.slidingPanel` 或 `.standard`） | `.standard` |
| `animatedImageURL` | `URL?` | WebP 动图网络地址 | `nil` |
| `animatedImageData` | `Data?` | WebP 动图本地数据 | `nil` |
| `animatedImagePlaceholder` | `UIImage?` | 动图占位图 | 系统图标 |
| `sampleImages` | `[SampleImageItem]` | 示例图片列表（支持 `.image(UIImage)` 和 `.url(URL)`） | `[]` |
| `maxSelectionCount` | `Int` | 最大选择数量 | `9` |
| `allowsCamera` | `Bool` | 是否允许相机 | `true` |
| `allowsMultipleSelection` | `Bool` | 是否支持多选 | `true` |
| `numberOfColumns` | `Int` | 网格列数 | `3` |
| `gridSpacing` | `CGFloat` | 网格间距 | `2` |
| `navigationTitle` | `String?` | 标准模式的导航栏标题 | `nil` |
| `slidingPanelTopHeightRatio` | `CGFloat` | 滑动面板顶部区域高度比例（0.0-1.0） | `0.33` |
| `permissionIcon` | `UIImage?` | 权限提示图标 | 系统图标 |
| `permissionMessage` | `String?` | 权限提示文字 | `"需要访问您的照片"` |
| `permissionButtonTitle` | `String?` | 权限设置按钮文字 | `"前往设置"` |

### SampleImageItem

示例图片支持两种类型：

```swift
enum SampleImageItem {
    case image(UIImage)  // 本地图片
    case url(URL)        // 网络图片（自动加载和缓存）
}
```

### 回调函数

| 回调 | 类型 | 说明 |
|------|------|------|
| `onPhotosSelected` | `(([PHAsset]) -> Void)?` | 照片选择完成回调 |
| `onSampleImageSelected` | `((WJSampleImageItem) -> Void)?` | 单个示例图片选择回调（即时） |
| `onSampleImagesCompleted` | `(([WJSampleImageItem]) -> Void)?` | 示例图片选择完成回调 |
| `onCameraSelected` | `(() -> Void)?` | 相机按钮点击回调 |
| `onCameraImageCaptured` | `((UIImage) -> Void)?` | **拍照完成回调，直接返回UIImage** ⭐ **新增** |
| `onCancel` | `(() -> Void)?` | 取消回调 |

## 🎨 自定义

### 修改颜色主题

可以通过修改 UI 组件的颜色来自定义主题：

```swift
// 在 CustomPhotoPickerViewController 中
override func viewDidLoad() {
    super.viewDidLoad()
    
    // 自定义颜色
    view.backgroundColor = .systemBackground
    navigationController?.navigationBar.tintColor = .systemBlue
}
```

### 自定义网格布局

```swift
let config = PhotoPickerConfiguration(
    type: .standard,
    animatedImageURL: nil,
    animatedImageData: nil,
    animatedImagePlaceholder: nil,
    sampleImages: [],
    maxSelectionCount: 20,
    allowsCamera: true,
    allowsMultipleSelection: true,
    numberOfColumns: 4,      // 4列布局
    gridSpacing: 1           // 1pt间距
)
```

## 📱 系统要求

- iOS 14.0+
- Xcode 14.0+
- Swift 5.9+

## 🏗️ 架构

```
CustomPhotoPicker/
├── Models/                    # 数据模型
│   ├── PhotoPickerType.swift         # 选择器类型
│   ├── PermissionStatus.swift        # 权限状态
│   ├── PhotoAlbum.swift              # 相册模型
│   ├── PhotoPickerConfiguration.swift # 配置模型
│   ├── SampleImageItem.swift         # 示例图片类型（支持 UIImage 和 URL）
│   └── PhotoGridItem.swift           # 网格项类型（待实现）
│
├── Managers/                  # 管理器层
│   ├── PhotoAlbumManager.swift       # 相册管理
│   └── PhotoPermissionManager.swift  # 权限管理
│
├── Services/                  # 业务逻辑层
│   └── PhotoPickerService.swift      # 统一服务接口
│
├── Views/                     # 自定义视图
│   ├── WJAnimatedImageView.swift     # WebP 动图视图
│   ├── WJFloatingPanelLayout.swift   # FloatingPanel 布局配置 ⭐ 新增
│   ├── WJAlbumSelectorButton.swift   # 相册选择按钮
│   ├── WJPermissionGuideView.swift   # 权限引导视图
│   └── Cells/
│       ├── PhotoGridCell.swift       # 照片网格 Cell
│       ├── CameraCell.swift          # 相机 Cell
│       ├── SampleImageCell.swift     # 示例图片 Cell（支持 URL）
│       └── AlbumCell.swift           # 相册列表 Cell
│
├── ViewControllers/           # 视图控制器
│   ├── WJPhotoPickerViewController.swift      # 主选择器
│   ├── WJFloatingPanelContentViewController.swift  # FloatingPanel 内容控制器 ⭐ 新增
│   └── WJAlbumSelectorViewController.swift    # 相册选择器
│
└── Extensions/                # 扩展
    ├── PHAsset+Extensions.swift      # PHAsset 扩展
    ├── Data+WebP.swift               # WebP 数据处理
    ├── URL+Extensions.swift          # URL 扩展
    └── UIImage+Thumbnail.swift       # 缩略图生成
```

### 核心组件说明

#### Models
- **WJSampleImageItem**: 支持本地图片和网络 URL 两种类型
- **WJPhotoPickerConfiguration**: 完整的配置选项，包括权限提示、滑动面板高度等

#### Views ⭐ **重大更新**
- **WJFloatingPanelLayout**: FloatingPanel 自定义布局配置
  - 支持自定义高度比例
  - 智能移除阈值设置
  - 防止吸附行为配置
- **WJAnimatedImageView**: WebP 动图视图，支持模态隐藏效果
- **WJSampleImageCell**: 支持网络图片加载和缓存

#### ViewControllers ⭐ **架构优化**
- **WJPhotoPickerViewController**: 
  - 支持单选/多选模式
  - 单选模式自动隐藏完成按钮
  - 选择即回调（单选模式）
  - 完成按钮智能启用/禁用
  - 集成 FloatingPanel 管理
- **WJFloatingPanelContentViewController**: 
  - FloatingPanel 内容管理
  - 滚动联动处理
  - 模态视图隐藏效果
  - 智能关闭逻辑

## 🔧 高级用法

### 获取图片数据

```swift
picker.onPhotosSelected = { assets in
    for asset in assets {
        // 获取原图
        asset.getOriginalImage { image in
            print("原图: \(image?.size ?? .zero)")
        }
        
        // 获取缩略图
        asset.getThumbnail(size: CGSize(width: 200, height: 200)) { thumbnail in
            print("缩略图: \(thumbnail?.size ?? .zero)")
        }
        
        // 获取图片数据
        asset.getImageData { data in
            if let data = data {
                print("数据大小: \(data.count) bytes")
            }
        }
        
        // 获取文件大小
        print("文件大小: \(asset.fileSizeString)")
    }
}
```

### 监听相册变化

```swift
let service = PhotoPickerService.shared

service.observePhotoLibraryChanges { change in
    print("相册发生变化")
    // 重新加载数据
}
```

### 预加载动图

```swift
if let url = URL(string: "https://example.com/animation.webp") {
    SDWebImagePrefetcher.shared.prefetchURLs([url]) { finished, total in
        print("预加载完成: \(finished)/\(total)")
    }
}
```

## ⚠️ 注意事项

1. **权限处理**
   - 首次使用需要请求相册权限
   - iOS 14+ 支持限制访问模式
   - 务必在 Info.plist 中配置权限说明

2. **内存管理**
   - 大量图片加载时注意内存使用
   - 组件已实现内存警告处理
   - 建议设置合理的缓存大小

3. **WebP 支持**
   - 必须在 AppDelegate 中注册 WebP 解码器
   - 网络图片需要服务器支持 HTTPS
   - 本地 WebP 文件需要添加到项目资源

4. **性能优化**
   - 使用缩略图而非原图展示
   - 启用图片缓存
   - 合理设置网格列数

## 🐛 常见问题

### Q: 为什么 WebP 动图不显示？

A: 请确保：
1. 在 AppDelegate 中注册了 WebP 解码器
2. Podfile 中包含 `SDWebImageWebPCoder`
3. WebP 文件格式正确

### Q: 如何自定义相册选择器的样式？

A: 可以修改各个 View 组件的属性，或者继承 `CustomPhotoPickerViewController` 重写相关方法。

### Q: 支持 iPad 吗？

A: 支持，布局会自动适配不同屏幕尺寸。

### Q: 如何限制只选择图片不选择视频？

A: 当前版本只支持图片选择，视频功能可以通过修改 `PhotoAlbumManager` 的 `fetchPhotos` 方法添加。

### Q: FloatingPanel 滑动关闭不够灵敏怎么办？

A: 可以在 `WJFloatingPanelLayout.swift` 中调整以下参数：
```swift
// 降低速度阈值
func removalVelocityThreshold() -> CGFloat {
    return 100.0  // 默认值，可以降低到50-150
}

// 调整位置阈值
// 在 WJFloatingPanelContentViewController 中修改
if positionRatio > 0.6 {  // 可以调整为0.5-0.7
    // 触发关闭
}
```

### Q: 如何自定义 FloatingPanel 的动画效果？

A: FloatingPanel 提供了丰富的自定义选项，可以在 `WJFloatingPanelLayout.swift` 中配置：
- 修改 `anchors` 调整面板位置
- 重写 `backdropAlpha` 调整背景透明度
- 调整 `removalVelocityThreshold` 控制关闭灵敏度

## 📝 更新日志

### v3.0.0 (当前版本) ⭐ **重大升级**

#### 🚀 FloatingPanel 集成
- ✅ **替换自定义滑动面板**: 使用成熟的 FloatingPanel 库替换自定义实现
- ✅ **完美滚动联动**: 
  - CollectionView 向上滚动时面板自动展开
  - 向下滚动时面板自动收缩
  - 实时响应，流畅自然
- ✅ **模态视图隐藏效果**: 
  - 向下滑动时背景内容实时缩放、淡化、偏移
  - 添加圆角效果，模拟卡片缩小
  - 完全模拟 iOS 原生模态视图行为
- ✅ **智能滑动关闭**: 
  - **位置触发**: 滑动到屏幕60%位置即可关闭
  - **速度触发**: 快速向下滑动（速度>100）立即关闭
  - **组合触发**: 中等速度+一定位置智能判断
  - **防止吸附**: 移除tip状态，避免意外停留

#### 🎯 交互体验提升
- ✅ **系统级体验**: 与 iOS 原生应用行为完全一致
- ✅ **多重保障**: 4种关闭方式确保用户操作顺畅
- ✅ **连续动画**: 平滑的状态过渡，无突兀感
- ✅ **智能响应**: 自动处理手势冲突和边界情况

#### 🔧 技术架构优化
- ✅ **新增文件**:
  - `WJFloatingPanelLayout.swift`: 自定义布局配置
  - `WJFloatingPanelContentViewController.swift`: 内容视图控制器
- ✅ **移除复杂逻辑**: 删除自定义滑动动画代码
- ✅ **代码简化**: 利用 FloatingPanel 的成熟功能

#### 📱 用户体验改进
- ✅ **更自然的交互**: 符合用户直觉的滑动行为
- ✅ **更流畅的动画**: 专业级弹性动画效果
- ✅ **更智能的响应**: 自动处理各种滑动场景
- ✅ **更稳定的性能**: 成熟库保证稳定性

#### 📸 拍照功能增强 ⭐ **最新更新**
- ✅ **新增拍照完成回调**: `onCameraImageCaptured((UIImage) -> Void)?`
- ✅ **直接返回UIImage**: 拍照完成后立即获得图片对象，无需转换
- ✅ **智能行为模式**: 
  - 单选模式：拍照后自动关闭选择器
  - 多选模式：拍照后返回选择器，可继续选择
- ✅ **简化开发流程**: 避免PHAsset转换，直接处理UIImage
- ✅ **即时反馈**: 拍照完成立即回调，提升用户体验

### v2.0.0

#### 新增功能
- ✅ **示例图片支持 URL**: 新增 `SampleImageItem` 枚举，支持 `.image(UIImage)` 和 `.url(URL)` 两种类型
- ✅ **单选模式优化**: 
  - 单选模式选择即回调，无需点击完成
  - 标准模式单选自动隐藏完成按钮
  - 滑动面板单选只显示相册选择按钮
- ✅ **自定义导航栏标题**: 标准模式支持外部传入自定义标题
- ✅ **自定义滑动面板高度**: 支持通过 `slidingPanelTopHeightRatio` 配置顶部区域高度比例
- ✅ **权限提示自定义**: 支持自定义权限提示图标、文字和按钮文字
- ✅ **示例图片回调优化**: 
  - `onSampleImageSelected`: 即时选择回调
  - `onSampleImagesCompleted`: 完成时返回所有选中的示例图片

#### Bug 修复
- ✅ 修复多选后全部取消，完成按钮没有置灰的问题
- ✅ 修复滑块滑到最上面时安全距离判断问题
- ✅ 限制滑动面板滑动范围（不能往下滑，最多到安全距离+20px）

#### 改进
- ✅ 完成按钮状态智能管理
- ✅ 滑动面板工具栏根据选择模式自动调整
- ✅ 代码结构优化和文档完善

### v1.0.0

#### 初始版本
- ✅ 双模式交互（滑动面板 + 标准模式）
- ✅ WebP 动图支持
- ✅ 多选/单选功能
- ✅ 相机拍摄
- ✅ 示例图片（仅支持 UIImage）
- ✅ 权限管理
- ✅ Swift Package Manager 支持

---


## 👨‍💻 作者

Meiwenjie

## 🙏 致谢

- [FloatingPanel](https://github.com/SCENEE/FloatingPanel) - 专业级滑动面板 ⭐ **核心依赖**
- [SDWebImage](https://github.com/SDWebImage/SDWebImage) - 图片加载和缓存
- [SnapKit](https://github.com/SnapKit/SnapKit) - 自动布局
- [SDWebImageWebPCoder](https://github.com/SDWebImage/SDWebImageWebPCoder) - WebP 支持

---

如有问题或建议，欢迎提 Issue！

**⭐ 如果这个项目对你有帮助，请给个 Star！**
