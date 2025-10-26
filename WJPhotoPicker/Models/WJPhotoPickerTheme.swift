//
//  WJPhotoPickerTheme.swift
//  WJPhotoPicker
//
//  Created by Cascade on 2025/10/24.
//

import UIKit

/// 相册选择器主题配置
public struct WJPhotoPickerTheme {
    
    // MARK: - 主题色
    
    /// 主题色 (可外部配置)
    public var primaryColor: UIColor
    
    /// 主题渐变色 (可选)
    public var primaryGradientColors: [UIColor]?
    
    // MARK: - 深色主题配色
    
    public struct DarkColors {
        /// 主背景色
        public var background: UIColor
        
        /// 卡片背景色
        public var cardBackground: UIColor
        
        /// 主文字颜色
        public var primaryText: UIColor
        
        /// 次级文字颜色
        public var secondaryText: UIColor
        
        /// 三级文字颜色
        public var tertiaryText: UIColor
        
        /// 分隔线颜色
        public var separator: UIColor
        
        public init(
            background: UIColor = UIColor(hex: "#1A0A2E"),
            cardBackground: UIColor = UIColor(hex: "#312539"),
            primaryText: UIColor = .white,
            secondaryText: UIColor = UIColor(white: 1.0, alpha: 0.7),
            tertiaryText: UIColor = UIColor(white: 1.0, alpha: 0.5),
            separator: UIColor = UIColor(white: 1.0, alpha: 0.2)
        ) {
            self.background = background
            self.cardBackground = cardBackground
            self.primaryText = primaryText
            self.secondaryText = secondaryText
            self.tertiaryText = tertiaryText
            self.separator = separator
        }
    }
    
    // MARK: - 浅色主题配色
    
    public struct LightColors {
        /// 主背景色
        public var background: UIColor
        
        /// 卡片背景色
        public var cardBackground: UIColor
        
        /// 主文字颜色
        public var primaryText: UIColor
        
        /// 次级文字颜色
        public var secondaryText: UIColor
        
        /// 三级文字颜色
        public var tertiaryText: UIColor
        
        /// 分隔线颜色
        public var separator: UIColor
        
        public init(
            background: UIColor = UIColor(hex: "#F5F5F7"),
            cardBackground: UIColor = .white,
            primaryText: UIColor = UIColor(hex: "#1D1D1F"),
            secondaryText: UIColor = UIColor(hex: "#6E6E73"),
            tertiaryText: UIColor = UIColor(hex: "#AEAEB2"),
            separator: UIColor = UIColor(hex: "#E5E5EA")
        ) {
            self.background = background
            self.cardBackground = cardBackground
            self.primaryText = primaryText
            self.secondaryText = secondaryText
            self.tertiaryText = tertiaryText
            self.separator = separator
        }
    }
    
    // MARK: - Properties
    
    public var darkColors: DarkColors
    public var lightColors: LightColors
    
    // MARK: - Initialization
    
    public init(
        primaryColor: UIColor,
        primaryGradientColors: [UIColor]? = nil,
        darkColors: DarkColors = DarkColors(),
        lightColors: LightColors = LightColors()
    ) {
        self.primaryColor = primaryColor
        self.primaryGradientColors = primaryGradientColors
        self.darkColors = darkColors
        self.lightColors = lightColors
    }
    
    // MARK: - Default Theme
    
    /// 默认主题 (紫色系)
    public static var `default`: WJPhotoPickerTheme {
        return WJPhotoPickerTheme(
            primaryColor: UIColor(hex: "#C74FFF"),
            primaryGradientColors: [
                UIColor(hex: "#C74FFF"),
                UIColor(hex: "#FF4FD8")
            ],
            darkColors: DarkColors(),
            lightColors: LightColors()
        )
    }
    
    // MARK: - Helper Methods
    
    /// 根据当前界面风格获取对应的颜色配置
    public func colors(for traitCollection: UITraitCollection) -> (
        background: UIColor,
        cardBackground: UIColor,
        primaryText: UIColor,
        secondaryText: UIColor,
        tertiaryText: UIColor,
        separator: UIColor
    ) {
        if traitCollection.userInterfaceStyle == .dark {
            return (
                darkColors.background,
                darkColors.cardBackground,
                darkColors.primaryText,
                darkColors.secondaryText,
                darkColors.tertiaryText,
                darkColors.separator
            )
        } else {
            return (
                lightColors.background,
                lightColors.cardBackground,
                lightColors.primaryText,
                lightColors.secondaryText,
                lightColors.tertiaryText,
                lightColors.separator
            )
        }
    }
}

// MARK: - UIColor Hex Extension

extension UIColor {
    public convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
