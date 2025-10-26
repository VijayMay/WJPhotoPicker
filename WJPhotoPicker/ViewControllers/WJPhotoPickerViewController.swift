//
//  WJPhotoPickerViewController.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import Photos
import PhotosUI
import FloatingPanel
import SnapKit

/// 自定义相册选择器主控制器
class WJPhotoPickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    private let configuration: WJPhotoPickerConfiguration
    private let service = WJPhotoPickerService.shared
    
    private var albums: [WJPhotoAlbum] = []
    private var currentAlbum: WJPhotoAlbum?
    private var photos: [PHAsset] = []
    private var gridItems: [WJPhotoGridItem] = []  // 融合后的网格项（相机+示例图片+照片）
    private var selectedAssets: Set<PHAsset> = []
    private var selectedSampleImages: Set<Int> = []  // 存储选中的示例图片索引
    
    private var isInitialLoad = true  // 标记是否是初始加载
    
    // MARK: - Callbacks
    
    var onPhotosSelected: (([PHAsset]) -> Void)?
    var onSampleImageSelected: ((WJSampleImageItem) -> Void)?  // 单个示例图片选择回调
    var onSampleImagesCompleted: (([WJSampleImageItem]) -> Void)?  // 完成时返回选中的示例图片
    var onCameraSelected: (() -> Void)?
    var onCameraImageCaptured: ((UIImage) -> Void)?  // 拍照完成回调，直接返回UIImage
    var onCancel: (() -> Void)?
    
    // MARK: - UI Components (Sliding Panel Type)
    
    private var topContainerView: UIView?
    private var mediaPreviewView: WJMediaPreviewView?    // 媒体预览组件 (WebP/MP4)
    private var floatingPanelController: FloatingPanelController?
    private var floatingPanelContentVC: WJFloatingPanelContentViewController?
    
    // MARK: - Advertisement
    
    private var advertisementView: WJAdvertisementView?
    
    // MARK: - Album List
    
    private var albumListView: WJAlbumListView?
    private var isAlbumListVisible = false
    
    // MARK: - UI Components (Common)
    
    private lazy var albumSelectorButton: WJAlbumSelectorButton = {
        let button = WJAlbumSelectorButton()
        button.addTarget(self, action: #selector(albumSelectorButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var photoGridCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = configuration.gridSpacing
        layout.minimumLineSpacing = configuration.gridSpacing
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = configuration.allowsMultipleSelection
        
        // 注册所有类型的 Cell
        collectionView.register(WJCameraCell.self, forCellWithReuseIdentifier: WJCameraCell.reuseIdentifier)
        collectionView.register(WJGalleryCell.self, forCellWithReuseIdentifier: WJGalleryCell.reuseIdentifier)
        collectionView.register(WJSampleImageCell.self, forCellWithReuseIdentifier: WJSampleImageCell.reuseIdentifier)
        collectionView.register(WJPhotoGridCell.self, forCellWithReuseIdentifier: WJPhotoGridCell.reuseIdentifier)
        
        // 注册 Footer
        collectionView.register(
            WJPermissionFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: WJPermissionFooterView.reuseIdentifier
        )
        
        return collectionView
    }()
    
    private lazy var permissionGuideView: WJPermissionGuideView = {
        let view = WJPermissionGuideView()
        view.isHidden = true
        view.onSettingsButtonTapped = { [weak self] in
            self?.service.openSettings()
        }
        return view
    }()
    
    private lazy var permissionBannerView: WJPermissionBannerView = {
        let view = WJPermissionBannerView()
        view.isHidden = true
        view.onSettingsButtonTapped = { [weak self] in
            self?.service.openSettings()
        }
        return view
    }()
    
    // MARK: - Theme
    
    private var currentThemeColors: (background: UIColor, cardBackground: UIColor, primaryText: UIColor, secondaryText: UIColor, tertiaryText: UIColor, separator: UIColor) {
        // 根据选择模式决定使用深色还是浅色主题：单选用深色，多选用浅色
        if configuration.allowsMultipleSelection {
            // 多选模式：使用浅色主题
            return (
                configuration.theme.lightColors.background,
                configuration.theme.lightColors.cardBackground,
                configuration.theme.lightColors.primaryText,
                configuration.theme.lightColors.secondaryText,
                configuration.theme.lightColors.tertiaryText,
                configuration.theme.lightColors.separator
            )
        } else {
            // 单选模式：使用深色主题
            return (
                configuration.theme.darkColors.background,
                configuration.theme.darkColors.cardBackground,
                configuration.theme.darkColors.primaryText,
                configuration.theme.darkColors.secondaryText,
                configuration.theme.darkColors.tertiaryText,
                configuration.theme.darkColors.separator
            )
        }
    }
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "完成",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "取消",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        return button
    }()
    
    // MARK: - Initialization
    
    init(configuration: WJPhotoPickerConfiguration = .default) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.configuration = .default
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        switch configuration.type {
        case .slidingPanel:
            setupSlidingPanelUI()
            setupAdvertisement()  // 滑块模式：在 FloatingPanel 创建后设置广告
        case .standard:
            setupStandardUI()
            setupAdvertisement()  // 标准模式：在视图创建后设置广告
        }
        
        setupNavigationBar()
        updateAlbumSelectorButton()  // 初始化时显示默认名称
        checkPermissionAndLoadData()
        observePhotoLibraryChanges()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mediaPreviewView?.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaPreviewView?.stopAnimating()
    }
    
    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        
        // 当系统深色/浅色模式改变时，更新主题色
        if traitCollection.hasDifferentColorAppearance(comparedTo: previous) {
            updateThemeColors()
        }
    }
    
    // MARK: - Theme Update
    
    private func updateThemeColors() {
        // 更新背景色
        view.backgroundColor = currentThemeColors.background
        
        if configuration.type == .slidingPanel {
            // 滑块模式：更新顶部容器和 FloatingPanel
            topContainerView?.backgroundColor = currentThemeColors.background
            floatingPanelController?.surfaceView.backgroundColor = currentThemeColors.cardBackground
            floatingPanelContentVC?.updateBackgroundColor(currentThemeColors.cardBackground)
            mediaPreviewView?.updateBackgroundColor(currentThemeColors.cardBackground)
        }
        
        // 重新应用导航栏主题色
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = currentThemeColors.background
        appearance.titleTextAttributes = [
            .foregroundColor: currentThemeColors.primaryText,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // 根据选择模式设置按钮颜色
        let buttonColor: UIColor = configuration.allowsMultipleSelection ? configuration.theme.primaryColor : .white
        navigationController?.navigationBar.tintColor = buttonColor
    }
    
    // MARK: - Setup UI (Sliding Panel)
    
    private func setupSlidingPanelUI() {
        // 顶部容器 (应用主题背景色)
        let topContainer = UIView()
        topContainer.backgroundColor = currentThemeColors.background
        view.addSubview(topContainer)
        self.topContainerView = topContainer
        
        // 预览卡片容器 (带圆角和阴影)
        let previewCard = UIView()
        previewCard.backgroundColor = .clear
        previewCard.layer.cornerRadius = 20
        previewCard.layer.shadowColor = UIColor.black.cgColor
        previewCard.layer.shadowOpacity = 0.1
        previewCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        previewCard.layer.shadowRadius = 8
        topContainer.addSubview(previewCard)
        
        // 媒体预览视图
        let mediaView = WJMediaPreviewView()
        mediaView.layer.cornerRadius = 20
        mediaView.clipsToBounds = true
        mediaView.updateBackgroundColor(currentThemeColors.cardBackground) // 设置背景颜色
        previewCard.addSubview(mediaView)
        self.mediaPreviewView = mediaView
        
        // 创建FloatingPanel
        let floatingPanel = FloatingPanelController()
        let contentVC = WJFloatingPanelContentViewController(configuration: configuration)
        
        // 设置内容视图控制器
        floatingPanel.set(contentViewController: contentVC)
        floatingPanel.delegate = contentVC
        
        // 设置自定义布局 ⭐ 关键：启用滚动联动
        let layout = WJFloatingPanelLayout()
        layout.topHeightRatio = configuration.slidingPanelTopHeightRatio
        floatingPanel.layout = layout
        
        // 配置FloatingPanel
        floatingPanel.isRemovalInteractionEnabled = false // 禁用向下滑动关闭
        floatingPanel.backdropView.dismissalTapGestureRecognizer.isEnabled = false
        floatingPanel.backdropView.isHidden = true // 隐藏背景遮罩，使权限引导视图透明
        floatingPanel.surfaceView.clipsToBounds = true
        floatingPanel.surfaceView.layer.cornerRadius = 16
        floatingPanel.surfaceView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // 显示拖拽手柄
        floatingPanel.surfaceView.grabberHandle.isHidden = false
        floatingPanel.surfaceView.grabberHandle.barColor = UIColor.systemGray3
        
        // ⭐ 关键：确保手势识别器启用
        floatingPanel.panGestureRecognizer.isEnabled = true
        
        // ⭐⭐⭐ 关键：显式启用滚动视图跟踪
        floatingPanel.track(scrollView: photoGridCollectionView)
        
        // 添加到当前控制器
        floatingPanel.addPanel(toParent: self)
        
        // ✅ 应用主题色到 FloatingPanel 背景（在 addPanel 之后，确保 viewDidLoad 已调用）
        floatingPanel.surfaceView.backgroundColor = currentThemeColors.cardBackground
        contentVC.updateBackgroundColor(currentThemeColors.cardBackground)
        
        self.floatingPanelController = floatingPanel
        self.floatingPanelContentVC = contentVC
        
        // 绑定按钮事件
        contentVC.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        contentVC.doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        contentVC.albumSelectorButton.addTarget(self, action: #selector(albumSelectorButtonTapped), for: .touchUpInside)
        
        // 设置关闭回调
        contentVC.onDismiss = { [weak self] in
            // 确保面板被移除后再调用取消
            DispatchQueue.main.async {
                self?.cancelButtonTapped()
            }
        }
        
        // 设置位置变化回调，模拟模态视图隐藏效果
        contentVC.onPositionChanged = { [weak self] relativePosition in
            self?.updateModalDismissEffect(progress: relativePosition)
        }
        
        // 在FloatingPanel中添加内容
        setupFloatingPanelContent(in: contentVC.contentView)
        
        // ⭐ 关键：设置滚动视图引用，启用滚动联动
        contentVC.trackingScrollView = photoGridCollectionView
        
        // 布局顶部容器
        topContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(calculatePreviewAreaHeight())
        }
        
        // 布局预览卡片 (11px top, 16px 左右, 199px @ 375)
        previewCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(11)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(calculatePreviewHeight())
        }
        
        mediaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 加载预览媒体
        loadPreviewMedia()
    }
    
    private func setupFloatingPanelContent(in containerView: UIView) {
        // 添加照片网格（最底层）
        containerView.addSubview(photoGridCollectionView)
        
        // 添加权限横幅（在照片网格上面）
        containerView.addSubview(permissionBannerView)
        
        // 添加权限引导视图（最顶层）
        containerView.addSubview(permissionGuideView)
        
        // 布局权限横幅 (45px 高度，左右16px 边距)
        permissionBannerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(45)
        }
        
        // 布局照片网格
        photoGridCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // 布局权限引导视图 (全屏覆盖)
        permissionGuideView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Helper: Calculate Preview Heights
    
    private func calculatePreviewAreaHeight() -> CGFloat {
        let previewHeight = calculatePreviewHeight()
        let topMargin: CGFloat = 11
        let bottomMargin: CGFloat = 18
        return topMargin + previewHeight + bottomMargin
    }
    
    private func calculatePreviewHeight() -> CGFloat {
        let screenWidth = view.bounds.width
        let baseWidth: CGFloat = 375
        let baseHeight: CGFloat = 199
        let ratio = screenWidth / baseWidth
        return baseHeight * ratio
    }
    
    // MARK: - Setup UI (Standard)
    
    private func setupStandardUI() {
        // 添加照片网格（最底层）
        view.addSubview(photoGridCollectionView)
        
        // 添加权限横幅（在照片网格上面）
        view.addSubview(permissionBannerView)
        
        // 添加权限引导视图（最顶层）
        view.addSubview(permissionGuideView)
        
        // 布局权限横幅 (45px 高度，左右16px 边距)
        permissionBannerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom).offset(8)
            }
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(45)
        }
        
        // 布局照片网格
        photoGridCollectionView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // 布局权限引导视图 (全屏覆盖)
        permissionGuideView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        // 应用主题色
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = currentThemeColors.background
        appearance.titleTextAttributes = [
            .foregroundColor: currentThemeColors.primaryText,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // 根据选择模式设置按钮颜色：单选模式用白色，多选模式用 primaryColor
        let buttonColor: UIColor = configuration.allowsMultipleSelection ? configuration.theme.primaryColor : .white
        navigationController?.navigationBar.tintColor = buttonColor
        
        if configuration.type == .standard {
            // 标准模式：显示导航栏
            
            // 左侧：返回按钮
            if configuration.showBackButton {
                let backButton = UIBarButtonItem(
                    image: configuration.backButtonIcon ?? UIImage(systemName: "chevron.left"),
                    style: .plain,
                    target: self,
                    action: #selector(backButtonTapped)
                )
                backButton.tintColor = buttonColor
                navigationItem.leftBarButtonItem = backButton
            } else {
                navigationItem.leftBarButtonItem = cancelButton
            }
            
            // 中间：All Picture 按钮 (仅全部权限显示) 或标题
            updateNavigationTitle()
            
            // 右侧：完成按钮 (仅多选)
            if configuration.allowsMultipleSelection {
                let doneBtn = UIBarButtonItem(
                    title: "完成",
                    style: .done,
                    target: self,
                    action: #selector(doneButtonTapped)
                )
                doneBtn.tintColor = buttonColor
                navigationItem.rightBarButtonItem = doneBtn
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        } else {
            // 滑动面板模式：显示导航栏
            navigationController?.setNavigationBarHidden(false, animated: false)
            
            // 左侧：返回按钮
            if configuration.showBackButton {
                let backButton = UIBarButtonItem(
                    image: configuration.backButtonIcon ?? UIImage(systemName: "chevron.left"),
                    style: .plain,
                    target: self,
                    action: #selector(backButtonTapped)
                )
                backButton.tintColor = buttonColor
                navigationItem.leftBarButtonItem = backButton
            }
            
            // 中间：标题
            title = configuration.navigationTitle ?? "相册"
            
            // 右侧：完成按钮 (仅多选)
            if configuration.allowsMultipleSelection {
                let doneBtn = UIBarButtonItem(
                    title: "完成",
                    style: .done,
                    target: self,
                    action: #selector(doneButtonTapped)
                )
                doneBtn.tintColor = buttonColor
                navigationItem.rightBarButtonItem = doneBtn
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
        
        updateDoneButtonState()
    }
    
    // MARK: - Helper: Update Navigation Title
    
    private func updateNavigationTitle() {
        guard configuration.type == .standard else { return }
        
        let status = service.checkPermission()
        
        // 全部权限且没有自定义标题：显示 All Picture 按钮
        if status == .authorized && configuration.navigationTitle == nil {
            navigationItem.titleView = albumSelectorButton
        } else {
            // 其他情况：显示文字标题
            navigationItem.titleView = nil
            title = configuration.navigationTitle ?? "相册"
        }
    }
    
    @objc private func backButtonTapped() {
        onCancel?()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Advertisement Setup
    
    private func setupAdvertisement() {
        // 如果不显示广告，直接返回
        guard configuration.showAdvertisement else { return }
        
        // 创建广告视图
        let adView = WJAdvertisementView(customView: configuration.customAdvertisementView)
        adView.isVisible = configuration.showAdvertisement
        adView.onAdTapped = { [weak self] in
            self?.configuration.onAdvertisementTapped?()
        }
        
        // 根据模式添加到不同位置
        switch configuration.type {
        case .slidingPanel:
            // 滑块模式：添加到 FloatingPanel 的 contentView 底部
            if let contentView = floatingPanelContentVC?.contentView {
                contentView.addSubview(adView)
                adView.snp.makeConstraints { make in
                    make.leading.trailing.bottom.equalToSuperview()
                    make.height.equalTo(WJAdvertisementView.height)
                }
            }
            
        case .standard:
            // 标准模式：添加到主视图底部
            view.addSubview(adView)
            adView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
                make.height.equalTo(WJAdvertisementView.height)
            }
        }
        
        self.advertisementView = adView
        
        // 更新照片网格的底部边距
        updatePhotoGridInsets()
    }
    
    private func updatePhotoGridInsets() {
        let adHeight = (advertisementView?.isVisible == true) ? WJAdvertisementView.height : 0
        let topInset = permissionBannerView.isHidden ? 0 : 61
        
        // 使用 DispatchQueue 确保在主线程更新，并强制布局
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.photoGridCollectionView.contentInset = UIEdgeInsets(
                top: CGFloat(topInset),
                left: 0,
                bottom: adHeight,
                right: 0
            )
            
            self.photoGridCollectionView.scrollIndicatorInsets = self.photoGridCollectionView.contentInset
            
            // 强制更新布局
            self.photoGridCollectionView.setNeedsLayout()
            self.photoGridCollectionView.layoutIfNeeded()
        }
    }
    
    // MARK: - Data Loading
    
    private func checkPermissionAndLoadData() {
        let status = service.checkPermission()
        handlePermissionStatus(status)
    }
    
    private func handlePermissionStatus(_ status: WJPermissionStatus) {
        // 初始加载时不使用动画
        let animated = !isInitialLoad
        
        switch status {
        case .authorized:
            // 全部权限：隐藏权限横幅
            if !animated {
                UIView.performWithoutAnimation {
                    permissionGuideView.isHidden = true
                    permissionBannerView.isHidden = true
                    photoGridCollectionView.isHidden = false
                }
            } else {
                permissionGuideView.isHidden = true
                permissionBannerView.isHidden = true
                photoGridCollectionView.isHidden = false
            }
            // 更新 contentInset（为广告留出空间）
            updatePhotoGridInsets()
            updateAlbumSelectorVisibility(show: true, animated: animated)
            updateNavigationTitle()  // 更新导航栏标题
            loadAlbums()
            loadPhotos()
            
        case .limited:
            // 部分权限：显示权限横幅，隐藏相册选择按钮
            if !animated {
                UIView.performWithoutAnimation {
                    permissionGuideView.isHidden = true
                    permissionBannerView.isHidden = false
                    photoGridCollectionView.isHidden = false
                }
            } else {
                permissionGuideView.isHidden = true
                permissionBannerView.isHidden = false
                photoGridCollectionView.isHidden = false
            }
            // 更新 contentInset（为横幅和广告留出空间）
            updatePhotoGridInsets()
            updateAlbumSelectorVisibility(show: false, animated: animated) // 隐藏相册选择按钮
            updateNavigationTitle()  // 更新导航栏标题
            loadAlbums()
            loadPhotos()
            
        case .denied:
            // 权限被拒绝：隐藏权限横幅（只在 limited 时显示）
            if !animated {
                UIView.performWithoutAnimation {
                    permissionGuideView.isHidden = true
                    permissionBannerView.isHidden = true
                    photoGridCollectionView.isHidden = false
                }
            } else {
                permissionGuideView.isHidden = true
                permissionBannerView.isHidden = true
                photoGridCollectionView.isHidden = false
            }
            // 更新 contentInset（为广告留出空间）
            updatePhotoGridInsets()
            updateAlbumSelectorVisibility(show: false, animated: animated)
            updateNavigationTitle()  // 更新导航栏标题
            photos = []
            buildGridItems()
            reloadCollectionView(animated: animated)
            isInitialLoad = false
            
        case .notDetermined:
            // 未确定权限：显示权限引导视图，不主动请求权限
            if !animated {
                UIView.performWithoutAnimation {
                    permissionGuideView.isHidden = false
                    permissionBannerView.isHidden = true
                    photoGridCollectionView.isHidden = true
                }
            } else {
                permissionGuideView.isHidden = false
                permissionBannerView.isHidden = true
                photoGridCollectionView.isHidden = true
            }
            updateAlbumSelectorVisibility(show: false, animated: animated)
            isInitialLoad = false
        }
    }
    
    private func requestPermission() {
        service.requestPermission { [weak self] status in
            self?.handlePermissionStatus(status)
        }
    }
    
    private func showPermissionGuide() {
        permissionGuideView.isHidden = false
        photoGridCollectionView.isHidden = true
    }
    
    private func loadAlbums() {
        service.fetchAlbums { [weak self] albums in
            guard let self = self else { return }
            self.albums = albums
            
            if let firstAlbum = albums.first {
                self.currentAlbum = firstAlbum
                self.updateAlbumSelectorButton()
            }
        }
    }
    
    private func loadPhotos() {
        service.fetchPhotos(from: currentAlbum) { [weak self] assets in
            guard let self = self else { return }
            self.photos = assets
            self.buildGridItems()
            // 初始加载时不使用动画
            let animated = !self.isInitialLoad
            self.reloadCollectionView(animated: animated)
            // 标记初始加载完成
            self.isInitialLoad = false
            
            // ⭐ 关键：数据加载完成后，刷新FloatingPanel的滚动联动
            if self.configuration.type == .slidingPanel {
                DispatchQueue.main.async {
                    self.refreshFloatingPanelScrollTracking()
                }
            }
        }
    }
    
    /// 构建网格数据源（相机 + Gallery + 示例图片 + 照片）
    private func buildGridItems() {
        gridItems.removeAll()
        
        // 1. 添加相机（如果允许）
        if configuration.allowsCamera {
            gridItems.append(.camera)
        }
        
        // 2. 添加 Gallery（仅在 limited 权限时）
        if service.checkPermission() == .limited {
            gridItems.append(.gallery)
        }
        
        // 3. 添加示例图片（如果有）
        for (index, item) in configuration.sampleImages.enumerated() {
            gridItems.append(.sampleImage(item, index: index))
        }
        
        // 4. 添加系统照片
        for photo in photos {
            gridItems.append(.photo(photo))
        }
    }
    
    private func loadPreviewMedia() {
        guard let mediaView = mediaPreviewView else { return }
        
        switch configuration.previewMediaType {
        case .webp:
            // 加载 WebP 动图
            if let url = configuration.animatedImageURL {
                mediaView.loadWebP(
                    url: url,
                    placeholder: configuration.previewPlaceholder,
                    autoPlay: configuration.previewAutoPlay
                )
            } else if let data = configuration.animatedImageData {
                mediaView.loadWebP(
                    data: data,
                    placeholder: configuration.previewPlaceholder,
                    autoPlay: configuration.previewAutoPlay
                )
            } else {
                // 只显示占位图
                mediaView.loadWebP(
                    url: nil,
                    placeholder: configuration.previewPlaceholder,
                    autoPlay: false
                )
            }
            
        case .mp4:
            // 加载 MP4 视频
            mediaView.loadMP4(
                url: configuration.videoURL,
                placeholder: configuration.previewPlaceholder,
                autoPlay: configuration.previewAutoPlay,
                loopPlay: configuration.previewLoopPlay
            )
        }
    }
    
    private func observePhotoLibraryChanges() {
        service.observePhotoLibraryChanges { [weak self] _ in
            self?.loadPhotos()
        }
    }
    
    // MARK: - Actions
    
    @objc private func albumSelectorButtonTapped() {
        // 切换相册列表显示/隐藏
        if isAlbumListVisible {
            hideAlbumList()
        } else {
            showAlbumList()
        }
    }
    
    private func showAlbumList() {
        guard !isAlbumListVisible, 
              let contentView = floatingPanelContentVC?.contentView
        else { 
            return 
        }
        
        // 创建相册列表视图
        let listView = WJAlbumListView()
        listView.albums = self.albums
        listView.selectedAlbum = self.currentAlbum
        listView.onAlbumSelected = { [weak self] album in
            self?.selectAlbum(album)
            self?.hideAlbumList()
        }
        listView.onDismiss = { [weak self] in
            self?.hideAlbumList()
        }
        
        // 计算底部偏移（为广告留出空间）
        let adHeight = (advertisementView?.isVisible == true) ? WJAdvertisementView.height : 0
        
        // 显示相册列表
        // 注意：contentView 已经在工具栏下方，所以 topOffset 为 0
        listView.show(
            in: contentView,
            topOffset: 0,
            bottomOffset: adHeight
        )
        
        // 更新按钮状态
        albumSelectorButton.setExpanded(true)
        
        self.albumListView = listView
        self.isAlbumListVisible = true
    }
    
    private func hideAlbumList() {
        guard let listView = albumListView, isAlbumListVisible else { return }
        
        listView.hide { [weak self] in
            self?.albumListView = nil
            self?.isAlbumListVisible = false
        }
        
        // 更新按钮状态
        albumSelectorButton.setExpanded(false)
    }
    
    private func selectAlbum(_ album: WJPhotoAlbum) {
        currentAlbum = album
        updateAlbumSelectorButton()
        loadPhotos()
    }
    
    // 旧的模态视图方式（保留作为备用）
    private func showAlbumSelectorModal_deprecated() {
        let albumSelector = WJAlbumSelectorViewController()
        albumSelector.albums = albums
        albumSelector.selectedAlbum = currentAlbum
        
        // 配置权限提示文案
        albumSelector.limitedPermissionIcon = configuration.limitedPermissionIcon
        albumSelector.limitedPermissionMessage = configuration.limitedPermissionMessage
        albumSelector.limitedPermissionButtonTitle = configuration.limitedPermissionButtonTitle
        
        albumSelector.onAlbumSelected = { [weak self] album in
            self?.currentAlbum = album
            self?.updateAlbumSelectorButton()
            self?.loadPhotos()
        }
        
        if #available(iOS 15.0, *) {
            if let sheet = albumSelector.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = false
            }
        }
        
        present(albumSelector, animated: true)
        albumSelectorButton.isExpanded = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.albumSelectorButton.isExpanded = false
        }
    }
    
    @objc private func doneButtonTapped() {
        // 如果有选中的照片，返回照片
        if !selectedAssets.isEmpty {
            let selectedArray = Array(selectedAssets)
            onPhotosSelected?(selectedArray)
        }
        
        // 如果有选中的示例图片，返回示例图片
        if !selectedSampleImages.isEmpty {
            let selectedSampleImageItems = selectedSampleImages.sorted().compactMap { index -> WJSampleImageItem? in
                guard index < configuration.sampleImages.count else { return nil }
                return configuration.sampleImages[index]
            }
            onSampleImagesCompleted?(selectedSampleImageItems)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        onCancel?()
        dismiss(animated: true, completion: nil)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "相机不可用", message: "当前设备不支持相机功能")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
        // 同时调用回调（如果需要）
        onCameraSelected?()
    }
    
    // MARK: - Modal Dismiss Effect
    
    /// 更新模态视图隐藏效果
    /// - Parameter progress: 进度值 (0.0 = half位置或更高, 1.0 = 屏幕底部)
    private func updateModalDismissEffect(progress: CGFloat) {
        guard let topContainer = topContainerView,
              let mediaView = mediaPreviewView else { return }
        
        // 限制进度范围
        let clampedProgress = max(0.0, min(1.0, progress))
        
        if clampedProgress > 0.0 {
            // 当面板向下移动时应用效果
            let effectProgress = clampedProgress
            
            // 1. 顶部容器缩放效果 (轻微缩小)
            let scale = 1.0 - (effectProgress * 0.08) // 最多缩小8%
            
            // 2. 透明度效果 (逐渐变暗)
            let alpha = 1.0 - (effectProgress * 0.4) // 最多变暗40%
            
            // 3. 向上偏移效果 (模拟被推离屏幕)
            let offsetY = -(effectProgress * 30) // 向上偏移最多30px
            
            // 4. 圆角效果 (模拟缩小到卡片)
            let cornerRadius = effectProgress * 12 // 最多12px圆角
            
            // 应用变换
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                topContainer.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: offsetY)
                topContainer.alpha = alpha
                topContainer.layer.cornerRadius = cornerRadius
                
                // 媒体预览额外效果：更明显的淡化
                mediaView.alpha = alpha * 0.7
            }, completion: nil)
            
        } else {
            // 恢复正常状态
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
                topContainer.transform = .identity
                topContainer.alpha = 1.0
                topContainer.layer.cornerRadius = 0
                mediaView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateAlbumSelectorButton() {
        // 默认使用 "All Picture"，如果有选中的相册则使用相册名称
        let title = currentAlbum?.title ?? "All Picture"
        
        // 根据模式更新不同的按钮
        if configuration.type == .slidingPanel {
            floatingPanelContentVC?.albumSelectorButton.configure(title: title)
        } else {
            albumSelectorButton.configure(title: title)
        }
    }
    
    /// 更新相册选择器的可见性
    /// - Parameters:
    ///   - show: true 显示，false 隐藏
    ///   - animated: 是否使用动画，默认 true
    private func updateAlbumSelectorVisibility(show: Bool, animated: Bool = true) {
        if configuration.type == .slidingPanel {
            floatingPanelContentVC?.albumSelectorButton.isHidden = !show
            // 更新工具栏高度，避免留下空白
            floatingPanelContentVC?.updateToolbarHeight(animated: animated)
        } else {
            // 标准模式：如果使用自定义标题，不需要处理
            // 如果使用 titleView（相册选择器），则控制可见性
            if configuration.navigationTitle == nil {
                albumSelectorButton.isHidden = !show
                
                // 如果隐藏相册选择器，显示默认标题
                if !show {
                    navigationItem.titleView = nil
                    title = "照片"  // 默认标题
                } else {
                    navigationItem.titleView = albumSelectorButton
                }
            }
        }
    }
    
    private func updateDoneButtonState() {
        // 只要有选中的照片或示例图片，就启用完成按钮
        let hasSelection = !selectedAssets.isEmpty || !selectedSampleImages.isEmpty
        
        if configuration.type == .slidingPanel {
            floatingPanelContentVC?.doneButton.isEnabled = hasSelection
        } else {
            doneButton.isEnabled = hasSelection
        }
    }
    
    /// 重新加载 CollectionView
    /// - Parameter animated: 是否使用动画，默认 true
    private func reloadCollectionView(animated: Bool) {
        if animated {
            photoGridCollectionView.reloadData()
        } else {
            // 禁用动画
            UIView.performWithoutAnimation {
                photoGridCollectionView.reloadData()
            }
        }
    }
    
    /// ⭐ 刷新FloatingPanel的滚动联动
    private func refreshFloatingPanelScrollTracking() {
        guard configuration.type == .slidingPanel,
              let floatingPanel = floatingPanelController else { return }
        
        // 强制FloatingPanel重新检查滚动视图
        floatingPanel.invalidateLayout()
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

// MARK: - UICollectionViewDataSource

extension WJPhotoPickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 根据 PhotoGridItem 类型配置 Cell
        let item = gridItems[indexPath.item]
        
        switch item {
        case .camera:
            return configureCameraCell(at: indexPath)
            
        case .gallery:
            return configureGalleryCell(at: indexPath)
            
        case .sampleImage(let sampleItem, let index):
            return configureSampleImageCell(at: indexPath, item: sampleItem, index: index)
            
        case .photo(let asset):
            return configurePhotoCell(at: indexPath, asset: asset)
        }
    }
    
    // MARK: - Supplementary Views (Footer)
    
    func collectionView(_ collectionView: UICollectionView,
                       viewForSupplementaryElementOfKind kind: String,
                       at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: WJPermissionFooterView.reuseIdentifier,
                for: indexPath
            ) as? WJPermissionFooterView else {
                return UICollectionReusableView()
            }
            
            // 判断是权限问题还是相册为空
            let status = service.checkPermission()
            
            if status == .denied {
                // 权限被拒绝：显示权限提示
                footer.configure(
                    icon: configuration.permissionIcon,
                    message: configuration.permissionMessage,
                    buttonTitle: configuration.permissionButtonTitle
                )
                
                footer.onSettingsButtonTapped = { [weak self] in
                    self?.service.openSettings()
                }
            } else if status == .limited && photos.isEmpty {
                // 限制权限且没有照片：引导用户去设置开启完整权限
                footer.configure(
                    icon: configuration.limitedPermissionIcon ?? configuration.permissionIcon,
                    message: configuration.limitedPermissionMessage ?? "当前仅可访问部分照片，建议开启完整相册权限以获得更好体验",
                    buttonTitle: configuration.limitedPermissionButtonTitle ?? configuration.permissionButtonTitle
                )
                
                footer.onSettingsButtonTapped = { [weak self] in
                    self?.service.openSettings()
                }
            } else if status == .authorized && photos.isEmpty {
                // 有完整权限但没有系统照片：显示空相册提示
                footer.configure(
                    icon: configuration.emptyAlbumIcon,
                    message: configuration.emptyAlbumMessage,
                    buttonTitle: configuration.emptyAlbumButtonTitle
                )
                
                footer.onSettingsButtonTapped = { [weak self] in
                    // 可选：空相册按钮的回调（例如跳转到相机）
                    self?.openCamera()
                }
            } else {
                // 其他情况：不显示 footer（通过返回空视图）
                return UICollectionReusableView()
            }
            
            return footer
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: - Configure Cells
    
    private func configureCameraCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = photoGridCollectionView.dequeueReusableCell(
            withReuseIdentifier: WJCameraCell.reuseIdentifier,
            for: indexPath
        ) as? WJCameraCell else {
            return UICollectionViewCell()
        }
        cell.configure(title: configuration.cameraTitle)
        return cell
    }
    
    private func configureGalleryCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = photoGridCollectionView.dequeueReusableCell(
            withReuseIdentifier: WJGalleryCell.reuseIdentifier,
            for: indexPath
        ) as? WJGalleryCell else {
            return UICollectionViewCell()
        }
        cell.configure(title: configuration.galleryTitle)
        return cell
    }
    
    private func configureSampleImageCell(at indexPath: IndexPath, item: WJSampleImageItem, index: Int) -> UICollectionViewCell {
        guard let cell = photoGridCollectionView.dequeueReusableCell(
            withReuseIdentifier: WJSampleImageCell.reuseIdentifier,
            for: indexPath
        ) as? WJSampleImageCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: item)
        
        // 恢复选中状态
        if selectedSampleImages.contains(index) {
            photoGridCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        
        return cell
    }
    
    private func configurePhotoCell(at indexPath: IndexPath, asset: PHAsset) -> UICollectionViewCell {
        guard let cell = photoGridCollectionView.dequeueReusableCell(
            withReuseIdentifier: WJPhotoGridCell.reuseIdentifier,
            for: indexPath
        ) as? WJPhotoGridCell else {
            return UICollectionViewCell()
        }
        
        let scale = UIScreen.main.scale
        let cellSize = (photoGridCollectionView.bounds.width - configuration.gridSpacing * CGFloat(configuration.numberOfColumns - 1)) / CGFloat(configuration.numberOfColumns)
        let targetSize = CGSize(width: cellSize * scale, height: cellSize * scale)
        
        cell.configure(with: asset, targetSize: targetSize)
        
        // 恢复选中状态
        if selectedAssets.contains(asset) {
            photoGridCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension WJPhotoPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 根据 PhotoGridItem 类型处理选择
        let item = gridItems[indexPath.item]
        
        switch item {
        case .camera:
            handleCameraSelection(at: indexPath)
            
        case .gallery:
            handleGallerySelection(at: indexPath)
            
        case .sampleImage(let sampleItem, let index):
            handleSampleImageSelection(item: sampleItem, index: index, indexPath: indexPath)
            
        case .photo(let asset):
            handlePhotoSelection(asset: asset, indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // 根据 PhotoGridItem 类型处理取消选择
        let item = gridItems[indexPath.item]
        
        switch item {
        case .camera:
            break  // 相机不需要处理取消选择
            
        case .gallery:
            break  // Gallery 不需要处理取消选择
            
        case .sampleImage(_, let index):
            selectedSampleImages.remove(index)
            updateDoneButtonState()
            
        case .photo(let asset):
            selectedAssets.remove(asset)
            updateDoneButtonState()
        }
    }
    
    // MARK: - Selection Handlers
    
    private func handleCameraSelection(at indexPath: IndexPath) {
        openCamera()
        photoGridCollectionView.deselectItem(at: indexPath, animated: true)
    }
    
    private func handleGallerySelection(at indexPath: IndexPath) {
        // 使用 PHPickerViewController 打开系统照片选择器
        // 优点：不需要权限，不会弹出系统提示框，用户体验更好
        if #available(iOS 14, *) {
            presentPHPicker()
        }
        photoGridCollectionView.deselectItem(at: indexPath, animated: true)
    }
    
    @available(iOS 14, *)
    private func presentPHPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        
        // 设置选择数量限制
        if configuration.allowsMultipleSelection {
            config.selectionLimit = configuration.maxSelectionCount
        } else {
            config.selectionLimit = 1
        }
        
        // 只选择图片
        config.filter = .images
        
        // 设置选择模式（iOS 15+）
        if #available(iOS 15, *) {
            config.selection = .ordered
        }
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func handleSampleImageSelection(item: WJSampleImageItem, index: Int, indexPath: IndexPath) {
        // 单选模式：直接回调并关闭
        if !configuration.allowsMultipleSelection {
            onSampleImagesCompleted?([item])
            dismiss(animated: true, completion: nil)
            return
        }
        
        // 多选模式
        if selectedSampleImages.contains(index) {
            selectedSampleImages.remove(index)
            photoGridCollectionView.deselectItem(at: indexPath, animated: true)
        } else {
            // 检查是否超过最大选择数
            let totalSelected = selectedAssets.count + selectedSampleImages.count
            if totalSelected >= configuration.maxSelectionCount {
                showMaxSelectionAlert()
                photoGridCollectionView.deselectItem(at: indexPath, animated: true)
                return
            }
            selectedSampleImages.insert(index)
        }
        
        onSampleImageSelected?(item)
        updateDoneButtonState()
    }
    
    private func handlePhotoSelection(asset: PHAsset, indexPath: IndexPath) {
        // 单选模式：直接回调并关闭
        if !configuration.allowsMultipleSelection {
            onPhotosSelected?([asset])
            dismiss(animated: true, completion: nil)
            return
        }
        
        // 多选模式
        if selectedAssets.contains(asset) {
            selectedAssets.remove(asset)
        } else {
            // 检查是否超过最大选择数
            let totalSelected = selectedAssets.count + selectedSampleImages.count
            if totalSelected >= configuration.maxSelectionCount {
                showMaxSelectionAlert()
                photoGridCollectionView.deselectItem(at: indexPath, animated: true)
                return
            }
            selectedAssets.insert(asset)
        }
        
        updateDoneButtonState()
    }
    
    private func showMaxSelectionAlert() {
        showAlert(
            title: "已达到最大选择数量",
            message: "最多只能选择 \(configuration.maxSelectionCount) 张照片"
        )
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension WJPhotoPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateItemSize(for: collectionView)
    }
    
    // MARK: - Helper: Calculate Item Size
    
    private func calculateItemSize(for collectionView: UICollectionView) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let columns = CGFloat(calculateColumns(for: screenWidth))
        let spacing: CGFloat = 5  // 间距 5px
        let margins: CGFloat = 16 * 2  // 左右边距各 16px
        
        let totalSpacing = (columns - 1) * spacing + margins
        let itemWidth = (screenWidth - totalSpacing) / columns
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    private func calculateColumns(for width: CGFloat) -> Int {
        // 优先使用外部配置
        if let custom = configuration.gridColumns {
            return custom
        }
        
        // 自动计算: 375+ 为 4列, <375 为 3列
        return width >= 375 ? 4 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5  // 间距 5px
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5  // 间距 5px
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)  // 左右边距 16px
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       referenceSizeForFooterInSection section: Int) -> CGSize {
        
        // 只在 photoGridCollectionView 显示 footer
        guard collectionView == photoGridCollectionView else {
            return .zero
        }
        
        let status = service.checkPermission()
        
        // 情况1: 权限被拒绝
        if status == .denied {
            return CGSize(width: collectionView.bounds.width, height: 300)
        }
        
        // 情况2: 限制权限且没有照片
        if status == .limited && photos.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 300)
        }
        
        // 情况3: 有完整权限但没有系统照片（显示空相册提示）
        if status == .authorized && photos.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 300)
        }
        
        return .zero
    }
}

// MARK: - UIImagePickerControllerDelegate

extension WJPhotoPickerViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if let image = info[.originalImage] as? UIImage {
                // 调用拍照完成回调，直接返回UIImage
                self.onCameraImageCaptured?(image)
                
                // ⭐ 拍照完成后，无论单选还是多选，都关闭整个自定义相册选择器
                // 这样可以让调用方直接获得拍摄的图片
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate (滚动联动)

extension WJPhotoPickerViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // FloatingPanel 会自动处理滚动联动，这里可以添加其他自定义逻辑
        // 例如：根据滚动位置调整动图效果等
    }
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14, *)
extension WJPhotoPickerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        // 如果用户取消选择
        guard !results.isEmpty else { return }
        
        // 处理选中的照片
        var selectedImages: [UIImage] = []
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            
            // 加载图片
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                defer { group.leave() }
                
                if let image = object as? UIImage {
                    selectedImages.append(image)
                }
            }
        }
        
        // 所有图片加载完成后回调
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            if !selectedImages.isEmpty {
                // 使用 onCameraImageCaptured 回调返回图片
                // 注意：PHPicker 返回的是 UIImage，不是 PHAsset
                if self.configuration.allowsMultipleSelection {
                    // 多选模式：依次调用回调
                    for image in selectedImages {
                        self.onCameraImageCaptured?(image)
                    }
                } else {
                    // 单选模式：返回第一张图片
                    if let firstImage = selectedImages.first {
                        self.onCameraImageCaptured?(firstImage)
                    }
                }
                
                // 关闭选择器
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
