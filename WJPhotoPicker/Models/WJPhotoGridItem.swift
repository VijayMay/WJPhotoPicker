//
//  WJPhotoGridItem.swift
//  MFPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import Photos
import UIKit

/// 照片网格项类型
enum WJPhotoGridItem: Equatable {
    case camera                                    // 相机
    case gallery                                   // Gallery（触发系统权限选择器）
    case sampleImage(WJSampleImageItem, index: Int)  // 示例图片
    case photo(PHAsset)                           // 系统照片
    
    /// 唯一标识符，用于选中状态管理
    var identifier: String {
        switch self {
        case .camera:
            return "camera"
        case .gallery:
            return "gallery"
        case .sampleImage(_, let index):
            return "sample_\(index)"
        case .photo(let asset):
            return asset.localIdentifier
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: WJPhotoGridItem, rhs: WJPhotoGridItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
