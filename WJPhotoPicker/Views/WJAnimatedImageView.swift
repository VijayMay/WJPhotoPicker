//
//  WJAnimatedImageView.swift
//  CustomPhotoPicker
//
//  Created by Meiwenjie on 2025/10/18.
//

import UIKit
import SDWebImage
import SnapKit

/// 支持动图展示的视图
class WJAnimatedImageView: UIView {
    
    // MARK: - Properties
    
    private let imageView: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.shouldCustomLoopCount = false
        view.shouldIncrementalLoad = true
        view.maxBufferSize = 10
        view.clearBufferWhenStopped = true
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    private let placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .systemGray6
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        observeMemoryWarning()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        observeMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(placeholderImageView)
        addSubview(imageView)
        addSubview(loadingIndicator)
        
        placeholderImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    /// 加载 WebP 动图（URL）
    func loadAnimatedImage(from url: URL?, placeholder: UIImage? = nil) {
        guard let url = url else {
            imageView.image = placeholder
            return
        }
        
        placeholderImageView.image = placeholder
        loadingIndicator.startAnimating()
        
        imageView.sd_setImage(
            with: url,
            placeholderImage: nil,
            options: [
                .retryFailed,
                .progressiveLoad,
                .scaleDownLargeImages,
                .avoidAutoSetImage
            ],
            progress: nil,
            completed: { [weak self] image, error, cacheType, url in
                guard let self = self else { return }
                
                self.loadingIndicator.stopAnimating()
                
                if error != nil {
                    self.imageView.image = placeholder
                    return
                }
                
                UIView.transition(
                    with: self.imageView,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.imageView.image = image
                        self.placeholderImageView.isHidden = true
                    },
                    completion: nil
                )
            }
        )
    }
    
    /// 加载本地 WebP 动图
    func loadAnimatedImage(named name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "webp"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let image = SDAnimatedImage(data: data) else {
            return
        }
        
        imageView.image = image
        placeholderImageView.isHidden = true
    }
    
    /// 加载本地 WebP 数据
    func loadAnimatedImage(data: Data) {
        guard let image = SDAnimatedImage(data: data) else {
            return
        }
        
        imageView.image = image
        placeholderImageView.isHidden = true
    }
    
    /// 停止动画
    func stopAnimating() {
        imageView.stopAnimating()
    }
    
    /// 开始动画
    func startAnimating() {
        imageView.startAnimating()
    }
    
    /// 清除图片
    func clear() {
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        placeholderImageView.image = nil
        placeholderImageView.isHidden = false
    }
    
    // MARK: - Private Methods
    
    private func observeMemoryWarning() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        SDImageCache.shared.clearMemory()
        stopAnimating()
    }
}
