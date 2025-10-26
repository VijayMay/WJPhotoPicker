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
            // ✅ full 状态: 距离导航栏底部 0px
            .full: FloatingPanelLayoutAnchor(
                absoluteInset: 0.0,
                edge: .top,
                referenceGuide: .safeArea
            ),
            
            // ✅ half 状态: 预览区域下方 18px
            // 计算方式: 11px(top) + 199px(preview @ 375) + 18px(spacing)
            .half: FloatingPanelLayoutAnchor(
                absoluteInset: calculateHalfPosition(),
                edge: .top,
                referenceGuide: .safeArea
            ),
        ]
    }
    
    /// 计算 half 状态位置
    private func calculateHalfPosition() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let baseWidth: CGFloat = 375
        let baseHeight: CGFloat = 199
        let previewHeight = (baseHeight / baseWidth) * screenWidth
        
        let topMargin: CGFloat = 11
        let bottomMargin: CGFloat = 18
        
        return topMargin + previewHeight + bottomMargin
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0 // 不显示背景遮罩
    }
    
    func shouldRemove(interactionVelocityThreshold: CGFloat) -> Bool {
        return false // 禁用向下滑动关闭，最低只能到 half 状态
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
