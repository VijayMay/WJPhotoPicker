//
//  WJSampleImageCell.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import SDWebImage
import SnapKit

/// 示例图片 Cell
class WJSampleImageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "WJSampleImageCell"
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    private let selectionOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()
    
    private let checkmarkView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        contentView.addSubview(imageView)
        contentView.addSubview(selectionOverlay)
        contentView.addSubview(checkmarkView)
        checkmarkView.addSubview(checkmarkImageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectionOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkmarkView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.width.height.equalTo(24)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(with image: UIImage?) {
        imageView.image = image
    }
    
    func configure(with item: WJSampleImageItem) {
        switch item {
        case .image(let image):
            imageView.image = image
            
        case .url(let url):
            imageView.sd_setImage(
                with: url,
                placeholderImage: item.placeholderImage,
                options: [.retryFailed, .scaleDownLargeImages]
            )
        }
    }
    
    // MARK: - Selection
    
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateSelectionState() {
        UIView.animate(withDuration: 0.2) {
            self.selectionOverlay.isHidden = !self.isSelected
            self.checkmarkView.isHidden = !self.isSelected
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        isSelected = false
    }
}
