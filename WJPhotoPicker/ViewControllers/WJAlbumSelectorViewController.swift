//
//  WJAlbumSelectorViewController.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import SnapKit

/// 相册选择器视图控制器
class WJAlbumSelectorViewController: UIViewController {
    
    // MARK: - Properties
    
    var albums: [WJPhotoAlbum] = []
    var selectedAlbum: WJPhotoAlbum?
    var onAlbumSelected: ((WJPhotoAlbum) -> Void)?
    
    // 权限提示配置
    var limitedPermissionIcon: UIImage?
    var limitedPermissionMessage: String?
    var limitedPermissionButtonTitle: String?
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(WJAlbumCell.self, forCellReuseIdentifier: WJAlbumCell.reuseIdentifier)
        table.rowHeight = 76
        table.separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 0)
        return table
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择相册"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    // 权限提示视图
    private lazy var permissionGuideView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        
        let iconImageView = UIImageView()
        iconImageView.tintColor = .systemGray
        iconImageView.contentMode = .scaleAspectFit
        
        let messageLabel = UILabel()
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        let settingsButton = UIButton(type: .system)
        settingsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        settingsButton.backgroundColor = .systemBlue
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.layer.cornerRadius = 12
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(settingsButton)
        
        containerView.addSubview(stackView)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.width.equalTo(stackView.snp.width).multipliedBy(0.8)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
        
        stackView.setCustomSpacing(12, after: messageLabel)
        
        containerView.isHidden = true
        return containerView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkPermissionAndShowContent()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(handleBar)
        headerView.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(permissionGuideView)
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        handleBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        permissionGuideView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Private Methods
    
    private func checkPermissionAndShowContent() {
        let service = WJPhotoPickerService.shared
        let status = service.checkPermission()
        
        if status == .limited && albums.isEmpty {
            // 限制权限且没有相册：显示权限提示
            showPermissionGuide()
        } else {
            // 有相册或其他权限状态：显示相册列表
            showAlbumList()
            loadAlbumThumbnails()
        }
    }
    
    private func showPermissionGuide() {
        configurePermissionGuideView()
        tableView.isHidden = true
        permissionGuideView.isHidden = false
    }
    
    private func configurePermissionGuideView() {
        // 获取权限提示视图中的子视图
        guard let stackView = permissionGuideView.subviews.first as? UIStackView,
              stackView.arrangedSubviews.count >= 3 else { return }
        
        let iconImageView = stackView.arrangedSubviews[0] as? UIImageView
        let messageLabel = stackView.arrangedSubviews[1] as? UILabel
        let settingsButton = stackView.arrangedSubviews[2] as? UIButton
        
        // 配置图标（使用外部配置或默认值）
        iconImageView?.image = limitedPermissionIcon ?? UIImage(systemName: "photo.badge.plus")
        
        // 配置文案（使用外部配置或默认值）
        messageLabel?.text = limitedPermissionMessage ?? "当前使用选择照片模式，没有可访问的相册\n建议开启完整相册权限"
        
        // 配置按钮文字（使用外部配置或默认值）
        settingsButton?.setTitle(limitedPermissionButtonTitle ?? "前往设置", for: .normal)
    }
    
    private func showAlbumList() {
        tableView.isHidden = false
        permissionGuideView.isHidden = true
    }
    
    @objc private func settingsButtonTapped() {
        let service = WJPhotoPickerService.shared
        service.openSettings()
    }
    
    private func loadAlbumThumbnails() {
        let service = WJPhotoPickerService.shared
        
        for (index, album) in albums.enumerated() {
            service.fetchPhotos(from: album) { [weak self] assets in
                guard let self = self, let firstAsset = assets.first else { return }
                
                let targetSize = CGSize(width: 120, height: 120)
                service.loadThumbnail(for: firstAsset, targetSize: targetSize) { image in
                    self.albums[index].thumbnail = image
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    if self.tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension WJAlbumSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WJAlbumCell.reuseIdentifier,
            for: indexPath
        ) as? WJAlbumCell else {
            return UITableViewCell()
        }
        
        let album = albums[indexPath.row]
        let isSelected = album == selectedAlbum
        cell.configure(with: album, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WJAlbumSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
        selectedAlbum = album
        onAlbumSelected?(album)
        
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
}
