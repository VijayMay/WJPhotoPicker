//
//  WJPermissionFooterView.swift
//  MFPhotoPicker
//
//  Created by Meiwenjie on 2025/10/19.
//

import UIKit
import SnapKit

/// 权限提示 Footer 视图
class WJPermissionFooterView: UICollectionReusableView {
    
    static let reuseIdentifier = "WJPermissionFooterView"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.backgroundColor = .clear
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    // MARK: - Properties
    
    var onSettingsButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(settingsButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func settingsButtonTapped() {
        onSettingsButtonTapped?()
    }
    
    // MARK: - Public Methods
    
    /// 配置权限提示视图
    /// - Parameters:
    ///   - icon: 图标
    ///   - message: 提示文字
    ///   - buttonTitle: 按钮文字（如果为 nil，隐藏按钮）
    func configure(icon: UIImage?, message: String?, buttonTitle: String?) {
        iconImageView.image = icon
        messageLabel.text = message
        
        if let buttonTitle = buttonTitle, !buttonTitle.isEmpty {
            settingsButton.setTitle(buttonTitle, for: .normal)
            settingsButton.isHidden = false
        } else {
            settingsButton.isHidden = true
        }
        
        // 强制更新布局，确保多行文本正确显示
        setNeedsLayout()
        layoutIfNeeded()
    }
}
