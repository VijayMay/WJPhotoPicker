//
//  WJPhotoPickerConfiguration.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit

/// 相册选择器配置
struct WJPhotoPickerConfiguration {
    // MARK: - 主题配置
    
    /// 主题配置
    let theme: WJPhotoPickerTheme
    
    // MARK: - 导航栏配置
    
    /// 是否显示返回按钮
    let showBackButton: Bool
    
    /// 返回按钮图标 (默认 chevron.left)
    let backButtonIcon: UIImage?
    
    // MARK: - 选择器配置
    
    /// 选择器类型
    let type: WJPhotoPickerType
    
    // MARK: - 预览区域配置 (仅滑块模式)
    
    /// 媒体类型
    enum PreviewMediaType {
        case webp
        case mp4
    }
    
    /// 预览媒体类型
    let previewMediaType: PreviewMediaType
    
    /// WebP 动图 URL
    let animatedImageURL: URL?
    
    /// WebP 动图数据（本地）
    let animatedImageData: Data?
    
    /// MP4 视频 URL
    let videoURL: URL?
    
    /// 预览媒体占位图
    let previewPlaceholder: UIImage?
    
    /// 自动播放 (默认 true)
    let previewAutoPlay: Bool
    
    /// 循环播放 (默认 true)
    let previewLoopPlay: Bool
    
    /// 兼容旧版本
    @available(*, deprecated, message: "使用 previewPlaceholder 代替")
    var animatedImagePlaceholder: UIImage? {
        return previewPlaceholder
    }
    
    /// 示例图片列表（支持 UIImage 和 URL）
    let sampleImages: [WJSampleImageItem]
    
    /// 兼容旧版本：从 UIImage 数组创建
    static func with(images: [UIImage]) -> [WJSampleImageItem] {
        return images.map { .image($0) }
    }
    
    /// 从 URL 数组创建
    static func with(urls: [URL]) -> [WJSampleImageItem] {
        return urls.map { .url($0) }
    }
    
    /// 最大选择数量
    let maxSelectionCount: Int
    
    /// 是否允许使用相机
    let allowsCamera: Bool
    
    /// 是否支持多选
    let allowsMultipleSelection: Bool
    
    /// 网格列数 (已废弃，使用 gridColumns)
    @available(*, deprecated, message: "使用 gridColumns 代替")
    let numberOfColumns: Int
    
    /// 网格间距
    let gridSpacing: CGFloat
    
    /// 网格列数 (nil = 自动: 375+ 为 4列, <375 为 3列)
    let gridColumns: Int?
    
    /// 标准模式的导航栏标题（仅标准模式有效）
    let navigationTitle: String?
    
    /// 滑动面板顶部区域高度比例（0.0-1.0，默认 0.33 即 1/3）
    let slidingPanelTopHeightRatio: CGFloat
    
    /// 权限提示图标
    let permissionIcon: UIImage?
    
    /// 权限提示文字
    let permissionMessage: String?
    
    /// 权限设置按钮文字
    let permissionButtonTitle: String?
    
    /// 默认相册名称（当没有相册或权限受限时显示）
    let defaultAlbumTitle: String
    
    /// 空相册提示图标（有权限但相册为空时）
    let emptyAlbumIcon: UIImage?
    
    /// 空相册提示文字（有权限但相册为空时）
    let emptyAlbumMessage: String?
    
    /// 空相册按钮文字（有权限但相册为空时，例如"去添加"）
    let emptyAlbumButtonTitle: String?
    
    /// 限制权限提示图标（Limited 权限且无照片时）
    let limitedPermissionIcon: UIImage?
    
    /// 限制权限提示文字（Limited 权限且无照片时）
    let limitedPermissionMessage: String?
    
    /// 限制权限按钮文字（Limited 权限且无照片时）
    let limitedPermissionButtonTitle: String?
    
    // MARK: - Grid Item 文案配置
    
    /// 相机 item 标题
    let cameraTitle: String
    
    /// Gallery item 标题
    let galleryTitle: String
    
    /// 示例图片 item 标题
    let sampleImageTitle: String
    
    // MARK: - 广告配置
    
    /// 是否显示广告（根据VIP状态）
    let showAdvertisement: Bool
    
    /// 自定义广告视图（如果为 nil 则使用默认视图）
    let customAdvertisementView: UIView?
    
    /// 广告点击回调
    var onAdvertisementTapped: (() -> Void)?
    
    /// 默认配置
    static var `default`: WJPhotoPickerConfiguration {
        return WJPhotoPickerConfiguration(
            theme: .default,
            showBackButton: true,
            backButtonIcon: UIImage(systemName: "chevron.left"),
            type: .standard,
            previewMediaType: .webp,
            animatedImageURL: nil,
            animatedImageData: nil,
            videoURL: nil,
            previewPlaceholder: UIImage(systemName: "photo"),
            previewAutoPlay: true,
            previewLoopPlay: true,
            sampleImages: [],
            maxSelectionCount: 9,
            allowsCamera: true,
            allowsMultipleSelection: true,
            numberOfColumns: 3,
            gridSpacing: 5,
            gridColumns: nil,
            navigationTitle: nil,
            slidingPanelTopHeightRatio: 0.33,
            permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
            permissionMessage: "需要访问您的照片",
            permissionButtonTitle: "前往设置",
            defaultAlbumTitle: "All Picture",
            emptyAlbumIcon: UIImage(systemName: "photo.on.rectangle"),
            emptyAlbumMessage: "相册中还没有照片\n快去拍摄或添加照片吧",
            emptyAlbumButtonTitle: nil,
            limitedPermissionIcon: UIImage(systemName: "photo.badge.plus"),
            limitedPermissionMessage: "当前仅可访问部分照片，建议开启完整相册权限以获得更好体验",
            limitedPermissionButtonTitle: "前往设置",
            cameraTitle: "Camera",
            galleryTitle: "Gallery",
            sampleImageTitle: "Sample",
            showAdvertisement: false,
            customAdvertisementView: nil,
            onAdvertisementTapped: nil
        )
    }
}
