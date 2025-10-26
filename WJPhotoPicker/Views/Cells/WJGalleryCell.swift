//
//  WJGalleryCell.swift
//  WJPhotoPicker
//
//  Created by Cascade on 2025/10/25.
//

import UIKit
import SnapKit

/// Gallery Cell - 用于触发系统权限选择器
class WJGalleryCell: UICollectionViewCell {
    
    static let reuseIdentifier = "WJGalleryCell"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 4  // 与照片网格保持一致
        return view
    }()
    
    private let galleryIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Gallery"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        return label
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
        contentView.addSubview(containerView)
        containerView.addSubview(galleryIconView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        galleryIconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(galleryIconView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Highlight
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.containerView.alpha = self.isHighlighted ? 0.6 : 1.0
            }
        }
    }
}
