//
//  WJPhotoPickerService.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import Photos
import UIKit

/// 相册选择器业务逻辑服务
class WJPhotoPickerService {
    
    static let shared = WJPhotoPickerService()
    
    private let photoManager = WJPhotoAlbumManager.shared
    private let permissionManager = WJPhotoPermissionManager.shared
    
    private init() {}
    
    // MARK: - Permission
    
    /// 检查权限
    func checkPermission() -> WJPermissionStatus {
        return permissionManager.checkPermission()
    }
    
    /// 请求权限
    func requestPermission(completion: @escaping (WJPermissionStatus) -> Void) {
        permissionManager.requestPermission(completion: completion)
    }
    
    /// 打开设置
    func openSettings() {
        permissionManager.openSettings()
    }
    
    // MARK: - Albums
    
    /// 获取相册列表
    func fetchAlbums(completion: @escaping ([WJPhotoAlbum]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let albums = self.photoManager.fetchAlbumList()
            DispatchQueue.main.async {
                completion(albums)
            }
        }
    }
    
    // MARK: - Photos
    
    /// 获取最近照片
    func fetchRecentPhotos(limit: Int = 0, completion: @escaping ([PHAsset]) -> Void) {
        photoManager.fetchRecentPhotos(limit: limit, completion: completion)
    }
    
    /// 从指定相册获取照片
    func fetchPhotos(from album: WJPhotoAlbum?, completion: @escaping ([PHAsset]) -> Void) {
        if let album = album {
            photoManager.fetchPhotos(from: album, completion: completion)
        } else {
            fetchRecentPhotos(completion: completion)
        }
    }
    
    // MARK: - Image Loading
    
    /// 加载缩略图
    func loadThumbnail(for asset: PHAsset,
                       targetSize: CGSize,
                       completion: @escaping (UIImage?) -> Void) {
        photoManager.loadThumbnail(for: asset, targetSize: targetSize, completion: completion)
    }
    
    /// 加载原图
    func loadFullImage(for asset: PHAsset,
                       completion: @escaping (UIImage?) -> Void) {
        photoManager.loadFullImage(for: asset, completion: completion)
    }
    
    // MARK: - Change Observer
    
    /// 监听相册变化
    func observePhotoLibraryChanges(_ observer: @escaping (PHChange) -> Void) {
        photoManager.observePhotoLibraryChanges(observer)
    }
}
