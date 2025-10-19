//
//  WJPermissionStatus.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import Foundation

/// 相册权限状态
enum WJPermissionStatus {
    case authorized      // 已授权
    case limited         // 限制访问（iOS 14+）
    case denied          // 已拒绝
    case notDetermined   // 未确定
}
