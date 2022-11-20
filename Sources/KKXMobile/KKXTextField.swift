//
//  KKXTextField.swift
//  KKXMobile
//
//  Created by ming on 2021/5/11.
//

import UIKit

open class KKXTextField: UITextField {
    
    public enum State {
        case normal
        case marked
        case focus
    }
    
    open var textState: State = .normal {
        didSet {
            reloadTextState()
        }
    }
    
    private func reloadTextState() {
        if let color = textColors[textState] {
            textColor = color
        }
        if let color = borderColors[textState] {
            layer.borderColor = color.cgColor
        }
    }
    
    public func textColor(for editState: State) -> UIColor? {
        textColors[editState]
    }
    public func setTextColor(_ color: UIColor?, for editState: State) {
        textColors[editState] = color
        reloadTextState()
    }
    private var textColors: [State: UIColor] = [:]
    
    public func borderColor(for editState: State) -> UIColor? {
        borderColors[editState]
    }
    public func setBorderColor(_ color: UIColor?, for editState: State) {
        borderColors[editState] = color
        reloadTextState()
    }
    private var borderColors: [State: UIColor] = [:]
    
    /// 文本是否可以长按编辑， 如果设置为false，只能copy操作，默认 true
    open var canEdit: Bool = true
    
    /// 默认false
    open var shouldFocus: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidEndEditingNotification, object: nil)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configurations()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurations()
    }
    
    open func configurations() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidBegainHandler(_:)), name: UITextField.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndHandler(_:)), name: UITextField.textDidEndEditingNotification, object: self)
    }
    
    @objc private func textDidBegainHandler(_ sender: Notification) {
        if shouldFocus {
            textState = .focus
        }
    }
    
    @objc private func textDidEndHandler(_ sender: Notification) {
        if shouldFocus {
            textState = .normal
        }
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !canEdit && action != #selector(copy(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if textAlignment == .center {
            leftViewRect(forBounds: bounds)
        }
        return super.placeholderRect(forBounds: bounds)
    }
}
