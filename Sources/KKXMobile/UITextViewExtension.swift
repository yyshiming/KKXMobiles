//
//  UITextViewExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/11.
//

import UIKit

extension UITextView {
    
    /// 添加监听text改变方法回调
    /// - Parameter handler: 回调
    /// - Returns: Self
    @discardableResult
    public func onTextChanged(handler: @escaping (String) -> Void) -> Self {
        textObservation.textDidChanged = handler
        return self
    }
    
    private var textObservation: KKXTextObservation {
        guard let observer = objc_getAssociatedObject(self, &observerKey) as? KKXTextObservation else {
            let observer = KKXTextObservation()
            objc_setAssociatedObject(self, &observerKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            observer.addObserver(UITextView.textDidChangeNotification, object: self) { sender in
                let textView = sender.object as? UITextView
                let text = textView?.text ?? ""
                textView?.placeholderLabel.isHidden = !text.isEmpty
                observer.textDidChanged?(text)
            }
            let observation = observe(\.text) { (object, _) in
                let text = object.text ?? ""
                self.placeholderLabel.isHidden = !text.isEmpty
                observer.textDidChanged?(text)
            }
            observer.observations.append(observation)
            return observer
        }
        return observer
    }
}

extension UITextView {
    
    public enum PlaceholderAlignment {
        case left
        case right
    }
    
    /// 添加占位字符串
    /// - Parameters:
    ///   - text: 字符串
    ///   - textColor: 字符串颜色
    ///   - alignment: 对齐方式
    /// - Returns: Self
    @discardableResult
    public func placeholder(text: String, textColor: UIColor = .kkxPlaceholderText, alignment: PlaceholderAlignment = .left) -> Self {
        placeholderLabel.text = text
        placeholderLabel.textColor = textColor
        placeholderAlignment = alignment
        configurePlaceholderLabel()
        return self
    }
    
    private var placeholderAlignment: PlaceholderAlignment {
        get {
            let alignment = objc_getAssociatedObject(self, &alignmentKey) as? PlaceholderAlignment
            return alignment ?? .left
        }
        set {
            objc_setAssociatedObject(self, &alignmentKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var placeholderLabel: UILabel {
        guard let label = objc_getAssociatedObject(self, &placeholderLabelKey) as? UILabel else {
            
            if font == nil {
                let pointSize: CGFloat = 16
                font = .systemFont(ofSize: pointSize)
            }
            
            let label = UILabel()
            label.numberOfLines = 0
            label.font = font
            addSubview(label)
            objc_setAssociatedObject(self, &placeholderLabelKey, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            let fontObservation = observe(\.font) { object, change in
                if let font = object.font {
                    object.placeholderLabel.font = .systemFont(ofSize: font.pointSize)
                }
            }
            textObservation.observations.append(fontObservation)

            let frameObservation = observe(\.frame, options: [.new, .old]) { object, change in
                guard change.newValue?.size != change.oldValue?.size else { return }
                self.configurePlaceholderLabel()
            }
            textObservation.observations.append(frameObservation)

            let boundsObservation = observe(\.bounds) { object, change in
                self.configurePlaceholderLabel()
            }
            textObservation.observations.append(boundsObservation)
            
            let textContainerInsetObservation = observe(\.textContainerInset) { object, change in
                self.configurePlaceholderLabel()
            }
            textObservation.observations.append(textContainerInsetObservation)
            
            let lineFragmentPaddingObservation = observe(\.textContainer.lineFragmentPadding) { object, change in
                self.configurePlaceholderLabel()
            }
            textObservation.observations.append(lineFragmentPaddingObservation)
            return label
        }
        return label
    }
    
    private func configurePlaceholderLabel() {
        var left = textContainer.lineFragmentPadding + textContainerInset.left
        let right = textContainer.lineFragmentPadding + textContainerInset.right
        placeholderLabel.frame.size.width = frame.width - left - right
        placeholderLabel.sizeToFit()
                
        if textAlignment == .right {
            left = frame.width - right - placeholderLabel.frame.width
        } else if textAlignment == .center {
            left = (frame.width - placeholderLabel.frame.width)/2
        }
        let maxHeight = frame.height - textContainerInset.top - textContainerInset.bottom
        placeholderLabel.frame.size.height = min(maxHeight, placeholderLabel.frame.height)
        placeholderLabel.frame.origin = CGPoint(x: left, y: textContainerInset.top)
    }
}
private var placeholderLabelKey: UInt8 = 0
private var alignmentKey: UInt8 = 0
private var observerKey: UInt8 = 0

