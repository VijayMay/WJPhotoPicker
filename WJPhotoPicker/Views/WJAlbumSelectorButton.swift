//
//  WJAlbumSelectorButton.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import SnapKit

/// 相册选择按钮
class WJAlbumSelectorButton: UIButton {
    
    // MARK: - Properties
    
    private let albumTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    var isExpanded: Bool = false
    
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
        textStackView.addArrangedSubview(albumTitleLabel)
        textStackView.addArrangedSubview(countLabel)
        
        stackView.addArrangedSubview(textStackView)
        stackView.addArrangedSubview(arrowImageView)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(title: String, count: Int) {
        albumTitleLabel.text = title
        countLabel.text = "\(count) 张照片"
        countLabel.isHidden = false
    }
    
    /// 只显示标题，不显示数量
    func configure(title: String) {
        albumTitleLabel.text = title
        countLabel.isHidden = true
    }
}
