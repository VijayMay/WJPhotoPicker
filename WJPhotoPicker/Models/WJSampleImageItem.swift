//
//  WJSampleImageItem.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit

/// 示例图片项（支持 UIImage 和 URL）
enum WJSampleImageItem {
    case image(UIImage)
    case url(URL)
    
    /// 获取占位图
    var placeholderImage: UIImage? {
        return UIImage(systemName: "photo.fill")?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
    }
}
