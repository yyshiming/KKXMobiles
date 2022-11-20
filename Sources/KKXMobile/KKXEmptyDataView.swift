//
//  KKXEmptyDataView.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

public class KKXEmptyDataView: UIView {
    
    public class Configuration {

        public static let `default` = Configuration()

        public static let failure = Configuration()
        
        public init() {

        }

        public var spacing = CGFloat(10)
        public var offset = UIOffset.zero

        public var image: UIImage?
        public var title: String?
        public var titleColor: UIColor?
        public var titleFont: UIFont?
        public var numberOfLines: Int = 0

        public var buttonTitle: String?
        public var buttonTitleColor: UIColor?
    }
    
    // MARK: -------- Properties --------
    
    public var spacing: CGFloat = 10 {
        didSet {
            stackView.spacing = spacing
        }
    }
    public var offset: UIOffset = .zero {
        didSet {
            reloadConstraintConstant()
        }
    }
    
    public var imageView: UIImageView? {
        if _imageView == nil {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            _imageView = imageView
            stackView.insertArrangedSubview(imageView, at: 0)
        }
        
        return _imageView
    }
    
    public var label: UILabel? {
        if _label == nil {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 18.0)
            label.textColor = UIColor.kkxSecondary
            label.translatesAutoresizingMaskIntoConstraints = false
            _label = label
            if let _ = _imageView {
                stackView.insertArrangedSubview(label, at: 1)
            }
            else {
                stackView.insertArrangedSubview(label, at: 0)
            }
        }
        return _label
    }
    
    public var button: UIButton? {
        if _button == nil {
            let button = UIButton(type: .system)
            button.tintColor = UIColor.kkxSystemBlue
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            _button = button
            stackView.addArrangedSubview(button)
        }
        
        return _button
    }
    
    // MARK: -------- Private Properties --------

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var centerXConstraint: NSLayoutConstraint?
    private var centerYConstraint: NSLayoutConstraint?
    
    private var _imageView: UIImageView?
    private var _label: UILabel?
    private var _button: UIButton?
    
    private var contentView = UIView()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var tapActionHandler: ((KKXEmptyDataView) -> Void)?
    private var buttonActionHandler: ((KKXEmptyDataView) -> Void)?
    
    // MARK: -------- Init --------
    
    public override init(frame: CGRect) {
        super.init(frame:frame)
        configureSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    private func configureSubviews() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        addSubview(stackView)
        
        NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: stackView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0).isActive = true
        centerXConstraint = NSLayoutConstraint( item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        centerXConstraint?.isActive = true
        centerYConstraint = NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        centerYConstraint?.isActive = true
        reloadConstraintConstant()
    }
        
    private func reloadConstraintConstant() {
        centerXConstraint?.constant = offset.horizontal
        centerYConstraint?.constant = offset.vertical
    }
    
    // MARK: -------- Actions --------
    
    @objc private func handleTap() {
        tapActionHandler?(self)
    }
    
    @objc private func handleButtonTap() {
        if let handler = buttonActionHandler {
            handler(self)
        } else {
            tapActionHandler?(self)
        }
    }
    
    // MARK: -------- Public Function --------
    
    /// 点击回调
    @discardableResult
    public func onTap(perform action: @escaping (KKXEmptyDataView) -> Void) -> Self {
        tapActionHandler = action
        return self
    }
    
    /// 按钮点击回调，默认会调用onTap的回调
    @discardableResult
    public func onButtonTap(perform action: @escaping (KKXEmptyDataView) -> Void) -> Self {
        buttonActionHandler = action
        return self
    }
}

// MARK: - ======== 没有数据时展示的view ========
extension UIView {
    
    /// 设置没数据view的显示/隐藏， 默认false
    public var kkxShowEmptyDataView: Bool {
        get { return !kkxEmptyDataView.isHidden }
        set {
            kkxEmptyDataView.isHidden = !newValue
        }
    }
    
    /// 没有数据时显示的view
    public var kkxEmptyDataView: KKXEmptyDataView {
        get {
            if let view = objc_getAssociatedObject(self, &emptyDataViewKey) as? KKXEmptyDataView {
                return view
            }
            else {
                let view = KKXEmptyDataView()
                insertSubview(view, at: 0)
                view.translatesAutoresizingMaskIntoConstraints = false
                let attributes: [NSLayoutConstraint.Attribute] = [.centerX, .centerY, .width, .height]
                for attribute in attributes {
                    NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .equal, toItem: safeAreaLayoutGuide, attribute: attribute, multiplier: 1.0, constant: 0.0).isActive = true
                }
                view.isHidden = true
                
                let config = KKXEmptyDataView.Configuration.default
                view.spacing = config.spacing
                view.offset = config.offset
                view.label?.numberOfLines = config.numberOfLines
                
                if let title = config.title {
                   view.label?.text = title
                }
                if let titleColor = config.titleColor {
                   view.label?.textColor = titleColor
                }
                if let font = config.titleFont {
                   view.label?.font = font
                }
                
                if let buttonTitle = config.buttonTitle {
                    view.button?.setTitle(buttonTitle, for: .normal)
                }
                if let buttonTitleColor = config.buttonTitleColor {
                    view.button?.setTitleColor(buttonTitleColor, for: .normal)
                }
                if let image = config.image {
                    view.imageView?.image = image
                }

                objc_setAssociatedObject(self, &emptyDataViewKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return view
            }
        }
    }

}
private var emptyDataViewKey: Int8 = 0

// MARK: - ======== 数据请求失败时展示的view ========
extension UIView {
    
    /// 设置没网络view的显示/隐藏， 默认false
    public var kkxShowFailureDataView: Bool {
        get { return !kkxFailureDataView.isHidden }
        set {
            kkxFailureDataView.isHidden = !newValue
        }
    }
    
    /// 没有网络时显示的view
    public var kkxFailureDataView: KKXEmptyDataView {
        get {
            if let view = objc_getAssociatedObject(self, &failureDataViewKey) as? KKXEmptyDataView {
                return view
            }
            else {
                let view = KKXEmptyDataView()
                insertSubview(view, at: 0)
                view.translatesAutoresizingMaskIntoConstraints = false
                let attributes: [NSLayoutConstraint.Attribute] = [.centerX, .centerY, .width, .height]
                for attribute in attributes {
                    NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .equal, toItem: safeAreaLayoutGuide, attribute: attribute, multiplier: 1.0, constant: 0.0).isActive = true
                }
                view.isHidden = true
                
                let config = KKXEmptyDataView.Configuration.failure
                view.spacing = config.spacing
                view.offset = config.offset
                view.label?.numberOfLines = config.numberOfLines
                
                if let title = config.title {
                   view.label?.text = title
                }
                if let titleColor = config.titleColor {
                   view.label?.textColor = titleColor
                }
                if let font = config.titleFont {
                   view.label?.font = font
                }
                if let buttonTitle = config.buttonTitle {
                    view.button?.setTitle(buttonTitle, for: .normal)
                }
                if let buttonTitleColor = config.buttonTitleColor {
                    view.button?.setTitleColor(buttonTitleColor, for: .normal)
                }
                if let image = config.image {
                    view.imageView?.image = image
                }
                
                objc_setAssociatedObject(self, &failureDataViewKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return view
            }
        }
    }
}
private var failureDataViewKey: Int8 = 0
