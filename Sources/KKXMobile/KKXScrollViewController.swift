//
//  KKXScrollViewController.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

open class KKXScrollViewController: KKXViewController, UIGestureRecognizerDelegate {

    // MARK: -------- Properties --------
        
    public let scrollView = UIScrollView()
    
    /// 子视图加载contentView上，固定高度时，可以直接设置contentView的高度约束
    public let contentView = UIView()
    
    /// contentView的四周边距
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            contentViewTop?.constant = contentInset.top
            contentViewLeft?.constant = contentInset.left
            contentViewBottom?.constant = -contentInset.bottom
            contentViewRight?.constant = -contentInset.right
        }
    }
    
    public var tapGestureRecognizer: UITapGestureRecognizer!

    public var contentCenterXConstraint: NSLayoutConstraint? {
        _contentCenterXConstraint
    }
    
    // MARK: -------- Private Properties --------
        
    private var contentViewTop: NSLayoutConstraint?
    private var contentViewLeft: NSLayoutConstraint?
    private var contentViewBottom: NSLayoutConstraint?
    private var contentViewRight: NSLayoutConstraint?
        
    private var _contentCenterXConstraint: NSLayoutConstraint?
    
    // MARK: -------- View Life Cycle --------
 
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(kkxTapAction))
        
        configureSubviews()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    // MARK: -------- Configuration --------
        
    private func configureSubviews() {
        
        // ScrollView
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let scrollViewAttributes: [NSLayoutConstraint.Attribute] = [.top, .left, .bottom, .right]
        for attr in scrollViewAttributes {
            NSLayoutConstraint(item: scrollView, attribute: attr, relatedBy: .equal, toItem: view, attribute: attr,  multiplier: 1.0, constant: 0).isActive = true
        }
        
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        contentViewTop = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top,  multiplier: 1.0, constant: 0)
        contentViewTop?.isActive = true
        contentViewLeft = NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left,  multiplier: 1.0, constant: 0)
        contentViewLeft?.isActive = true
        contentViewBottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom,  multiplier: 1.0, constant: 0)
        contentViewBottom?.isActive = true
        contentViewRight = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right,  multiplier: 1.0, constant: 0)
        contentViewRight?.isActive = true
        let contentViewCenterX = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX,  multiplier: 1.0, constant: 0)
        contentViewCenterX.isActive = true
        _contentCenterXConstraint = contentViewCenterX
        
        // 点击隐藏键盘手势
        tapGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func kkxTapAction() {
        view.endEditing(true)
        onTap()
    }
    
    open func onTap() {
        
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == scrollView || touch.view == contentView {
            return true
        }
        return false
    }
}

extension KKXScrollViewController: KKXKeyboardShowHideProtocol {
    
    public var aScrollView: UIScrollView {
        scrollView
    }
}

extension KKXScrollViewController: KKXAdjustmentBehaviorProtocol {
    
    public var kkxAdjustsScrollViewInsets: Bool {
        get {
            if #available(iOS 11.0, *) {
                return scrollView.contentInsetAdjustmentBehavior != .never
            }
            else {
                return automaticallyAdjustsScrollViewInsets
            }
        }
        set {
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = newValue ? .always:.never
            }
            else {
                automaticallyAdjustsScrollViewInsets = newValue
            }
        }
    }
}
