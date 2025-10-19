//
//  WJPhotoAlbum.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import Photos

/// 相册模型
struct WJPhotoAlbum {
    /// 相册标题
    let title: String
    
    /// 系统相册集合
    let assetCollection: PHAssetCollection
    
    /// 照片数量
    let count: Int
    
    /// 缩略图
    var thumbnail: UIImage?
    
    /// 相册类型
    var albumType: AlbumType {
        switch assetCollection.assetCollectionSubtype {
        case .smartAlbumUserLibrary:
            return .recents
        case .smartAlbumFavorites:
            return .favorites
        case .albumRegular:
            return .userAlbums
        default:
            return .smartAlbums
        }
    }
    
    // MARK: - AlbumType
    
    enum AlbumType {
        case recents        // 最近项目
        case favorites      // 个人收藏
        case userAlbums     // 用户相册
        case smartAlbums    // 智能相册
    }
}

// MARK: - Equatable

extension WJPhotoAlbum: Equatable {
    static func == (lhs: WJPhotoAlbum, rhs: WJPhotoAlbum) -> Bool {
        return lhs.assetCollection.localIdentifier == rhs.assetCollection.localIdentifier
    }
}
