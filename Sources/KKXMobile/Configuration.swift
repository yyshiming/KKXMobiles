//
//  Configuration.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension KKX {
    
    public final class Configuration {
        
        public static let `default` = Configuration()
        
        public init() {
            
        }
        
        public let defaultBackImage = UIImage.itemImage(with: UIImage.ItemConfiguration(direction: .left, lineWidth: 2.0, tintColor: .kkxBlack, width: 12.0))

        public var languageCode: String?
        
        /// 主背景色，默认UIColor.white
        public var mainBackground: UIColor = .white

        /// 主题色， 默认UIColor.white
        public var themeColor: UIColor = .white
        
        /// 是否隐藏导航栏的阴影，默认false
        public var isHideNavigationBarShadowImage: Bool = false
        
        /// 自定义返回item图片，为nil是使用系统返回item， 默认为nil
        public var customBackBarButtonItemImage: UIImage? = nil
        
        /// 自定义返回item图片的insets，默认 UIEdgeInsets.zero
        public var customBackImageInsets = UIEdgeInsets.zero
        
        /// pad上是否支持转屏，默认false
        public var autorotateOnIpad = KKX.Autorotate(shouldAutorotate: false, supportedInterfaceOrientations: .portrait)

        /// 导航栏默认风格
        public var navigationBarStyle: KKXNavigationBarStyle = .default()
        
        /// 占位图颜色
        public var placeholderColor: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor(dynamicProvider: { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return UIColor(white: 0.3, alpha: 1.0)
                    }
                    else {
                        return UIColor(white: 0.9, alpha: 1.0)
                    }
                })
            } else {
                return UIColor(white: 0.9, alpha: 1.0)
            }
        }
        
        /// 图片占位图
        public var placeholderImage: UIImage? {
            get {
                if _placeholderImage == nil {
                    return placeholderColor.image
                }
                return _placeholderImage
            }
            set {
                _placeholderImage = newValue
            }
        }
        
        private var _placeholderImage: UIImage?
    }
    
    public struct Autorotate {
        public var shouldAutorotate: Bool = true
        public var supportedInterfaceOrientations: UIInterfaceOrientationMask = .all
        public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation = .portrait
    }

    public enum NavigationBarStyle {
        case `default`
        case theme
        case background
        case clear
    }
}

public extension UIColor {
    static let kkxTheme = defaultConfiguration.themeColor
    static let kkxMainBackground = defaultConfiguration.mainBackground
    static let kkxPlaceholder = defaultConfiguration.placeholderColor
}

public extension UIImage {
    static let kkxPlaceholder = defaultConfiguration.placeholderImage
}

public var kkx_autorotateOnIpad: KKX.Autorotate {
    defaultConfiguration.autorotateOnIpad
}

internal let defaultConfiguration = KKX.Configuration.default
