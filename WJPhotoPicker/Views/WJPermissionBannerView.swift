//
//  WJPermissionBannerView.swift
//  WJPhotoPicker
//
//  Created by Cascade on 2025/10/24.
//

import UIKit
import SnapKit

/// 权限横幅提示视图 (45px 高度)
class WJPermissionBannerView: UIView {
    
    // MARK: - Properties
    
    var onSettingsButtonTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "为了更好的体验，请开启完整照片访问权限"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("去设置", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
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
        backgroundColor = UIColor(hex: "#782FDE")
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(messageLabel)
        addSubview(settingsButton)
        
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(settingsButton.snp.leading).offset(-12)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
        }
    }
    
    // MARK: - Public Methods
    
    /// 配置横幅内容
    func configure(message: String?, buttonTitle: String?) {
        messageLabel.text = message ?? "为了更好的体验，请开启完整照片访问权限"
        settingsButton.setTitle(buttonTitle ?? "去设置", for: .normal)
    }
    
    /// 配置横幅颜色
    func configure(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundColor = backgroundColor
        messageLabel.textColor = textColor
        // 按钮始终保持白色背景+黑色文字
        settingsButton.setTitleColor(.black, for: .normal)
        settingsButton.backgroundColor = .white
    }
    
    // MARK: - Actions
    
    @objc private func settingsButtonTapped() {
        onSettingsButtonTapped?()
    }
}
