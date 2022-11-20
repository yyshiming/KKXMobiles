//
//  Convenient.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit
import UserNotifications

/// 当前设备屏与对应的设备，屏幕宽度比例
struct Scale {
    
    /// 当前设备屏与iPhoneX，屏幕宽度比例
    public static let iPhoneX = UIScreen.main.bounds.width/375.0
}

public func kkxFit(_ x: CGFloat) -> CGFloat {
    return x * Scale.iPhoneX
}

extension CGFloat {
    
    public var kkxFit: CGFloat {
        return self * Scale.iPhoneX
    }
}

extension CGFloat {
    
    /// one pixel
    public static let pixel = 1.0/UIScreen.main.scale
}

/// 设备类型是否是pad
public var isPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

@available(iOS 13.0, *)
public var kkxWindowScene: UIWindowScene? {
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    return windowScene
}

public var kkxKeyWindow: UIWindow? {
    if #available(iOS 15.0, *) {
        return kkxWindowScene?.keyWindow
    } else if #available(iOS 13.0, *) {
        return kkxWindowScene?.windows.first
    } else {
        return UIApplication.shared.keyWindow
    }
}

public var kkxWindow: UIWindow? {
    if #available(iOS 13.0, *) {
        return kkxWindowScene?.windows.first
    } else {
        return UIApplication.shared.windows.first
    }
}

/// 获取屏幕bounds
public var kkxScreenBounds: CGRect {
    var bounds: CGRect?
    if #available(iOS 13.0, *) {
        bounds = kkxWindow?.screen.bounds
    } else {
        bounds = UIScreen.main.bounds
    }
    return bounds ?? .zero
}

/// keyWindow安全区域
///
///     状态栏没有隐藏时
///     iPhone X:
///     UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
///     其他：
///     UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
public var kkxWindowSafeAreaInsets: UIEdgeInsets {
    var insets: UIEdgeInsets = .zero
    if #available(iOS 11.0, *) {
        insets = kkxKeyWindow?.safeAreaInsets ?? .zero
    }
    return insets
}

public func kkxCall(_ phoneNumber: String) {
    if let url = URL(string: "telprompt://" + phoneNumber) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

/// 获取目前屏幕中显示的viewController
public var kkxTopViewController: UIViewController? {
    var controller = kkxKeyWindow?.rootViewController
    while true {
        if let presentedControler = controller?.presentedViewController {
            controller = presentedControler
        }
        else if let topViewController = (controller as? UINavigationController)?.topViewController {
            controller = topViewController
        }
        else if let selectedController = (controller as? UITabBarController)?.selectedViewController {
            controller = selectedController
        }
        else {
            break
        }
    }
    return controller
}

public enum PriceFormatStyle {
    /// 自动根据金额，判断需要保留几位小数
    case adjustment
    /// 直接保留d位小数
    case digits(d: Int)
}

/// 根据金额（分）返回format
/// - Parameter price: 金额（分）
/// - Parameter style: adjustment  | digits，默认adjustment
/// - Returns: format
public func kkxFormat(forPrice price: Int, style: PriceFormatStyle = .adjustment) -> String {
    let digits: Int
    switch style {
    case .adjustment:
        if (price % 100 == 0) {
            digits = 0
        } else if (price % 10 == 0) {
            digits = 1
        } else {
            digits = 2
        }
    case .digits(let d):
        digits = d
    }
    let format = "%.\(digits)f"
    return format
}

/// 注册推送通知
public func registerRemoteNotifications(_ delegate: UNUserNotificationCenterDelegate) {
    if #available(iOS 10.0, *) {
        let center = UNUserNotificationCenter.current()
        center.delegate = delegate
        let options = UNAuthorizationOptions.badge.rawValue | UNAuthorizationOptions.sound.rawValue | UNAuthorizationOptions.alert.rawValue
        center.requestAuthorization(options: UNAuthorizationOptions(rawValue: options)) { (granted, error) in
            if granted {
                DispatchQueue.kkx_safe {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else {
                DispatchQueue.kkx_safe {
                    kkxPrint("请开启推送功能否则无法收到推送通知")
                }
            }
        }
    } else {
        let types = UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.alert.rawValue
        let settings = UIUserNotificationSettings(types: UIUserNotificationType(rawValue: types), categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
}

/// 从storyboard获取viewController
/// - Parameter withName: stroyboard name
/// - Parameter forClass: class(stroyboard id必须设置为class的名字)
public func controllerInStoryboard<T: UIViewController>(_ withName: KKXStoryboardName, forClass: T.Type) -> T {
    let identifier = NSStringFromClass(forClass).components(separatedBy: ".").last
    let storyboard = UIStoryboard(name: withName.rawValue, bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: identifier!) as! T
    return controller
}

public struct KKXStoryboardName {
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct KKXCacheUnit {
    static let B = 1024
    static let KB = 1024 * KKXCacheUnit.B
    static let MB = 1024 * KKXCacheUnit.KB
    static let GB = 1024 * KKXCacheUnit.MB
}

public func sizeString<T: BinaryInteger>(_ size: T) -> String {
    if size > KKXCacheUnit.MB {
        return String(format: "%.1fGB", Float(size)/Float(KKXCacheUnit.MB))
    } else if size > KKXCacheUnit.KB {
        return String(format: "%.1fMB", Float(size)/Float(KKXCacheUnit.KB))
    } else if size > KKXCacheUnit.B {
        return String(format: "%.1fKB", Float(size)/Float(KKXCacheUnit.B))
    } else {
        return String(format: "%.1fB", Float(size))
    }
}

/// DEBUG环境打印
public func kkxPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items, separator, terminator)
    #endif
}

/// DEBUG环境打印
public func kkxDebugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    debugPrint(items, separator, terminator)
    #endif
}

// MARK: - ======== LocalizedString ========
public func KKXExtensionString(_ key: String, comment: String = "") -> String {
    return NSLocalizedString(key, bundle: Bundle.kkxMobile, comment: comment)
}
