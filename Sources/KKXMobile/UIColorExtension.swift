//
//  UIColorExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension UIColor {
    
    /// 单色转换为image
    public var image: UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 单色转换为image
    public func image(_ size: CGSize = .init(width: 1.0, height: 1.0), radius: CGFloat = 0, corners: UIRectCorner = .allCorners, strokeColor: UIColor? = nil) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(self.cgColor)
        if let strokeColor = strokeColor {
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineWidth(.pixel)
        }
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        context.addPath(path.cgPath)
        context.drawPath(using: .fillStroke)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let w = size.width/2
        let h = size.height/2
        let insets = UIEdgeInsets(top: h-1, left: w-1, bottom: h, right: w)
        let resizeImage = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    public convenience init?(red: UInt32, green: UInt32, blue: UInt32, transparent: CGFloat = 1) {
        let r = min(max(red, 0), 255)
        let g = min(max(green, 0), 255)
        let b = min(max(blue, 0), 255)
        let t = min(max(transparent, 0), 1)
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: t)
    }
    
    /// hexString: 0xFFFF, #EEEEEE, DDDDDD
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string = hexString.replacingOccurrences(of: "0x", with: "")
        }
        else if hexString.lowercased().hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        }
        else {
            string = hexString
        }
        
        if string.count == 3 {
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }
        
        guard let hex = UInt32(string, radix: 16) else {
            return nil
        }
        
        var trans = alpha
        trans = min(max(trans, 0), 1)
        
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: red, green: green, blue: blue, transparent: trans)
    }
    
    /// hex: 0xFFFFFF
    public convenience init?(hex: UInt32, alpha: CGFloat = 1.0) {
        var trans = alpha
        trans = min(max(trans, 0), 1)
        
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: red, green: green, blue: blue, transparent: trans)
    }
    
    /// 创建一个RGBA color
    /// - Parameters:
    ///   - r: 0 - 255
    ///   - g: 0 - 255
    ///   - b: 0 - 255
    ///   - a: 0 - 1
    /// - Returns: UIColor
    public static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
}

/// systemGray    dark:  #8E8E93 (142, 142, 147) light:  #8E8E93 (142, 142, 147)
/// systemGray2  dark:  #636366 (99, 99, 102)      light:  #8E8E93 (174, 174, 178)
/// systemGray3  dark:  #48484A (72, 72, 74)        light:  #8E8E93 (199, 199, 204)
/// systemGray4  dark:  #3A3A3C (58, 58, 60)       light:  #8E8E93 (209, 209, 204)
/// systemGray5  dark:  #2C2C2E (44, 44, 46)       light:  #8E8E93 (229, 229, 234)
/// systemGray6  dark:  #1C1C1E (28, 28, 30)       light:  #8E8E93 (242, 242, 247)
///
/// systemBlue    dark: #0A84FF (10, 132, 255) light: #007AFF(0, 122, 255)
extension UIColor {

    public class var kkxCard: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return .systemGray6
                }
                else {
                    return .white
                }
            })
        } else {
            return .white
        }
    }
    
    public class var kkxCard1: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return .systemGray5
                }
                else {
                    return .white
                }
            })
        } else {
            return .white
        }
    }
    
    public class var kkxGray1: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray
        } else {
            return UIColor(red: 142.0/255.0, green: 142.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        }
    }
    
    public class var kkxGray2: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray2
        } else {
            return UIColor(red: 174.0/255.0, green: 174.0/255.0, blue: 178.0/255.0, alpha: 1.0)
        }
    }
    
    public class var kkxGray3: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray3
        } else {
            return UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        }
    }
    
    public class var kkxGray4: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray4
        } else {
            return UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 214.0/255.0, alpha: 1.0)
        }
    }
    
    public class var kkxGray5: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray5
        } else {
            return UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        }
    }
    
    public class var kkxGray6: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray6
        } else {
            return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        }
    }
    
    public class var kkxSecondary: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.6)
        }
    }
    
    public class var kkxTertiary: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiaryLabel
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.3)
        }
    }
    
    public class var kkxQuaternary: UIColor {
        if #available(iOS 13.0, *) {
            return .quaternaryLabel
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.2)
        }
    }
    
    /// 黑色
    public class var kkxBlack: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    
    /// 黑色，0.8透明
    public class var kkxAlphaBlack: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label.withAlphaComponent(0.8)
        } else {
            return UIColor.black.withAlphaComponent(0.8)
        }
    }
    
    /// 白色
    public class var kkxWhite: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    
    public class var kkxTipLabel: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 240.0/255.0, alpha: 0.7)
                }
                else {
                    return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.7)
                }
            })
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.7)
        }
    }
    
    public class var kkxGray: UIColor {
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
    
    /// 占位符颜色
    ///
    ///
    ///     light: (60.0, 60.0, 67.0, 0.3)
    ///     dark: (235.0, 235.0, 245.0, 0.3)
    public class var kkxPlaceholderText: UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.3)
        }
    }
    
    /// 分割线、边框颜色
    ///
    ///
    ///     light: (60.0, 60.0, 67.0, 0.3)
    ///     dark: (84.0, 84.0, 88.0, 0.6)
    public class var kkxSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return .separator
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.3)
        }
    }
    
    /// 系统蓝色
    ///
    ///
    ///     light: (0.0, 122.0, 255.0, 1.0)
    ///     dark: (10.0, 132.0, 255.0, 1.0)
    public class var kkxSystemBlue: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBlue
        } else {
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
    }
    /// toolBar中item默认颜色
    ///
    ///     light：systemBlue
    ///     dark: white
    public class var kkxAccessoryBar: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return UIColor.white
                }
                else {
                    return UIColor.kkxSystemBlue
                }
            })
        } else {
            return UIColor.kkxSystemBlue
        }
    }
}
