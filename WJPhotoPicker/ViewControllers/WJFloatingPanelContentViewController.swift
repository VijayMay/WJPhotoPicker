//
//  WJFloatingPanelContentViewController.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/19.
//

import UIKit
import FloatingPanel
import SnapKit

/// FloatingPanel内容视图控制器
class WJFloatingPanelContentViewController: UIViewController {
    
    // MARK: - Properties
    
    private let configuration: WJPhotoPickerConfiguration
    
    // 回调
    var onDismiss: (() -> Void)?
    var onPositionChanged: ((CGFloat) -> Void)?  // 位置变化回调，用于模拟模态视图隐藏
    
    // 滚动视图引用 - 用于滚动联动
    weak var trackingScrollView: UIScrollView?
    
    // UI组件
    private let toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
    
    // 内容视图
    private let contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Initialization
    
    init(configuration: WJPhotoPickerConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Public Methods
    
    /// 更新背景色
    func updateBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
        // contentContainerView 保持透明，避免遮挡权限引导视图
        // toolbarView 保持透明，显示父视图的背景色
    }
    
    
    // MARK: - Setup
    
    private func setupUI() {
        // 背景色将通过 updateBackgroundColor 方法设置
        view.backgroundColor = .systemBackground
        
        // 添加圆角
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // 添加阴影
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        
        view.addSubview(toolbarView)
        view.addSubview(contentContainerView)
        
        // 只添加相册选择器
        toolbarView.addSubview(albumSelectorButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        toolbarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        // 相册选择器居中
        albumSelectorButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentContainerView.snp.makeConstraints { make in
            make.top.equalTo(toolbarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    /// 获取内容容器视图，用于添加CollectionView等内容
    var contentView: UIView {
        return contentContainerView
    }
    
    /// 获取工具栏的高度（包括顶部偏移）
    var toolbarHeight: CGFloat {
        return albumSelectorButton.isHidden ? 34 : (8 + 44) // 隐藏时34px间距，显示时为52px
    }
    
    /// 更新工具栏高度（用于动画）
    func updateToolbarHeight(animated: Bool = true) {
        let newHeight: CGFloat = albumSelectorButton.isHidden ? 0 : 44
        let topOffset: CGFloat = albumSelectorButton.isHidden ? 34 : 8
        
        toolbarView.snp.updateConstraints { make in
            make.height.equalTo(newHeight)
            make.top.equalToSuperview().offset(topOffset)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
}

// MARK: - FloatingPanelControllerDelegate

extension WJFloatingPanelContentViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        let layout = WJFloatingPanelLayout()
        layout.topHeightRatio = configuration.slidingPanelTopHeightRatio
        return layout
    }
    
    /// ⭐ 关键方法：返回需要跟踪的滚动视图，实现滚动联动
    func floatingPanel(_ vc: FloatingPanelController, contentScrollViewFor state: FloatingPanelState) -> UIScrollView? {
        // 始终返回滚动视图，让FloatingPanel自动处理滚动联动
        // FloatingPanel会智能地处理以下情况：
        // 1. half状态 + 向上滚动 → 面板展开到full
        // 2. full状态 + 滚动内容 → 正常滚动CollectionView
        // 3. full状态 + 滚动到顶部继续下拉 → 面板收缩到half
        return trackingScrollView
    }
    
    /// ⭐⭐⭐ 关键方法：控制何时允许拖拽面板（简化版本）
    func floatingPanel(_ vc: FloatingPanelController, shouldBeginDraggingWith gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        // 简化逻辑：始终允许FloatingPanel处理手势
        // 让FloatingPanel和scrollView自动协调
        return true
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        // 开始拖拽时的处理
    }
    
    func floatingPanelDidChangeState(_ vc: FloatingPanelController) {
        // 状态变化时的处理
        // 不再自动移除面板，用户只能通过返回按钮关闭
    }
    
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
        // 面板移动时的处理 - 用于模拟模态视图隐藏效果
        let currentPosition = vc.surfaceLocation.y
        let screenHeight = vc.view.bounds.height
        
        // 获取half状态的位置作为基准
        let layout = WJFloatingPanelLayout()
        layout.topHeightRatio = configuration.slidingPanelTopHeightRatio
        let halfPosition = screenHeight * layout.topHeightRatio
        
        // 计算相对于half状态的进度
        // 0.0 = half位置或更高, 1.0 = 屏幕底部
        let relativePosition: CGFloat
        if currentPosition <= halfPosition {
            relativePosition = 0.0
        } else {
            relativePosition = (currentPosition - halfPosition) / (screenHeight - halfPosition)
        }
        
        // 调用位置变化回调
        onPositionChanged?(relativePosition)
    }
    
    private func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: FloatingPanelState) {
        // 结束拖拽时的处理
        // 不再自动移除面板，用户只能通过返回按钮关闭
    }
    
    func floatingPanelWillRemove(_ vc: FloatingPanelController) {
        // 面板即将被移除时触发关闭回调
        onDismiss?()
    }
}
