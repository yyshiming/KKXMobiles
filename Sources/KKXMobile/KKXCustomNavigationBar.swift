//
//  KKXCustomNavigationBar.swift
//  KKXMobile
//
//  Created by ming on 2022/10/14.
//

import UIKit

open class KKXCustomNavigationBar: UIView {

    public enum TitleAlignment {
        case left
        case centerX
    }
    
    /// 导航栏内容四周距离，默认.init(right: 5)
    open var contentInset: UIEdgeInsets = UIEdgeInsets(right: 5) {
        didSet {
            contentTopConstraint?.constant = contentInset.top
            contentLeftConstraint?.constant = contentInset.left
            contentBottomConstraint?.constant = -contentInset.bottom
            contentRightConstraint?.constant = -contentInset.right
        }
    }
    
    /// leftItem之间间隔，默认5
    public var leftItemSpacing: CGFloat = 8 {
        didSet {
            _leftItemsStackView.spacing = leftItemSpacing
        }
    }
    
    /// rightItem之间间隔，默认5
    public var rightItemSpacing: CGFloat = 8 {
        didSet {
            _rightItemsStackView.spacing = rightItemSpacing
        }
    }
    
    public var titleAlignment: TitleAlignment = .centerX {
        didSet {
            switch titleAlignment {
            case .left:
                titleCenterXConstraint?.isActive = false
                titleLeftConstraint?.isActive = true
            case .centerX:
                titleLeftConstraint?.isActive = false
                titleCenterXConstraint?.isActive = true
            }
        }
    }
    /// 导航栏内容
    public let contentView = UIView()
    
    /// 返回按钮
    public let backButton = UIButton(type: .system)
    
    /// 标题
    public let titleLabel = UILabel()
    
    public var titleView: UIView? {
        get {
            _titleView
        }
        set {
            _titleView?.removeFromSuperview()
            _titleView = newValue
            reloadTitleView()
        }
    }
    private var _titleView: UIView?
    
    /// 设置leftItems
    public var leftItems: [UIView] = [] {
        didSet {
            for oldItem in _leftItemsStackView.arrangedSubviews {
                if oldItem != backButton {
                    oldItem.removeFromSuperview()
                }
            }
            for item in leftItems {
                _leftItemsStackView.addArrangedSubview(item)
                item.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentHeight).isActive = true
                NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentHeight).isActive = true
            }
        }
    }

    /// 设置rightItems
    public var rightItems: [UIView] = [] {
        didSet {
            for oldItem in _rightItemsStackView.arrangedSubviews {
                oldItem.removeFromSuperview()
            }
            for item in rightItems {
                _rightItemsStackView.addArrangedSubview(item)
                item.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint(item: item, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentHeight).isActive = true
                NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentHeight).isActive = true
            }
        }
    }
    
    
    @discardableResult
    public func onBackTap(callback: @escaping () -> Void) -> Self {
        _onBackTap = callback
        return self
    }
    private var _onBackTap: (() -> Void)?
    
    private let _leftItemsStackView = UIStackView()

    private let _rightItemsStackView = UIStackView()
    
    private let contentHeight: CGFloat = 44
    
    private var contentTopConstraint: NSLayoutConstraint?
    private var contentLeftConstraint: NSLayoutConstraint?
    private var contentBottomConstraint: NSLayoutConstraint?
    private var contentRightConstraint: NSLayoutConstraint?
    
    private var titleLeftConstraint: NSLayoutConstraint?
    private var titleCenterXConstraint: NSLayoutConstraint?

    // MARK: -------- Init --------
    
    public override init(frame: CGRect) {
        super.init(frame:frame)
        configureSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    // MARK: -------- Configure --------
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        backButton.tintColor = tintColor
        titleLabel.textColor = tintColor
    }
    
    open func configureSubviews() {
        backgroundColor = .kkxMainBackground
        
        tintColor = .kkxAlphaBlack
        
        _leftItemsStackView.axis = .horizontal
        _leftItemsStackView.alignment = .center
        _leftItemsStackView.distribution = .equalSpacing
        _leftItemsStackView.spacing = leftItemSpacing
        
        let config = KKX.Configuration.default
        let backImage = config.customBackBarButtonItemImage ?? config.defaultBackImage
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = UIColor.kkxBlack
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .kkxAlphaBlack
        
        _rightItemsStackView.axis = .horizontal
        _rightItemsStackView.alignment = .center
        _rightItemsStackView.distribution = .equalSpacing
        _rightItemsStackView.spacing = rightItemSpacing
        
        addSubview(contentView)
        
        contentView.addSubview(_leftItemsStackView)
        contentView.addSubview(_rightItemsStackView)
        
        _leftItemsStackView.addArrangedSubview(backButton)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentTopConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: contentInset.top)
        contentTopConstraint?.isActive = true
        contentLeftConstraint = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: contentInset.left)
        contentLeftConstraint?.isActive = true
        contentBottomConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -contentInset.bottom)
        contentBottomConstraint?.isActive = true
        contentRightConstraint = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -contentInset.right)
        contentRightConstraint?.isActive = true
        NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentHeight).isActive = true
        
        _leftItemsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: _leftItemsStackView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: _leftItemsStackView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: _leftItemsStackView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: backButton, attribute: .height, relatedBy: .equal, toItem: _leftItemsStackView, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: backButton, attribute: .width, relatedBy: .equal, toItem: backButton, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
        
        _rightItemsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: _rightItemsStackView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: _rightItemsStackView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: _rightItemsStackView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
        reloadTitleView()
    }

    private func reloadTitleView() {
        if titleLabel.superview != nil {
            titleLabel.removeFromSuperview()
        }
        
        let topView = titleView ?? titleLabel
        contentView.addSubview(topView)

        topView.translatesAutoresizingMaskIntoConstraints = false
        titleLeftConstraint = NSLayoutConstraint(item: topView, attribute: .leading, relatedBy: .equal, toItem: _leftItemsStackView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        
        titleCenterXConstraint = NSLayoutConstraint(item: topView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        titleCenterXConstraint?.isActive = true
        NSLayoutConstraint(item: topView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: topView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: _rightItemsStackView, attribute: .leading, multiplier: 1.0, constant: -5).isActive = true
    }
    
    open override var intrinsicContentSize: CGSize {
        let height = contentHeight + kkxSafeAreaInsets.top
        return CGSize(width: kkxScreenBounds.width, height: height)
    }
    
    @objc private func backButtonAction() {
        _onBackTap?()
    }
}

