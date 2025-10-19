//
//  AppDelegate.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import SDWebImage
import SDWebImageWebPCoder

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 注册 WebP 解码器
        setupWebPSupport()
        
        // 配置图片缓存
        configureImageCache()
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func setupWebPSupport() {
        // 注册 WebP 解码器
        let webPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(webPCoder)
    }
    
    private func configureImageCache() {
        // 配置内存缓存（100MB）
        SDImageCache.shared.config.maxMemoryCost = 100 * 1024 * 1024
        
        // 配置磁盘缓存（200MB）
        SDImageCache.shared.config.maxDiskSize = 200 * 1024 * 1024
        
        // 缓存过期时间（7天）
        SDImageCache.shared.config.maxDiskAge = 7 * 24 * 60 * 60
    }
}
