//
//  WJViewController.swift
//  MFPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import Photos
import SDWebImage
import SDWebImageWebPCoder
import SnapKit

class WJViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // MARK: - UI Components
    
    private let slidingPanelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("滑动面板相册", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let standardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("标准相册", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let slidingPanelSingleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("滑动面板单选", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let standardSingleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("标准单选", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "WJPhotoPicker 示例"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择一种相册类型"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "未选择照片"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemGray5.cgColor
        imageView.backgroundColor = .systemGray6
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(slidingPanelButton)
        view.addSubview(standardButton)
        view.addSubview(slidingPanelSingleButton)
        view.addSubview(standardSingleButton)
        view.addSubview(resultLabel)
        view.addSubview(thumbnailImageView)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        slidingPanelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.width.equalTo(280)
            make.height.equalTo(56)
        }
        
        standardButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(slidingPanelButton.snp.bottom).offset(20)
            make.width.equalTo(280)
            make.height.equalTo(56)
        }
        
        slidingPanelSingleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(standardButton.snp.bottom).offset(20)
            make.width.equalTo(280)
            make.height.equalTo(56)
        }
        
        standardSingleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(slidingPanelSingleButton.snp.bottom).offset(20)
            make.width.equalTo(280)
            make.height.equalTo(56)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(standardSingleButton.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalTo(resultLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
    }
    
    private func setupActions() {
        slidingPanelButton.addTarget(self, action: #selector(openSlidingPanelPicker), for: .touchUpInside)
        standardButton.addTarget(self, action: #selector(openStandardPicker), for: .touchUpInside)
        slidingPanelSingleButton.addTarget(self, action: #selector(openSlidingPanelSinglePicker), for: .touchUpInside)
        standardSingleButton.addTarget(self, action: #selector(openStandardSinglePicker), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func openSlidingPanelPicker() {
        // 滑动面板类型 + WebP动图 + 示例图片
        let config = WJPhotoPickerConfiguration(
            type: .slidingPanel,
            // 使用真实的 WebP 动图 URL（来自 Cloudinary 示例）
            animatedImageURL: URL(string: "https://res.cloudinary.com/demo/image/upload/w_150,h_100,q_80/bored_animation.webp"),
            animatedImageData: nil,
            animatedImagePlaceholder: UIImage(systemName: "photo.on.rectangle.angled"),
            sampleImages: loadSampleImages(),
            maxSelectionCount: 9,
            allowsCamera: true,
            allowsMultipleSelection: true,
            numberOfColumns: 3,
            gridSpacing: 2,
            navigationTitle: nil,
            slidingPanelTopHeightRatio: 0.33,
            permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
            permissionMessage: "需要访问您的照片来选择图片，请在设置中开启相册权限",
            permissionButtonTitle: "前往设置",
            defaultAlbumTitle: "相册",
            emptyAlbumIcon: UIImage(systemName: "photo.on.rectangle"),
            emptyAlbumMessage: "相册中还没有照片\n快去拍摄或添加照片吧",
            emptyAlbumButtonTitle: nil,  // 不显示按钮
            limitedPermissionIcon: UIImage(systemName: "photo.badge.plus"),
            limitedPermissionMessage: "您选择了部分照片权限，当前没有可访问的照片",
            limitedPermissionButtonTitle: "开启完整权限"
        )
        
        presentPhotoPicker(with: config, type: "滑动面板")
    }
    
    @objc private func openStandardPicker() {
        // 标准类型 + 4列布局 + 示例图片
        let config = WJPhotoPickerConfiguration(
            type: .standard,
            animatedImageURL: nil,
            animatedImageData: nil,
            animatedImagePlaceholder: nil,
            sampleImages: loadSampleImages(),  // 添加示例图片
            maxSelectionCount: 5,
            allowsCamera: true,
            allowsMultipleSelection: true,
            numberOfColumns: 4,
            gridSpacing: 1,
            navigationTitle: nil,  // 使用相册选择按钮
            slidingPanelTopHeightRatio: 0.33,
            permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
            permissionMessage: "需要访问您的照片来选择图片，请在设置中开启相册权限",
            permissionButtonTitle: "前往设置",
            defaultAlbumTitle: "所有照片",
            emptyAlbumIcon: UIImage(systemName: "photo.on.rectangle"),
            emptyAlbumMessage: "相册中还没有照片\n快去拍摄或添加照片吧",
            emptyAlbumButtonTitle: nil,
            limitedPermissionIcon: UIImage(systemName: "photo.badge.plus"),
            limitedPermissionMessage: "当前使用选择照片模式，没有可访问的照片\n建议开启完整相册权限",
            limitedPermissionButtonTitle: "开启完整权限"
        )
        
        presentPhotoPicker(with: config, type: "标准")
    }
    
    @objc private func openSlidingPanelSinglePicker() {
        // 滑动面板单选模式
        let config = WJPhotoPickerConfiguration(
            type: .slidingPanel,
            animatedImageURL: URL(string: "https://res.cloudinary.com/demo/image/upload/w_150,h_100,q_80/bored_animation.webp"),
            animatedImageData: nil,
            animatedImagePlaceholder: UIImage(systemName: "photo.on.rectangle.angled"),
            sampleImages: loadSampleImages(),
            maxSelectionCount: 1,  // 单选
            allowsCamera: true,
            allowsMultipleSelection: false,  // 禁用多选
            numberOfColumns: 3,
            gridSpacing: 2,
            navigationTitle: nil,
            slidingPanelTopHeightRatio: 0.33,
            permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
            permissionMessage: "需要访问您的照片来选择图片，请在设置中开启相册权限",
            permissionButtonTitle: "前往设置",
            defaultAlbumTitle: "相册",
            emptyAlbumIcon: UIImage(systemName: "photo.on.rectangle"),
            emptyAlbumMessage: "相册中还没有照片\n快去拍摄或添加照片吧",
            emptyAlbumButtonTitle: nil,
            limitedPermissionIcon: UIImage(systemName: "photo.badge.plus"),
            limitedPermissionMessage: "您选择了部分照片权限，当前没有可访问的照片\n建议开启完整相册权限以选择更多照片",
            limitedPermissionButtonTitle: "开启完整权限"
        )
        
        presentPhotoPicker(with: config, type: "滑动面板单选")
    }
    
    @objc private func openStandardSinglePicker() {
        // 标准单选模式
        let config = WJPhotoPickerConfiguration(
            type: .standard,
            animatedImageURL: nil,
            animatedImageData: nil,
            animatedImagePlaceholder: nil,
            sampleImages: loadSampleImages(),
            maxSelectionCount: 1,  // 单选
            allowsCamera: true,
            allowsMultipleSelection: false,  // 禁用多选
            numberOfColumns: 4,
            gridSpacing: 1,
            navigationTitle: nil,  // 使用相册选择按钮
            slidingPanelTopHeightRatio: 0.33,
            permissionIcon: UIImage(systemName: "photo.on.rectangle.angled"),
            permissionMessage: "需要访问您的照片来选择图片，请在设置中开启相册权限",
            permissionButtonTitle: "前往设置",
            defaultAlbumTitle: "相册",
            emptyAlbumIcon: UIImage(systemName: "photo.on.rectangle"),
            emptyAlbumMessage: "相册中还没有照片\n快去拍摄或添加照片吧",
            emptyAlbumButtonTitle: nil,
            limitedPermissionIcon: UIImage(systemName: "photo.badge.plus"),
            limitedPermissionMessage: "当前使用选择照片模式，没有可访问的照片\n建议开启完整相册权限以选择照片",
            limitedPermissionButtonTitle: "开启完整权限"
        )
        
        presentPhotoPicker(with: config, type: "标准单选")
    }
    
    // MARK: - Helper Methods
    
    /// 加载示例图片（使用 URL 方式，支持网络图片）
    private func loadSampleImages() -> [WJSampleImageItem] {
        // Unsplash 示例图片 URL
        let imageURLStrings = [
            "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop",  // 山景
            "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&h=300&fit=crop",  // 自然
//            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&h=300&fit=crop",  // 森林
//            "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop",  // 花朵
//            "https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=400&h=300&fit=crop",  // 湖泊
//            "https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=400&h=300&fit=crop"   // 日落
        ]
        
        // 转换为 URL 并创建 WJSampleImageItem
        let urls = imageURLStrings.compactMap { URL(string: $0) }
        return WJPhotoPickerConfiguration.with(urls: urls)
    }
    
    private func presentPhotoPicker(with config: WJPhotoPickerConfiguration, type: String) {
        let picker = WJPhotoPickerViewController(configuration: config)
        
        // 照片选择回调
        picker.onPhotosSelected = { [weak self] assets in
            self?.handlePhotosSelected(assets, type: type)
        }
        
        // 示例图选择回调（单个选择时的即时回调）
        picker.onSampleImageSelected = { [weak self] image in
            self?.handleSampleImageSelected(image, type: type)
        }
        
        // 示例图完成回调（点击完成按钮时返回所有选中的示例图片）
        picker.onSampleImagesCompleted = { [weak self] items in
            self?.handleSampleImagesCompleted(items, type: type)
        }
        
        // 相机回调
        picker.onCameraSelected = { [weak self] in
            self?.openCamera()
        }
        
        // 拍照完成回调
        picker.onCameraImageCaptured = { [weak self] image in
            self?.handleCameraImageCaptured(image, type: type)
        }
        
        // 取消回调
        picker.onCancel = { [weak self] in
            self?.resultLabel.text = "用户取消选择"
            self?.thumbnailImageView.isHidden = true
        }
        
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    private func handlePhotosSelected(_ assets: [PHAsset], type: String) {
        resultLabel.text = "[\(type)] 已选择 \(assets.count) 张照片"
        
        // 加载第一张照片作为缩略图
        if let firstAsset = assets.first {
            firstAsset.getThumbnail(size: CGSize(width: 400, height: 400)) { [weak self] image in
                DispatchQueue.main.async {
                    if let image = image {
                        self?.thumbnailImageView.image = image
                        self?.thumbnailImageView.isHidden = false
                        self?.showSuccessAlert(message: "成功获取 \(assets.count) 张照片")
                    }
                }
            }
        }
    }
    
    private func handleSampleImageSelected(_ item: WJSampleImageItem, type: String) {
        resultLabel.text = "[\(type)] 已选择示例图片"
        
        // 显示示例图片缩略图
        switch item {
        case .image(let image):
            thumbnailImageView.image = image
            thumbnailImageView.isHidden = false
        case .url(let url):
            // 使用SDWebImage加载网络图片
            thumbnailImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
            thumbnailImageView.isHidden = false
        }
        
        showSuccessAlert(message: "选择了示例图片")
    }
    
    private func handleSampleImagesCompleted(_ items: [WJSampleImageItem], type: String) {
        resultLabel.text = "[\(type)] 完成选择 \(items.count) 张示例图片"
        
        // 显示第一张示例图片
        if let firstItem = items.first {
            switch firstItem {
            case .image(let image):
                thumbnailImageView.image = image
                thumbnailImageView.isHidden = false
            case .url(let url):
                thumbnailImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
                thumbnailImageView.isHidden = false
            }
        }
        
        showSuccessAlert(message: "完成选择 \(items.count) 张示例图片")
    }
    
    private func handleCameraImageCaptured(_ image: UIImage, type: String) {
        resultLabel.text = "[\(type)] 已拍摄照片 (\(Int(image.size.width))x\(Int(image.size.height)))"
        
        // 显示拍摄的照片
        thumbnailImageView.image = image
        thumbnailImageView.isHidden = false
        
        showSuccessAlert(message: "成功拍摄照片，尺寸: \(Int(image.size.width))x\(Int(image.size.height))")
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "提示", message: "相机不可用")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        // 确保在主线程且视图在窗口层级中
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.view.window != nil,
                  self.presentedViewController == nil else {
                return
            }
            
            let alert = UIAlertController(title: "✅ 成功", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        // 确保在主线程且视图在窗口层级中
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.view.window != nil,
                  self.presentedViewController == nil else {
                return
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension WJViewController {
    func imagePickerController(_ picker: UIImagePickerController,
                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if info[.originalImage] is UIImage {
            resultLabel.text = "已拍摄照片"
            showSuccessAlert(message: "成功拍摄照片")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        resultLabel.text = "取消拍照"
    }
}

