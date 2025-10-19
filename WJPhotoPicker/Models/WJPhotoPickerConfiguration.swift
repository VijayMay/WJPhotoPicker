//
//  WJPhotoPickerConfiguration.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit

/// 相册选择器配置
struct WJPhotoPickerConfiguration {
    /// 选择器类型
    let type: WJPhotoPickerType
    
    /// WebP 动图 URL
    let animatedImageURL: URL?
    
    /// WebP 动图数据（本地）
    let animatedImageData: Data?
    
    /// 动图占位图
    let animatedImagePlaceholder: UIImage?
    
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
    
    /// 网格列数
    let numberOfColumns: Int
    
    /// 网格间距
    let gridSpacing: CGFloat
    
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
    
    /// 默认配置
    static var `default`: WJPhotoPickerConfiguration {
        return WJPhotoPickerConfiguration(
            type: .standard,
            animatedImageURL: nil,
            animatedImageData: nil,
            animatedImagePlaceholder: UIImage(systemName: "photo"),
            sampleImages: [],
            maxSelectionCount: 9,
            allowsCamera: true,
            allowsMultipleSelection: true,
            numberOfColumns: 3,
            gridSpacing: 2,
            navigationTitle: nil,
            slidingPanelTopHeightRatio: 0.33,
            permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
            permissionMessage: "需要访问您的照片",
            permissionButtonTitle: "前往设置",
            defaultAlbumTitle: "相册",
            emptyAlbumIcon: UIImage(systemName: "photo.on.rectangle"),
            emptyAlbumMessage: "相册中还没有照片\n快去拍摄或添加照片吧",
            emptyAlbumButtonTitle: nil,  // 可选，不显示按钮
            limitedPermissionIcon: UIImage(systemName: "photo.badge.plus"),
            limitedPermissionMessage: "当前仅可访问部分照片，建议开启完整相册权限以获得更好体验",
            limitedPermissionButtonTitle: "前往设置"
        )
    }
}
