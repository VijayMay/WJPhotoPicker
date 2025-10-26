//
//  WJAlbumCell.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import SnapKit

/// 相册 Cell
class WJAlbumCell: UITableViewCell {
    
    static let reuseIdentifier = "WJAlbumCell"
    
    // MARK: - UI Components
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.textAlignment = .right
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(40)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(album: WJPhotoAlbum, isSelected: Bool) {
        titleLabel.text = album.title
        countLabel.text = "\(album.count)"
        thumbnailImageView.image = album.thumbnail
        
        // 设置选中状态
        if isSelected {
            backgroundColor = UIColor(white: 1.0, alpha: 0.1)
            thumbnailImageView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            backgroundColor = .clear
            thumbnailImageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        countLabel.text = nil
        checkmarkImageView.isHidden = true
    }
}
