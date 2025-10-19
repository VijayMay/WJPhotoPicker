//
//  URL+Extensions.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import Foundation

extension URL {
    
    /// 检查URL是否指向 WebP 文件
    var isWebPURL: Bool {
        return pathExtension.lowercased() == "webp"
    }
    
    /// 检查URL是否指向图片文件
    var isImageURL: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "webp", "heic", "heif", "bmp", "tiff"]
        return imageExtensions.contains(pathExtension.lowercased())
    }
}
