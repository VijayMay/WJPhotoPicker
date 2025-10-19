//
//  WJSlidingPanelView.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import SnapKit

// MARK: - UIColor Extension for Interpolation

extension UIColor {
    static func interpolate(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        let progress = max(0, min(1, progress))
        
        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
        
        from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let red = fromRed + (toRed - fromRed) * progress
        let green = fromGreen + (toGreen - fromGreen) * progress
        let blue = fromBlue + (toBlue - fromBlue) * progress
        let alpha = fromAlpha + (toAlpha - fromAlpha) * progress
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

/// 可滑动面板视图
class WJSlidingPanelView: UIView {
    
    // MARK: - Types
    
    enum PanelState {
        case collapsed    // 折叠状态
        case partial      // 部分展开（默认）
        case expanded     // 完全展开
    }
    
    // MARK: - Properties
    
    private(set) var currentState: PanelState = .partial
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    private let animationDuration: TimeInterval = 0.3
    private let springDamping: CGFloat = 0.8
    
    var onStateChanged: ((PanelState) -> Void)?
    var onDismiss: (() -> Void)?  // 向下滑动取消的回调
    var onSlideProgress: ((CGFloat) -> Void)?  // 滑动进度回调，用于动态调整动图透明度
    
    // 滚动联动相关
    private var lastContentOffset: CGFloat = 0
    private var isScrollLinkageEnabled = true  // 是否启用滚动联动
    
    /// 顶部区域高度比例（从外部传入）
    var topHeightRatio: CGFloat = 0.33
    
    // 状态对应的位置
    private var collapsedOffset: CGFloat {
        // 不允许折叠，最小位置就是 partial
        return partialOffset
    }
    
    private var partialOffset: CGFloat {
        // 获取父视图的顶部区域高度（动图区域）
        if let superview = superview {
            return superview.bounds.height * topHeightRatio
        }
        return bounds.height * 0.4
    }
    
    private var expandedOffset: CGFloat {
        return 0
    }
    
    private var dismissThreshold: CGFloat {
        // 向下滑动超过 partial 位置 150px 时触发取消
        return partialOffset + 150
    }
    
    private var expandedOffsetOriginal: CGFloat {
        // 最大展开到安全距离下面 20px
        if #available(iOS 11.0, *) {
            // 从父视图或窗口获取正确的安全距离
            let topInset = window?.safeAreaInsets.top ?? superview?.safeAreaInsets.top ?? 0
            return topInset + 20
        } else {
            return 20
        }
    }
    
    // MARK: - UI Components
    
    // 滑动手柄
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // 顶部工具栏（多选模式）
    private let toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("完成", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    let albumSelectorButton: WJAlbumSelectorButton = {
        let button = WJAlbumSelectorButton()
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGesture()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 8
        
        addSubview(contentView)
        addSubview(handleBar)
        addSubview(toolbarView)
        
        toolbarView.addSubview(cancelButton)
        toolbarView.addSubview(albumSelectorButton)
        toolbarView.addSubview(doneButton)
        
        handleBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        
        toolbarView.snp.makeConstraints { make in
            make.top.equalTo(handleBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        albumSelectorButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(toolbarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    /// 配置工具栏显示模式
    func configureToolbar(isMultipleSelection: Bool) {
        if isMultipleSelection {
            // 多选模式：显示取消、相册选择、完成
            cancelButton.isHidden = false
            doneButton.isHidden = false
            albumSelectorButton.isHidden = false
        } else {
            // 单选模式：只显示相册选择按钮
            cancelButton.isHidden = true
            doneButton.isHidden = true
            albumSelectorButton.isHidden = false
        }
        updateToolbarHeight()
    }
    
    /// 更新工具栏高度（根据相册选择器的可见性）
    /// - Parameter animated: 是否使用动画，默认 true
    func updateToolbarHeight(animated: Bool = true) {
        let shouldShowToolbar = !albumSelectorButton.isHidden || !cancelButton.isHidden || !doneButton.isHidden
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.toolbarView.snp.updateConstraints { make in
                    make.height.equalTo(shouldShowToolbar ? 44 : 0)
                }
                self.layoutIfNeeded()
            }
        } else {
            self.toolbarView.snp.updateConstraints { make in
                make.height.equalTo(shouldShowToolbar ? 44 : 0)
            }
        }
    }
    
    private func setupGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Public Methods
    
    func setState(_ state: PanelState, animated: Bool = true) {
        currentState = state
        
        let offset: CGFloat
        switch state {
        case .collapsed:
            offset = collapsedOffset
        case .partial:
            offset = partialOffset
        case .expanded:
            offset = expandedOffset
        }
        
        updatePosition(offset: offset, animated: animated)
        onStateChanged?(state)
    }
    
    // MARK: - Private Methods
    
    private func updatePosition(offset: CGFloat, animated: Bool) {
        self.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(offset)
        }
        
        if animated {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                usingSpringWithDamping: springDamping,
                initialSpringVelocity: 0,
                options: .curveEaseInOut,
                animations: {
                    self.superview?.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            superview?.layoutIfNeeded()
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        let velocity = gesture.velocity(in: superview)
        
        // 获取当前 top offset
        let currentOffset = self.frame.origin.y
        
        switch gesture.state {
        case .changed:
            let newConstant = currentOffset + translation.y
            let minOffset = expandedOffset  // 最小（最上面）
            let maxOffset = dismissThreshold   // 最大（允许向下滑动到取消阈值）
            
            // 限制滑动范围：从 expanded 到 dismissThreshold
            let constrainedOffset = max(minOffset, min(maxOffset, newConstant))
            
            self.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(constrainedOffset)
            }
            gesture.setTranslation(.zero, in: superview)
            
            // 计算滑动进度并回调（用于动态调整动图透明度）
            let progress = calculateSlideProgress(currentOffset: constrainedOffset)
            onSlideProgress?(progress)
            
            // 更新滑动手柄和内容的视觉反馈
            updateVisualFeedback(for: constrainedOffset, progress: progress)
            
        case .ended:
            let currentOffset = self.frame.origin.y
            
            // 检查是否达到取消阈值
            if currentOffset >= partialOffset + 100 || velocity.y > 800 {
                // 向下滑动超过阈值或快速向下滑动 → 取消
                onDismiss?()
                return
            }
            
            // 根据速度和位置决定最终状态（只有 expanded 和 partial 两种状态）
            let targetState: PanelState
            
            if velocity.y < -500 {
                // 快速向上滑动 → 展开
                targetState = .expanded
            } else if velocity.y > 500 {
                // 快速向下滑动 → 部分展开
                targetState = .partial
            } else {
                // 根据位置判断
                let threshold = (expandedOffset + partialOffset) / 2
                
                if currentOffset < threshold {
                    targetState = .expanded
                } else {
                    targetState = .partial
                }
            }
            
            setState(targetState, animated: true)
            
            // 滑动结束时重置进度和视觉状态
            onSlideProgress?(0.0)
            resetVisualFeedback()
            
        default:
            break
        }
    }
    
    /// 计算滑动进度（0.0 = 正常，1.0 = 即将取消）
    private func calculateSlideProgress(currentOffset: CGFloat) -> CGFloat {
        // 当滑动超过 partial 位置时开始计算进度
        if currentOffset <= partialOffset {
            return 0.0  // 正常状态
        }
        
        // 计算从 partial 到取消阈值的进度
        let slideDistance = currentOffset - partialOffset
        let maxSlideDistance: CGFloat = 100  // 滑动100px后开始明显效果
        
        return min(1.0, slideDistance / maxSlideDistance)
    }
    
    /// 更新滑动过程中的视觉反馈
    private func updateVisualFeedback(for currentOffset: CGFloat, progress: CGFloat) {
        // 1. 更新滑动手柄的视觉状态
        updateHandleBarAppearance(progress: progress)
        
        // 2. 更新内容区域的视觉效果
        updateContentAppearance(for: currentOffset, progress: progress)
        
        // 3. 更新工具栏的透明度
        updateToolbarAppearance(progress: progress)
    }
    
    /// 更新滑动手柄的外观
    private func updateHandleBarAppearance(progress: CGFloat) {
        let baseColor = UIColor.systemGray3
        let activeColor = UIColor.systemGray2
        
        // 根据进度调整颜色和大小
        let colorProgress = min(1.0, progress * 2) // 让颜色变化更明显
        let color = UIColor.interpolate(from: baseColor, to: activeColor, progress: colorProgress)
        
        // 滑动时手柄略微变宽，增加视觉反馈
        let widthMultiplier = 1.0 + (progress * 0.3) // 最多增加30%宽度
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.handleBar.backgroundColor = color
            self.handleBar.transform = CGAffineTransform(scaleX: widthMultiplier, y: 1.0)
        }, completion: nil)
    }
    
    /// 更新内容区域的外观
    private func updateContentAppearance(for currentOffset: CGFloat, progress: CGFloat) {
        // 当向下滑动时，内容区域略微缩放和变暗
        let scale = 1.0 - (progress * 0.02) // 轻微缩放
        let alpha = 1.0 - (progress * 0.1)  // 轻微变暗
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.contentView.alpha = alpha
        }, completion: nil)
    }
    
    /// 更新工具栏的外观
    private func updateToolbarAppearance(progress: CGFloat) {
        let alpha = 1.0 - (progress * 0.3) // 工具栏逐渐变淡
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.toolbarView.alpha = alpha
        }, completion: nil)
    }
    
    /// 重置所有视觉反馈到初始状态
    private func resetVisualFeedback() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
            // 重置滑动手柄
            self.handleBar.backgroundColor = .systemGray3
            self.handleBar.transform = .identity
            
            // 重置内容区域
            self.contentView.transform = .identity
            self.contentView.alpha = 1.0
            
            // 重置工具栏
            self.toolbarView.alpha = 1.0
        }, completion: nil)
    }
    
    // MARK: - Scroll Linkage
    
    /// 处理内容滚动联动
    /// - Parameters:
    ///   - scrollView: 滚动的视图
    ///   - velocity: 滚动速度
    func handleContentScroll(_ scrollView: UIScrollView, velocity: CGPoint) {
        guard isScrollLinkageEnabled else { return }
        
        let currentOffset = scrollView.contentOffset.y
        let deltaY = currentOffset - lastContentOffset
        lastContentOffset = currentOffset
        
        // 获取内容高度和可视区域高度
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.bounds.height
        let hasScrollableContent = contentHeight > visibleHeight
        
        // 只有当内容可滚动时才启用联动
        guard hasScrollableContent else { return }
        
        // 向上滚动联动：当用户向上滚动且有一定速度时展开面板
        if deltaY > 5 && velocity.y > 50 && currentState == .partial {
            // 向上滚动且速度足够：展开面板，增大可视区域
            setState(.expanded, animated: true)
        }
        // 向下滚动联动：当滚动到顶部附近且向下滚动时收起面板
        else if currentOffset <= 20 && deltaY < -5 && velocity.y < -50 && currentState == .expanded {
            // 接近顶部且向下滚动：收起面板
            setState(.partial, animated: true)
        }
    }
    
    /// 启用或禁用滚动联动
    func setScrollLinkageEnabled(_ enabled: Bool) {
        isScrollLinkageEnabled = enabled
    }
    
    // MARK: - Layout
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview != nil else { return }
        
        self.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(partialOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension WJSlidingPanelView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                          shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
