//
//  WJMediaPreviewView.swift
//  WJPhotoPicker
//
//  Created by Cascade on 2025/10/24.
//

import UIKit
import AVFoundation
import SDWebImage

/// 媒体预览视图 (支持 WebP 动图和 MP4 视频)
class WJMediaPreviewView: UIView {
    
    // MARK: - Properties
    
    enum MediaType {
        case webp
        case mp4
    }
    
    private var mediaType: MediaType = .webp
    private var autoPlay: Bool = true
    private var loopPlay: Bool = true
    
    // MARK: - UI Components
    
    private lazy var imageView: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isOpaque = true // 设置为不透明，使用背景色
        view.clearsContextBeforeDrawing = true
        view.tintAdjustmentMode = .normal // 禁用 tint 调整
        let bgColor = UIColor(hex: "#312539") // 使用滑块背景色
        view.backgroundColor = bgColor
        view.layer.backgroundColor = bgColor.cgColor
        return view
    }()
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var playerLooper: AVPlayerLooper?
    
    private lazy var placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .white.withAlphaComponent(0.5)
        let bgColor = UIColor(hex: "#312539") // 使用滑块背景色
        view.backgroundColor = bgColor
        view.layer.backgroundColor = bgColor.cgColor
        return view
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
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
    
    deinit {
        cleanupPlayer()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        let bgColor = UIColor(hex: "#312539") // 使用滑块背景色
        backgroundColor = bgColor
        layer.backgroundColor = bgColor.cgColor
        
        addSubview(placeholderImageView)
        addSubview(imageView)
        addSubview(loadingIndicator)
        
        placeholderImageView.frame = bounds
        placeholderImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        loadingIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
        loadingIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    // MARK: - Public Methods
    
    /// 更新背景颜色
    func updateBackgroundColor(_ color: UIColor) {
        backgroundColor = color
        layer.backgroundColor = color.cgColor
        imageView.backgroundColor = color
        imageView.layer.backgroundColor = color.cgColor
        placeholderImageView.backgroundColor = color
        placeholderImageView.layer.backgroundColor = color.cgColor
    }
    
    /// 加载 WebP 动图
    func loadWebP(url: URL?, placeholder: UIImage? = nil, autoPlay: Bool = true) {
        self.mediaType = .webp
        self.autoPlay = autoPlay
        
        cleanupPlayer()
        
        placeholderImageView.image = placeholder
        placeholderImageView.isHidden = false
        imageView.isHidden = false
        
        guard let url = url else {
            imageView.image = placeholder
            return
        }
        
        loadingIndicator.startAnimating()
        
        imageView.sd_setImage(with: url, placeholderImage: placeholder) { [weak self] image, error, _, _ in
            guard let self = self else { return }
            self.loadingIndicator.stopAnimating()
            self.placeholderImageView.isHidden = true
            
            // 重新设置背景色，防止被 SDWebImage 重置
            let currentBgColor = self.backgroundColor ?? UIColor(hex: "#312539")
            self.imageView.backgroundColor = currentBgColor
            self.imageView.layer.backgroundColor = currentBgColor.cgColor
            
            // 调试打印
            print("🎨 设置背景色: \(currentBgColor)")
            print("🎨 imageView.backgroundColor: \(String(describing: self.imageView.backgroundColor))")
            print("🎨 imageView.layer.backgroundColor: \(String(describing: self.imageView.layer.backgroundColor))")
            print("🎨 imageView.subviews.count: \(self.imageView.subviews.count)")
            print("🎨 imageView.layer.sublayers?.count: \(String(describing: self.imageView.layer.sublayers?.count))")
            print("🎨 imageView.image: \(String(describing: self.imageView.image))")
            
            // 检查并修改所有子视图的背景色
            for (index, subview) in self.imageView.subviews.enumerated() {
                print("🎨 子视图[\(index)].backgroundColor: \(String(describing: subview.backgroundColor))")
                subview.backgroundColor = currentBgColor
                subview.layer.backgroundColor = currentBgColor.cgColor
            }
            
            // 检查并修改所有子图层的背景色
            if let sublayers = self.imageView.layer.sublayers {
                for (index, sublayer) in sublayers.enumerated() {
                    print("🎨 子图层[\(index)].backgroundColor: \(String(describing: sublayer.backgroundColor))")
                    sublayer.backgroundColor = currentBgColor.cgColor
                }
            }
            
            // 强制刷新
            self.imageView.setNeedsDisplay()
            self.imageView.layer.setNeedsDisplay()
            
            if error != nil {
                print("❌ WebP 加载失败: \(error?.localizedDescription ?? "")")
            }
            
            if autoPlay {
                self.startAnimating()
            }
        }
    }
    
    /// 加载 WebP 动图 (本地数据)
    func loadWebP(data: Data?, placeholder: UIImage? = nil, autoPlay: Bool = true) {
        self.mediaType = .webp
        self.autoPlay = autoPlay
        
        cleanupPlayer()
        
        placeholderImageView.image = placeholder
        placeholderImageView.isHidden = false
        imageView.isHidden = false
        
        guard let data = data else {
            imageView.image = placeholder
            return
        }
        
        if let animatedImage = SDAnimatedImage(data: data) {
            imageView.image = animatedImage
            placeholderImageView.isHidden = true
            
            // 重新设置背景色，防止被重置
            let currentBgColor = backgroundColor ?? UIColor(hex: "#312539")
            imageView.backgroundColor = currentBgColor
            imageView.layer.backgroundColor = currentBgColor.cgColor
            
            // 修改所有子视图和子图层的背景色
            for subview in imageView.subviews {
                subview.backgroundColor = currentBgColor
                subview.layer.backgroundColor = currentBgColor.cgColor
            }
            if let sublayers = imageView.layer.sublayers {
                for sublayer in sublayers {
                    sublayer.backgroundColor = currentBgColor.cgColor
                }
            }
            
            if autoPlay {
                startAnimating()
            }
        } else {
            imageView.image = placeholder
        }
    }
    
    /// 加载 MP4 视频
    func loadMP4(url: URL?, placeholder: UIImage? = nil, autoPlay: Bool = true, loopPlay: Bool = true) {
        self.mediaType = .mp4
        self.autoPlay = autoPlay
        self.loopPlay = loopPlay
        
        imageView.isHidden = true
        placeholderImageView.image = placeholder
        placeholderImageView.isHidden = false
        
        guard let url = url else {
            return
        }
        
        loadingIndicator.startAnimating()
        
        setupPlayer(with: url)
        
        if autoPlay {
            startAnimating()
        }
    }
    
    /// 开始播放
    func startAnimating() {
        switch mediaType {
        case .webp:
            imageView.startAnimating()
        case .mp4:
            player?.play()
        }
    }
    
    /// 停止播放
    func stopAnimating() {
        switch mediaType {
        case .webp:
            imageView.stopAnimating()
        case .mp4:
            player?.pause()
        }
    }
    
    /// 是否正在播放
    var isAnimating: Bool {
        switch mediaType {
        case .webp:
            return imageView.isAnimating
        case .mp4:
            return player?.rate != 0
        }
    }
    
    // MARK: - Private Methods
    
    private func setupPlayer(with url: URL) {
        cleanupPlayer()
        
        let playerItem = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: playerItem)
        
        // 设置循环播放
        if loopPlay {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        }
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        layer.insertSublayer(playerLayer, at: 0)
        
        self.player = player
        self.playerLayer = playerLayer
        
        // 监听播放状态
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        // 监听加载状态
        playerItem.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
    }
    
    private func cleanupPlayer() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLooper?.disableLooping()
        
        NotificationCenter.default.removeObserver(self)
        
        player = nil
        playerLayer = nil
        playerLooper = nil
    }
    
    // MARK: - Observers
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .readyToPlay:
                    loadingIndicator.stopAnimating()
                    placeholderImageView.isHidden = true
                case .failed:
                    loadingIndicator.stopAnimating()
                    print("❌ MP4 加载失败: \(playerItem.error?.localizedDescription ?? "")")
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    @objc private func playerItemDidReachEnd() {
        if !loopPlay {
            player?.seek(to: .zero)
            player?.pause()
        }
    }
}
