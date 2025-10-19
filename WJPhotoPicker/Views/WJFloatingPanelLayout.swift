//
//  WJFloatingPanelLayout.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/19.
//

import UIKit
import FloatingPanel

/// 自定义FloatingPanel布局
class WJFloatingPanelLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    
    /// 顶部区域高度比例
    var topHeightRatio: CGFloat = 0.33
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 20.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: topHeightRatio, edge: .top, referenceGuide: .superview),
            // 移除tip状态，避免吸附行为
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0 // 不显示背景遮罩
    }
    
    func shouldRemove(interactionVelocityThreshold: CGFloat) -> Bool {
        return true // 允许快速向下滑动关闭
    }
    
    /// 自定义移除速度阈值 (降低阈值使其更容易触发)
    func removalVelocityThreshold() -> CGFloat {
        return 100.0 // 大幅降低到100
    }
    
    /// 移除进度阈值 - 滑动多远就移除
    func removalProgressThreshold() -> CGFloat {
        return 0.25 // 滑动25%就可以移除
    }
    
    /// 禁用状态吸附行为
    func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        return false // 禁用橡皮筋效果，避免吸附
    }
    
    /// ⭐ 优化滚动联动的动画效果
    func interactionAnimator(_ fpc: FloatingPanelController, to targetState: FloatingPanelState, with velocity: CGVector) -> UIViewPropertyAnimator {
        // 使用弹性动画，让状态切换更自然
        let timing = UISpringTimingParameters(
            dampingRatio: 0.8,  // 适度的阻尼，既有弹性又不过度
            initialVelocity: velocity  // 保持用户的滑动速度
        )
        return UIViewPropertyAnimator(duration: 0.3, timingParameters: timing)
    }
    
}
