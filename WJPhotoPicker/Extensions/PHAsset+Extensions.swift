//
//  PHAsset+Extensions.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import Photos
import UIKit

extension PHAsset {
    
    /// 获取原图
    func getOriginalImage(completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        PHImageManager.default().requestImage(
            for: self,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    /// 获取缩略图
    func getThumbnail(size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(
            for: self,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    /// 获取图片数据
    func getImageData(completion: @escaping (Data?) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImageDataAndOrientation(
            for: self,
            options: options
        ) { data, _, _, _ in
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
    /// 文件大小（字节）
    var fileSize: Int64 {
        let resources = PHAssetResource.assetResources(for: self)
        guard let resource = resources.first,
              let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong else {
            return 0
        }
        return Int64(unsignedInt64)
    }
    
    /// 文件大小（格式化字符串）
    var fileSizeString: String {
        let size = fileSize
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
