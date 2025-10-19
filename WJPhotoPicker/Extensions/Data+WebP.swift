//
//  Data+WebP.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import Foundation

extension Data {
    
    /// 检查是否为 WebP 格式
    var isWebP: Bool {
        guard count >= 12 else { return false }
        
        let riffHeader = self[0..<4]
        let webpHeader = self[8..<12]
        
        return riffHeader.elementsEqual([0x52, 0x49, 0x46, 0x46]) &&  // "RIFF"
               webpHeader.elementsEqual([0x57, 0x45, 0x42, 0x50])     // "WEBP"
    }
    
    /// 检查是否为动画 WebP
    var isAnimatedWebP: Bool {
        guard isWebP, count >= 16 else { return false }
        
        // 检查是否包含 "ANIM" chunk
        let dataString = String(data: self, encoding: .ascii) ?? ""
        return dataString.contains("ANIM")
    }
}
