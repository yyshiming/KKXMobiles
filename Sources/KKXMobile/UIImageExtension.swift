//
//  UIImageExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit


// MARK: - -------- 创建渐变图片 --------
extension UIImage {

    /// 获取渐变图片
    /// - Parameters:
    ///   - size: image size
    ///   - colors: default are nil
    ///   - startPoint: default are  (0.0, 0.5)
    ///   - endPoint: default are  (1.0, 0.5)
    ///   - type: values are `axial' (the default value), `radial', and `conic'
    /// - Returns: 渐变图片
    public class func gradient(with size: CGSize,
                               colors: [Any]? = nil,
                               startPoint: CGPoint = .init(x: 0.5, y: 0.0),
                               endPoint: CGPoint = .init(x: 0.5, y: 1.0),
                               locations: [CGFloat]? = nil,
                               type: CAGradientLayerType = .init(rawValue: "axial")) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        let allocator = CFAllocatorGetDefault().takeRetainedValue()
        let array = CFArrayCreateMutable(allocator, 0, nil)
        for color in colors ?? [] {
            if let c = color as? UIColor {
                let value = Unmanaged.passRetained(c.cgColor).autorelease().toOpaque()
                CFArrayAppendValue(array, value)
            } else {
                let c = color as! CGColor
                let value = Unmanaged.passRetained(c).autorelease().toOpaque()
                CFArrayAppendValue(array, value)
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let arr = array, let gradient = CGGradient(colorsSpace: colorSpace, colors: arr, locations: locations) {
            let start = CGPoint(x: size.width * startPoint.x, y: size.height * startPoint.y)
            let end = CGPoint(x: size.width * endPoint.x, y: size.height * endPoint.y)
            context?.drawLinearGradient(gradient, start: start, end: end, options: .drawsBeforeStartLocation)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}


// MARK: - -------- 在图片中绘制文字 --------
extension UIImage {
    
    /// 在图片中绘制文字
    /// - Parameters:
    ///   - infos: String 、NSAttributedString、UIImage
    /// - Returns: 绘制完成的图片
    public func drawText(_ infos: [(Any, CGRect)]) -> UIImage? {
        // 不要用UIGraphicsBeginImageContext(_ size: CGSize)，不然图片会模糊
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        for info in infos {
            if let attrString = info.0 as? NSAttributedString {
                attrString.draw(in: info.1)
            } else if let str = info.0 as? String {
                NSAttributedString(string: str).draw(in: info.1)
            } else if let image = info.0 as? UIImage {
                image.draw(in: info.1)
            } else {
                break
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - -------- 创建Arrow、Close图片 --------
extension UIImage {
    
    public struct ItemConfiguration {
        
        public enum Style: Int {
            case arrow = 0
            case close = 1
        }
        
        public enum Direction: Int {
            case up    = 0
            case down  = 1
            case left  = 2
            case right = 3
        }
        
        public static func arrowConfiguration() -> UIImage.ItemConfiguration {
            UIImage.ItemConfiguration()
        }
        
        public static func closeConfiguration() -> UIImage.ItemConfiguration {
            UIImage.ItemConfiguration(style: .close, width: 14.0)
        }
        
        /// Item配置
        /// - Parameters:
        ///   - style: 默认arrow
        ///   - direction: 方向（top，left，bottom，right），默认nil, ViewItem的style为arrow时，如果direction为nil，就显示为right
        ///   - lineWidth: 线段宽度，默认1.5
        ///   - tintColor: 箭头颜色，默认separator
        ///   - width: direction为left，right时为宽度，高度=宽度*2；direction为top，bottom时为高度，宽度=高度*2，默认6.5
        public init(style: UIImage.ItemConfiguration.Style = .arrow, direction: UIImage.ItemConfiguration.Direction? = nil, lineWidth: CGFloat = 1.5, tintColor: UIColor? = nil, width: CGFloat = 6.5) {
            self.style = style
            self.width = width
            self.lineWidth = lineWidth
            self.direction = direction
            self.tintColor = tintColor ?? UIImage.ItemConfiguration.defaultColor
        }
        
        public var style: UIImage.ItemConfiguration.Style
        /// 箭头方向，默认right
        public var direction: UIImage.ItemConfiguration.Direction?
        /// 线条宽度，默认1.5
        public var lineWidth: CGFloat
        /// 颜色，默认separator
        public var tintColor: UIColor
        /// 箭头宽度，默认6.5
        public var width: CGFloat
        
        private static var defaultColor: UIColor {
            if #available(iOS 13.0, *) {
                return .separator
            } else {
                return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.3)
            }
        }
    }
    
    /// Item图片(Arrow，Close)
    /// - Parameters:
    ///   - configuration: style
    /// - Returns: 图片
    public class func itemImage(with configuration: UIImage.ItemConfiguration? = nil) -> UIImage? {
        
        let config = configuration ?? .arrowConfiguration()
        
        let style = config.style
        let arrowWidth = config.width
        let lineWidth = config.lineWidth
        let tintColor = config.tintColor
        let direction = config.direction ?? .right

        var size: CGSize
        switch style {
        case .arrow:
            switch direction {
            case .up, .down:
                size = CGSize(width: arrowWidth * 2 - lineWidth, height: arrowWidth)
            case .left, .right:
                size = CGSize(width: arrowWidth, height: arrowWidth * 2 - lineWidth)
            }
        case .close:
            size = CGSize(width: arrowWidth, height: arrowWidth)
            break
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setStrokeColor(tintColor.cgColor)

        let centerX = size.width / 2
        let centerY = size.height / 2
        
        let hSpacing = (size.width - lineWidth) / 2
        let vSpacing = (size.height - lineWidth) / 2
        
        switch style {
        case .arrow:
            var startPoint = CGPoint.zero
            var middlePoint = CGPoint.zero
            var endPoint = CGPoint.zero
            
            switch direction {
            case .up:
                startPoint = CGPoint(x: centerX - hSpacing, y: centerY + vSpacing)
                middlePoint = CGPoint(x: centerX, y: centerY - vSpacing)
                endPoint = CGPoint(x: centerX + hSpacing, y: centerY + vSpacing)
            case .down:
                startPoint = CGPoint(x: centerX - hSpacing, y: centerY - vSpacing)
                middlePoint = CGPoint(x: centerX, y: centerY + vSpacing)
                endPoint = CGPoint(x: centerX + hSpacing, y: centerY - vSpacing)
            case .left:
                startPoint = CGPoint(x: centerX + hSpacing, y: centerY - vSpacing)
                middlePoint = CGPoint(x: centerX - hSpacing, y: centerY)
                endPoint = CGPoint(x: centerX + hSpacing, y: centerY + vSpacing)
            case .right:
                startPoint = CGPoint(x: centerX - hSpacing, y: centerY - vSpacing)
                middlePoint = CGPoint(x: centerX + hSpacing, y: centerY)
                endPoint = CGPoint(x: centerX - hSpacing, y: centerY + vSpacing)
            }
            context.move(to: startPoint)
            context.addLine(to: middlePoint)
            context.addLine(to: endPoint)
        case .close:
            let topLeft = CGPoint(x: centerX - hSpacing, y: centerY - vSpacing)
            let topRight = CGPoint(x: centerX + hSpacing, y: topLeft.y)
            let bottomLeft = CGPoint(x: topLeft.x, y: centerY + vSpacing)
            let bottomRight = CGPoint(x: topRight.x, y: bottomLeft.y)
            
            context.move(to: topLeft)
            context.addLine(to: bottomRight)
            context.move(to: topRight)
            context.addLine(to: bottomLeft)
        }
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - -------- pdfPage转Image --------
extension UIImage {
    
    /// pdfPage转UIImage
    /// - Parameters:
    ///   - pdfPage: pdfPage
    /// - Returns: UIImage
    public class func image(for pdfPage: CGPDFPage?) -> UIImage? {
        guard let pdfPage = pdfPage else {
            return nil
        }
        let pageRect = pdfPage.getBoxRect(.mediaBox)
        let contentSize = CGSize(width: floor(pageRect.width), height: floor(pageRect.height))
        UIGraphicsBeginImageContextWithOptions(contentSize, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.fill(pageRect)
         
        context.saveGState()
        context.translateBy(x: 0, y: contentSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.interpolationQuality = .high
        context.setRenderingIntent(.defaultIntent)
        context.drawPDFPage(pdfPage)
        context.restoreGState()
         
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

internal func Image(named name: String) -> UIImage? {
    guard name.count > 0 else {
        return nil
    }
    if #available(iOS 13.0, *) {
        return UIImage(named: name, in: Bundle.kkxMobile, with: nil)
    } else {
        var scale = Int(UIScreen.main.scale)
        if scale < 2 {
            scale = 2
        } else if scale > 3 {
            scale = 3
        }
        let resourceName = name + "@\(scale)x"
        if let path = Bundle.kkxMobile.path(forResource: resourceName, ofType: "png") {
            return UIImage(contentsOfFile: path)
        } else if let path = Bundle.kkxMobile.path(forResource: name, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}
