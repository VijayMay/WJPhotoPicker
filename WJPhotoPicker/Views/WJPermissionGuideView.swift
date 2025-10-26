//
//  WJPermissionGuideView.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import SnapKit

/// 权限引导视图
class WJPermissionGuideView: UIView {
    
    // MARK: - Properties
    
    var onSettingsButtonTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "需要访问相册权限"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "请在设置中允许访问您的照片，以便选择和上传图片"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("去设置", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        return stack
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
        backgroundColor = .clear
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(settingsButton)
        
        addSubview(stackView)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.width.equalTo(stackView.snp.width).multipliedBy(0.8)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
        
        stackView.setCustomSpacing(12, after: titleLabel)
        stackView.setCustomSpacing(30, after: descriptionLabel)
    }
    
    // MARK: - Actions
    
    @objc private func settingsButtonTapped() {
        onSettingsButtonTapped?()
    }
}
