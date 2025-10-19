//
//  WJPhotoAlbumManager.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import Photos
import UIKit

/// 相册数据管理器
class WJPhotoAlbumManager: NSObject {
    
    static let shared = WJPhotoAlbumManager()
    
    private let imageManager = PHCachingImageManager()
    private var changeObserver: ((PHChange) -> Void)?
    
    private override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// 获取所有相册列表
    func fetchAlbumList() -> [WJPhotoAlbum] {
        var albums: [WJPhotoAlbum] = []
        
        // 1. 最近项目（优先显示）
        let recentOptions = PHFetchOptions()
        recentOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let recentAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: nil
        )
        
        recentAlbums.enumerateObjects { collection, _, _ in
            let count = self.fetchPhotosCount(from: collection)
            if count > 0 {
                albums.append(WJPhotoAlbum(
                    title: collection.localizedTitle ?? "最近项目",
                    assetCollection: collection,
                    count: count
                ))
            }
        }
        
        // 2. 个人收藏
        let favoriteAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumFavorites,
            options: nil
        )
        
        favoriteAlbums.enumerateObjects { collection, _, _ in
            let count = self.fetchPhotosCount(from: collection)
            if count > 0 {
                albums.append(WJPhotoAlbum(
                    title: collection.localizedTitle ?? "个人收藏",
                    assetCollection: collection,
                    count: count
                ))
            }
        }
        
        // 3. 用户创建的相册
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        
        userAlbums.enumerateObjects { collection, _, _ in
            let count = self.fetchPhotosCount(from: collection)
            if count > 0 {
                albums.append(WJPhotoAlbum(
                    title: collection.localizedTitle ?? "未命名相册",
                    assetCollection: collection,
                    count: count
                ))
            }
        }
        
        // 4. 其他智能相册
        let smartAlbumSubtypes: [PHAssetCollectionSubtype] = [
            .smartAlbumScreenshots,
            .smartAlbumSelfPortraits,
            .smartAlbumPanoramas,
            .smartAlbumVideos,
            .smartAlbumLivePhotos
        ]
        
        for subtype in smartAlbumSubtypes {
            let smartAlbums = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: subtype,
                options: nil
            )
            
            smartAlbums.enumerateObjects { collection, _, _ in
                let count = self.fetchPhotosCount(from: collection)
                if count > 0 {
                    albums.append(WJPhotoAlbum(
                        title: collection.localizedTitle ?? "智能相册",
                        assetCollection: collection,
                        count: count
                    ))
                }
            }
        }
        
        return albums
    }
    
    /// 获取最近照片
    func fetchRecentPhotos(limit: Int = 0, completion: @escaping ([PHAsset]) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        // limit为0表示不限制，加载全部照片
        if limit > 0 {
            options.fetchLimit = limit
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let assets = PHAsset.fetchAssets(with: .image, options: options)
            var results: [PHAsset] = []
            
            assets.enumerateObjects { asset, _, _ in
                results.append(asset)
            }
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    /// 从指定相册获取照片
    func fetchPhotos(from album: WJPhotoAlbum, completion: @escaping ([PHAsset]) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let assets = PHAsset.fetchAssets(in: album.assetCollection, options: options)
            var results: [PHAsset] = []
            
            assets.enumerateObjects { asset, _, _ in
                results.append(asset)
            }
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    /// 加载缩略图
    func loadThumbnail(for asset: PHAsset,
                       targetSize: CGSize,
                       completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    /// 加载原图
    func loadFullImage(for asset: PHAsset,
                       completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    /// 监听相册变化
    func observePhotoLibraryChanges(_ observer: @escaping (PHChange) -> Void) {
        self.changeObserver = observer
    }
    
    // MARK: - Private Methods
    
    private func fetchPhotosCount(from collection: PHAssetCollection) -> Int {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let assets = PHAsset.fetchAssets(in: collection, options: options)
        return assets.count
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension WJPhotoAlbumManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.changeObserver?(changeInstance)
        }
    }
}
