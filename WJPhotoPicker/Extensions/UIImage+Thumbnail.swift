//
//  UIImage+Thumbnail.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit

extension UIImage {
    
    /// 生成缩略图
    func thumbnail(size: CGSize) -> UIImage? {
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    /// 按比例缩放
    func scaled(to size: CGSize, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage? {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        
        let aspectRatio: CGFloat
        switch contentMode {
        case .scaleAspectFit:
            aspectRatio = min(aspectWidth, aspectHeight)
        case .scaleAspectFill:
            aspectRatio = max(aspectWidth, aspectHeight)
        default:
            aspectRatio = 1.0
        }
        
        let scaledSize = CGSize(
            width: self.size.width * aspectRatio,
            height: self.size.height * aspectRatio
        )
        
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
    
    /// 压缩图片
    func compressed(quality: CGFloat = 0.8) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
}
