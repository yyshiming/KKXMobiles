//
//  KKXInputView.swift
//  Demo
//
//  Created by ming on 2021/11/12.
//

import UIKit

open class KKXInputView: UIView {

    open override var inputView: UIView? {
        get { _inputView }
        set {
            _inputView = newValue
            isUserInteractionEnabled = true
        }
    }
    
    open override var inputAccessoryView: UIView? {
        get { _inputAccessoryView }
        set {
            _inputAccessoryView = newValue
        }
    }
    
    open override var inputViewController: UIInputViewController? {
        get { _inputViewController }
        set {
            _inputViewController = newValue
        }
    }
    
    open override var inputAccessoryViewController: UIInputViewController? {
        get { _inputAccessoryViewController }
        set {
            _inputAccessoryViewController = newValue
        }
    }
    
    private var _inputView: UIView?
    private var _inputAccessoryView: UIView?
    private var _inputViewController: UIInputViewController?
    private var _inputAccessoryViewController: UIInputViewController?
    
    open override var canBecomeFirstResponder: Bool {
        true
    }
    
    open override var canResignFirstResponder: Bool {
        true
    }
}
