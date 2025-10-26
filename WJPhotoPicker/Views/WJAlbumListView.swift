//
//  WJAlbumListView.swift
//  WJPhotoPicker
//
//  Created by Cascade on 2025/10/26.
//

import UIKit
import Photos
import SnapKit

/// 相册列表视图 - 纯粹的相册选择组件，可在任何项目中复用
class WJAlbumListView: UIView {
    
    // MARK: - Properties
    
    /// 相册列表
    var albums: [WJPhotoAlbum] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    /// 当前选中的相册
    var selectedAlbum: WJPhotoAlbum?
    
    /// 相册选择回调
    var onAlbumSelected: ((WJPhotoAlbum) -> Void)?
    
    /// 取消选择回调（点击空白区域）
    var onDismiss: (() -> Void)?
    
    // MARK: - UI Components
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#312539") // 与滑块相同的背景色
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .singleLine
        table.separatorColor = UIColor(white: 1.0, alpha: 0.1)
        table.separatorInset = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 16)
        table.rowHeight = 60
        table.delegate = self
        table.dataSource = self
        table.register(WJAlbumCell.self, forCellReuseIdentifier: WJAlbumCell.reuseIdentifier)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return table
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(backgroundView)
        addSubview(tableView)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加点击手势（点击空白区域关闭）
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.delegate = self
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleBackgroundTap() {
        onDismiss?()
    }
    
    // MARK: - Public Methods
    
    /// 显示相册列表
    func show(in containerView: UIView, topOffset: CGFloat, bottomOffset: CGFloat) {
        containerView.addSubview(self)
        
        snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topOffset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomOffset)
        }
        
        // 强制布局
        containerView.layoutIfNeeded()
        
        // 使用 clipsToBounds 实现从工具栏下方展开的效果
        self.clipsToBounds = true
        
        // 保存最终高度
        let finalHeight = self.frame.height
        
        // 初始状态：高度为 0（从工具栏下方开始）
        self.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-bottomOffset - finalHeight)
        }
        containerView.layoutIfNeeded()
        
        // 动画展开到完整高度
        self.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-bottomOffset)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            containerView.layoutIfNeeded()
        })
    }
    
    /// 隐藏相册列表
    func hide(completion: (() -> Void)? = nil) {
        // 获取当前的 bottomOffset
        let currentHeight = self.frame.height
        
        // 动画收缩高度到 0
        self.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(currentHeight)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }
}

// MARK: - UITableViewDataSource

extension WJAlbumListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WJAlbumCell.reuseIdentifier, for: indexPath) as? WJAlbumCell else {
            return UITableViewCell()
        }
        
        let album = albums[indexPath.row]
        let isSelected = album.assetCollection.localIdentifier == selectedAlbum?.assetCollection.localIdentifier
        cell.configure(album: album, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WJAlbumListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        onAlbumSelected?(album)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension WJAlbumListView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 只有点击背景时才触发，点击 tableView 不触发
        return touch.view == backgroundView
    }
}
