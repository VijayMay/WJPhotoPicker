//
//  WJAdvertisementView.swift
//  WJPhotoPicker
//
//  Created by Cascade on 2025/10/26.
//

import UIKit
import SnapKit

/// 广告视图 - 全局常驻组件，支持自定义视图
class WJAdvertisementView: UIView {
    
    // MARK: - Properties
    
    /// 固定高度
    static let height: CGFloat = 88
    
    /// 是否显示（根据VIP状态）
    var isVisible: Bool = true {
        didSet {
            isHidden = !isVisible
        }
    }
    
    /// 点击回调
    var onAdTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let contentView: UIView
    
    // MARK: - Initialization
    
    /// 使用默认视图初始化
    convenience init() {
        self.init(customView: nil)
    }
    
    /// 使用自定义视图初始化
    /// - Parameter customView: 自定义广告视图，如果为 nil 则使用默认视图
    init(customView: UIView?) {
        if let customView = customView {
            self.contentView = customView
        } else {
            self.contentView = WJAdvertisementView.createDefaultView()
        }
        
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        onAdTapped?()
    }
    
    // MARK: - Default View
    
    /// 创建默认广告视图（PicMuse PRO 样式）
    private static func createDefaultView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
        
        // Icon Label
        let iconLabel = UILabel()
        iconLabel.text = "Join"
        iconLabel.font = .systemFont(ofSize: 16, weight: .medium)
        iconLabel.textColor = .white
        
        // Title Label with Gradient
        let titleLabel = UILabel()
        titleLabel.text = "PicMuse"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#00D4FF")
        
        let proLabel = UILabel()
        proLabel.text = "PRO"
        proLabel.font = .systemFont(ofSize: 20, weight: .bold)
        proLabel.textColor = UIColor(hex: "#7B61FF")
        
        // Subtitle Label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Unlock all templates · Faster generation · No watermark"
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textColor = UIColor(white: 1.0, alpha: 0.7)
        subtitleLabel.numberOfLines = 1
        
        // Pro Button
        let proButton = UIButton(type: .system)
        proButton.setTitle("Pro", for: .normal)
        proButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        proButton.setTitleColor(.white, for: .normal)
        proButton.backgroundColor = UIColor(hex: "#7B61FF")
        proButton.layer.cornerRadius = 16
        proButton.isUserInteractionEnabled = false // 点击由父视图处理
        
        // Add subviews
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(proLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(proButton)
        
        // Layout
        iconLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(4)
            make.centerY.equalTo(iconLabel)
        }
        
        proLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
            make.centerY.equalTo(iconLabel)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel)
            make.top.equalTo(iconLabel.snp.bottom).offset(6)
            make.trailing.lessThanOrEqualTo(proButton.snp.leading).offset(-16)
        }
        
        proButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(32)
        }
        
        return containerView
    }
}
