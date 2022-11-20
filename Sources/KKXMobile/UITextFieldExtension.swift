//
//  UITextFieldExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/11.
//

import UIKit

extension UITextField {

    /// 添加监听text改变方法回调
    /// - Parameter handler: 回调
    /// - Returns: Self
    @discardableResult
    public func onTextChanged(handler: @escaping (String) -> Void) -> Self {
        textObservation.textDidChanged = handler
        return self
    }
    
    private var textObservation: KKXTextObservation {
        guard let observer = objc_getAssociatedObject(self, &textObservationKey) as? KKXTextObservation else {
            let observer = KKXTextObservation()
            objc_setAssociatedObject(self, &textObservationKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            observer.addObserver(UITextField.textDidChangeNotification, object: self) { sender in
                let textField = sender.object as? UITextField
                let text = textField?.text ?? ""
                observer.textDidChanged?(text)
            }
            let observation = observe(\.text) { (textField, _) in
                let text = textField.text ?? ""
                observer.textDidChanged?(text)
            }
            observer.observations.append(observation)
            return observer
        }
        return observer
    }
}
private var textObservationKey: UInt8 = 0

public class KKXTextObservation {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public var observations: [NSKeyValueObservation] = []
    public var textDidChanged: ((String) -> Void)?
    private var handler: ((Notification) -> Void)?
    
    public func addObserver(_ name: Notification.Name,
                            object anObject: Any?,
                            handler: @escaping (Notification) -> Void) {
        self.handler = handler
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged(_:)), name: name, object: anObject)
    }
    
    @objc private func textDidChanged(_ sender: Notification) {
        handler?(sender)
    }
}
