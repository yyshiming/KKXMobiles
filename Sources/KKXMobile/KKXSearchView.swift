//
//  KKXSearchView.swift
//  KKXMobile
//
//  Created by ming on 2020/8/11.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

open class KKXSearchView: UIView {

    // MARK: -------- Properties --------
    
    public enum CancelButtonBehavior {
        case automatic
        case never
        case always
    }

    /// default is CancelButtonBehavior.automatic
    public var cancelButtonBehavior = CancelButtonBehavior.automatic {
        didSet {
            updateCancelButtonBehavior()
        }
    }
    
    public var cancelButtonClick: ((Bool) -> Void)?
    
    public override var tintColor: UIColor! {
        get { super.tintColor }
        set {
            super.tintColor = newValue
            textField.tintColor = newValue
            cancelButton.setAttributedTitle(cancelAttributedTitle(newValue), for: .normal)
        }
    }
    public let textField = KKXTextField()
    public let cancelButton = UIButton(type: .system)
    
    /// default is 30
    public var textFieldHeight: CGFloat = 30 {
        didSet {
            textFieldHeightConstraint?.constant = textFieldHeight
        }
    }
    
    /// default is UIEdgeInsets.zero
    public var contentInset: UIEdgeInsets {
        get { _contentInset }
        set {
            _contentInset = newValue
            textFieldLeftConstraint?.constant = newValue.left
            textFieldRightToSuperConstraint?.constant = -newValue.right
        }
    }
    
    // MARK: -------- Private Properties --------
    
    private var _contentInset = UIEdgeInsets.zero

    private var textFieldHeightConstraint: NSLayoutConstraint?
    private var textFieldLeftConstraint: NSLayoutConstraint?
    private var textFieldCenterYConstraint: NSLayoutConstraint?
    private var textFieldRightToSuperConstraint: NSLayoutConstraint?

    private var cancelButtonLeftConstraint: NSLayoutConstraint?
    private var cancelButtonRightConstraint: NSLayoutConstraint?
    
    // MARK: -------- Init --------
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidEndEditingNotification, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        configureSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    private func cancelAttributedTitle(_ color: UIColor = UIColor.kkxSystemBlue, font: UIFont = UIFont.systemFont(ofSize: 18)) -> NSAttributedString {
        NSAttributedString(
            string: KKXExtensionString("cancel"),
            attributes: [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: font
            ]
        )
    }
    
    // MARK: -------- Configure --------
    
    private func configureSubviews() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
        
        textField.layer.cornerRadius = 5.0
        textField.backgroundColor = UIColor.kkxGray
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.tintColor = UIColor.kkxSystemBlue
        addSubview(textField)

        cancelButton.clipsToBounds = true
        cancelButton.setAttributedTitle(cancelAttributedTitle(), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        addSubview(cancelButton)
        
        configureConstraints()
        updateCancelButtonBehavior()
    }
    
    private func configureConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        textFieldHeightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: textFieldHeight)
        textFieldHeightConstraint?.priority = UILayoutPriority(rawValue: 998)
        textFieldHeightConstraint?.isActive = true
        textFieldLeftConstraint = NSLayoutConstraint(item: textField, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: contentInset.left)
        textFieldLeftConstraint?.isActive = true
        textFieldCenterYConstraint = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: kkxSafeAreaInsets.top/2)
        textFieldCenterYConstraint?.isActive = true
        textFieldRightToSuperConstraint = NSLayoutConstraint(item: textField, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -contentInset.right)
        textFieldRightToSuperConstraint?.isActive = true
        
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: textField, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: textField, attribute: .height, multiplier: 1.0, constant: 0).isActive = true
        cancelButtonLeftConstraint = NSLayoutConstraint(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: textField, attribute: .right, multiplier: 1.0, constant: cancelButtonSpacing)
        cancelButtonLeftConstraint?.isActive = true
        cancelButtonRightConstraint = NSLayoutConstraint(item: cancelButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -cancelButtonSpacing)
        cancelButtonRightConstraint?.isActive = true
        
        cancelButton.alpha = 0
    }
    
    open override var intrinsicContentSize: CGSize {
        let width = kkxScreenBounds.width
        return CGSize(width: width, height: 44)
    }
    
    private func showCancelButton(_ animated: Bool = true) {
        cancelButton.isHidden = false
        textFieldRightToSuperConstraint?.isActive = false
        cancelButtonRightConstraint?.isActive = true
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.cancelButton.alpha = 1.0
                self.layoutIfNeeded()
            }
        } else {
            self.cancelButton.alpha = 1.0
            self.layoutIfNeeded()
        }
    }
    
    private func hideCancelButton(_ animated: Bool = true) {
        cancelButtonRightConstraint?.isActive = false
        textFieldRightToSuperConstraint?.isActive = true
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.cancelButton.alpha = 0.0
                self.layoutIfNeeded()
            }
        } else {
            self.cancelButton.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
    
    private func updateCancelButtonBehavior() {
        switch cancelButtonBehavior {
        case .automatic:
            if textField.isFirstResponder {
                showCancelButton(false)
            } else {
                hideCancelButton(false)
            }
        case .never:
            hideCancelButton(false)
        case .always:
            showCancelButton(false)
        }
    }
    
    // MARK: -------- Actions --------
    
    @objc private func textFieldDidBeginEditing(_ sender: Notification) {
        if let tf = sender.object as? UITextField,
           tf == textField,
           cancelButtonBehavior == .automatic {
            showCancelButton()
        }
    }
    
    @objc private func textFieldDidEndEditing(_ sender: Notification) {
        if let tf = sender.object as? UITextField,
           tf == textField,
           cancelButtonBehavior == .automatic {
            hideCancelButton()
        }
    }
    
    @objc private func cancelAction() {
        cancelButtonClick?(textField.isFirstResponder)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        textField.layer.borderColor = UIColor.kkxSeparator.cgColor
    }
    
    // MARK: -------- Layout --------
    
    private let cancelButtonSpacing: CGFloat = 15
    
    @available(iOS 11.0, *)
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        textFieldCenterYConstraint?.constant = kkxSafeAreaInsets.top/2
    }
}

public protocol KKXCustomSearchView {
    var searchView: KKXSearchView { get }
}
extension KKXCustomSearchView {
    public var searchView: KKXSearchView {
        guard let searchView = objc_getAssociatedObject(self, &searchViewKey) as? KKXSearchView
        else {
            let searchView = KKXSearchView()
            objc_setAssociatedObject(self, &searchViewKey, searchView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return searchView
        }
        return searchView
    }
}
private var searchViewKey: UInt8 = 0
