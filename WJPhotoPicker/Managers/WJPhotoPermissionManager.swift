//
//  WJPhotoPermissionManager.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import Photos
import UIKit

/// 相册权限管理器
class WJPhotoPermissionManager {
    
    static let shared = WJPhotoPermissionManager()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 检查当前权限状态
    func checkPermission() -> WJPermissionStatus {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        let result = convertStatus(status)
        return result
    }
    
    /// 请求相册权限
    func requestPermission(completion: @escaping (WJPermissionStatus) -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    completion(self.convertStatus(status))
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(self.convertStatus(status))
                }
            }
        }
    }
    
    /// 打开系统设置页面
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
    /// 显示照片选择器（仅限 Limited 权限）
    /// 注意：iOS 系统会在访问照片时自动弹出选择器，这个方法主要用于主动触发
    @available(iOS 14, *)
    func presentLimitedLibraryPicker(from viewController: UIViewController) {
        // 对于 Limited 权限，直接跳转到设置让用户选择完整权限
        // 这比尝试调用可能不存在的私有 API 更安全
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            openSettings()
        }
    }
    
    /// 检查是否应该显示照片选择器提示
    func shouldShowLimitedLibraryPicker() -> Bool {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited
        }
        return false
    }
    
    // MARK: - Private Methods
    
    private func convertStatus(_ status: PHAuthorizationStatus) -> WJPermissionStatus {
        switch status {
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
}
