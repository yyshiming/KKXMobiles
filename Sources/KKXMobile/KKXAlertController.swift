//
//  KKXAlertController.swift
//  KKXMobile
//
//  Created by ming on 2020/8/20.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

/// 自定义弹框
///
///     view(半透明)
///     ----|backgroundView
///     ----|--containerView
///     ----|----scrollView
///     ----|--------scrollContentView
///     ----|------------titleLabel
///     ----|------------messageLabel
///     ----|------------customView
///     ----|----seperaterView1
///     ----|----actionStackView
///     ----|--------action
///     ----|--------seperaterView
///     ----|keyboardAlignmentView
open class KKXAlertController: KKXViewController {

    public enum ClosePosition {
        case none
        case topLeft
        case topRight
    }
    
    /// 如果message、attributeMessage都设置，优先显示attributedMessage
    open var message: String?
    
    /// 如果message、attributeMessage都设置，优先显示attributedMessage
    open var attributedMessage: NSAttributedString?
    
    /// containerView大小，默认 CGSize(width: 270, height: 自适应)
    open var contentSize: CGSize = CGSize(width: 270, height: 0)

    /// 是否点击半透明dismiss, 默认false
    open var dismissOnTaped: Bool = false
    
    @discardableResult
    public func onViewDidLoad(callback: @escaping () -> Void) -> Self {
        _onViewDidLoad = callback
        return self
    }
    private var _onViewDidLoad: (() -> Void)?
    
    @discardableResult
    public func onViewWillAppear(callback: @escaping (Bool) -> Void) -> Self {
        _onViewWillAppear = callback
        return self
    }
    private var _onViewWillAppear: ((Bool) -> Void)?
    
    @discardableResult
    public func onViewDidAppear(callback: @escaping (Bool) -> Void) -> Self {
        _onViewDidAppear = callback
        return self
    }
    private var _onViewDidAppear: ((Bool) -> Void)?
    
    @discardableResult
    public func onViewWillDisappear(callback: @escaping (Bool) -> Void) -> Self {
        _onViewWillDisappear = callback
        return self
    }
    private var _onViewWillDisappear: ((Bool) -> Void)?
    
    @discardableResult
    public func onViewDidDisappear(callback: @escaping (Bool) -> Void) -> Self {
        _onViewDidDisappear = callback
        return self
    }
    private var _onViewDidDisappear: ((Bool) -> Void)?
    
    @discardableResult
    func onClose(callback: @escaping () -> Void) -> Self {
        _onClose = callback
        return self
    }
    private var _onClose: (() -> Void)?
    
    public let backgroundView = UIView()
    public let containerView = KKXAlertContainerView()
    
    public let closeButton = KKXExpandButton(type: .custom)
    
    public var closePosition: ClosePosition = .none {
        didSet {
            reloadCloseButtonConstant()
        }
    }
    
    public private(set) var actions: [KKXAlertAction] = []
    
    public func addAction(_ action: KKXAlertAction) {
        actions.append(action)
    }
    
    public func addActions(_ actions: [KKXAlertAction]) {
        actions.forEach { (action) in
            addAction(action)
        }
    }
    
    /// 自定义view
    open var customView: UIView?
    
    // MARK: - -------- Private Properties --------
    
    private var actionSeparatorViews: [UIView] = []
    
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private var titleLabel: UILabel {
        if let label = _titleLabel {
            return label
        }
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17.0)
        label.textColor = .kkxAlphaBlack
        label.numberOfLines = 0
        _titleLabel = label
        return label
    }
    private var messageLabel: UILabel {
        if let label = _messageLabel {
            return label
        }
        let label = UILabel()
        label.numberOfLines = 0
        _messageLabel = label
        return label
    }
    private var actionStackView: UIStackView {
        if let stackView = _actionStackView {
            return stackView
        }
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        _actionStackView = stackView
        return stackView
    }
    private var _titleLabel: UILabel?
    private var _messageLabel: UILabel?
    private var _actionStackView: UIStackView?
    
    private let keyboardAlignmentView = UIView()
    
    private let containerRadius: CGFloat = 14
    
    private let actionHeight: CGFloat = 44
        
    private let closeButtonSize = CGSize(width: 40, height: 40)

    private var keyboardAlignmentHeight: NSLayoutConstraint?
    
    private var containerTop: NSLayoutConstraint?
    private var containerBottom: NSLayoutConstraint?
    private var containerCenterY: NSLayoutConstraint?
    private var containerMaxHeight: NSLayoutConstraint?
    
    private var titleLabelLeading: NSLayoutConstraint?
    
    private var closeButtonleading: NSLayoutConstraint?
    private var closeButtonTrailing: NSLayoutConstraint?

    private var _observations: [NSKeyValueObservation] = []
        
    // MARK: - -------- View Life Cycle --------

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIView.keyboardDidHideNotification, object: nil)
    }
    
    convenience init() {
        self.init(title: nil)
    }
    
    public init(title: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        _onViewDidLoad?()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIView.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIView.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIView.keyboardDidHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        configureData()
        configureSubviews()
        view.layoutIfNeeded()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _onViewWillAppear?(animated)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadContainerConstraint()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _onViewDidAppear?(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _onViewWillDisappear?(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _onViewDidDisappear?(animated)
    }
    
    private func reloadContainerConstraint() {
        let margin: CGFloat = 48
        var maxHeight = view.frame.height - margin
        if view.kkxSafeAreaInsets.top > 20 {
            maxHeight -= (view.kkxSafeAreaInsets.top + view.kkxSafeAreaInsets.bottom)
        }
        if containerMaxHeight == nil {
            containerMaxHeight = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: maxHeight)
        } else {
            containerMaxHeight?.constant = maxHeight
        }
        containerTop?.constant = view.kkxSafeAreaInsets.top
        containerBottom?.constant = -max(20, view.kkxSafeAreaInsets.bottom)
    }
    
    private func reloadCloseButtonConstant() {
        switch closePosition {
        case .none:
            closeButton.isHidden = true
            titleLabelLeading?.isActive = false
        case .topLeft:
            closeButton.isHidden = false
            closeButtonleading?.isActive = true
            closeButtonTrailing?.isActive = false
            
            titleLabelLeading?.isActive = true
        case .topRight:
            closeButton.isHidden = false
            closeButtonleading?.isActive = false
            closeButtonTrailing?.isActive = true
            
            titleLabelLeading?.isActive = true
        }
    }
    
    private var closeButtonImage: UIImage? {
        UIImage.itemImage(with: .init(style: .close, tintColor: .kkxSecondary, width: 12))
    }
    
    private func initSubviews() {
        containerView.layer.cornerRadius = containerRadius
        containerView.isUserInteractionEnabled = true
        containerView.clipsToBounds = true
        containerView.blur(.prominent)
        
        closeButton.setImage(closeButtonImage, for: .normal)
        closeButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        closeButton.layer.cornerRadius = closeButtonSize.height / 2
        closeButton.layer.masksToBounds = true
    }
    
    // MARK: - -------- Configuration --------
    
    private func configureData() {
        if title != nil {
            titleLabel.text = title
        }
        
        var attrMessage = attributedMessage
        if attrMessage == nil, let message = message {
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0),
                              NSAttributedString.Key.foregroundColor: UIColor.kkxAlphaBlack]
            attrMessage = NSAttributedString(string: message, attributes: attributes)
        }
        if attrMessage != nil {
            messageLabel.attributedText = attrMessage
        }
        
        for (i, action) in actions.enumerated() {
            action.onHandler { [weak self] obj in
                guard let self = self else { return }
                if obj.autoDismiss {
                    self.cancelAction()
                }
            }
            let button = action.button
            button.tag = i
            button.setBackgroundImage(UIColor.highlightBackground.image, for: .highlighted)
            let observation = button.observe(\.isHighlighted) { [weak self](btn, _) in
                guard let self = self else { return }
                let line1 = self.actionSeparatorViews.first { $0.tag == btn.tag - 1 }
                let line2 = self.actionSeparatorViews.first { $0.tag == btn.tag }
                let alpha = CGFloat(btn.isHighlighted ? 0 : 1)
                line1?.alpha = alpha
                line2?.alpha = alpha
            }
            _observations.append(observation)
        }
    }
    
    private func configureSubviews() {
        initSubviews()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        
        let leftMargin: CGFloat = 15
        let contentTop: CGFloat = 20
        let contentSpacing: CGFloat = 15
        let seperaterTop: CGFloat = 20
        
        // BackgroundView
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: backgroundView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: backgroundView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: backgroundView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        
        // KeyboardAlignmentView
        view.addSubview(keyboardAlignmentView)
        keyboardAlignmentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: keyboardAlignmentView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: keyboardAlignmentView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: keyboardAlignmentView, attribute: .top, relatedBy: .equal, toItem: backgroundView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: keyboardAlignmentView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        keyboardAlignmentHeight = NSLayoutConstraint(item: keyboardAlignmentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        keyboardAlignmentHeight?.isActive = true
        
        // ContainerView
        backgroundView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentSize.width).isActive = true
        
        var containerToItem: Any!
        if #available(iOS 11.0, *) {
            containerToItem = backgroundView.safeAreaLayoutGuide
        } else {
            containerToItem = backgroundView
        }
        NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: containerToItem, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: containerToItem, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        
        containerTop = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: backgroundView, attribute: .top, multiplier: 1.0, constant: 0)
        containerTop?.isActive = true
        containerBottom = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: backgroundView, attribute: .bottom, multiplier: 1.0, constant: 0)
        containerBottom?.isActive = true
        
        // ScrollView
        var buttonStackTopItem: UIView = containerView
        var buttonStackTopAttribute = NSLayoutConstraint.Attribute.top
        if title != nil || message != nil || attributedMessage != nil || customView != nil {
            
            // ScrollView
            containerView.addSubview(scrollView)
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            let attributes: [NSLayoutConstraint.Attribute] = [
                .top, .leading, .trailing
            ]
            for attribute in attributes {
                NSLayoutConstraint(item: scrollView, attribute: attribute, relatedBy: .equal, toItem: containerView, attribute: attribute, multiplier: 1.0, constant: 0).isActive = true
            }
            
            // ScrollContentView
            scrollView.addSubview(scrollContentView)
            scrollContentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: scrollContentView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: scrollContentView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: scrollContentView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: scrollContentView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: scrollContentView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            
            var seperaterTopConstraint: NSLayoutConstraint?
            if actions.count > 0 {
                // SeperaterView
                let seperaterView = UIView()
                seperaterView.backgroundColor = .alertSeparator
                containerView.addSubview(seperaterView)
                
                seperaterView.translatesAutoresizingMaskIntoConstraints = false
                seperaterTopConstraint = NSLayoutConstraint(item: seperaterView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: seperaterTop)
                seperaterTopConstraint?.isActive = true
                NSLayoutConstraint(item: seperaterView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: seperaterView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: seperaterView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: .pixel).isActive = true
                
                buttonStackTopItem = seperaterView
                buttonStackTopAttribute = .bottom
            } else {
                // 没有actions时scrollContentView添加bottom约束
                NSLayoutConstraint(item: scrollContentView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -contentTop).isActive = true
            }
            
            var bottomReferenceItem: Any!
            var contentTopItem = scrollContentView
            var contentTopItemAttribute = NSLayoutConstraint.Attribute.top
            
            // TitleLabel
            if title != nil {
                scrollContentView.addSubview(titleLabel)
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: scrollContentView, attribute: .top, multiplier: 1.0, constant: contentTop).isActive = true
                NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: scrollContentView, attribute: .leading, multiplier: 1.0, constant: leftMargin).isActive = true
                titleLabelLeading = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: scrollContentView, attribute: .leading, multiplier: 1.0, constant: closeButtonSize.width)
                NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: scrollContentView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
                
                bottomReferenceItem = titleLabel
                contentTopItem = titleLabel
                contentTopItemAttribute = .bottom
            }
            
            // MessageLabel
            if message != nil || attributedMessage != nil {
                scrollContentView.addSubview(messageLabel)
                messageLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: contentTopItem, attribute: contentTopItemAttribute, multiplier: 1.0, constant: contentSpacing).isActive = true
                NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: scrollContentView, attribute: .leading, multiplier: 1.0, constant: leftMargin).isActive = true
                NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: scrollContentView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
                
                bottomReferenceItem = messageLabel
                contentTopItem = messageLabel
                contentTopItemAttribute = .bottom
            }
            
            // CustomView
            if let customView = customView {
                seperaterTopConstraint?.constant = 0
                
                scrollContentView.addSubview(customView)
                customView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint(item: customView, attribute: .top, relatedBy: .equal, toItem: contentTopItem, attribute: contentTopItemAttribute, multiplier: 1.0, constant: contentSpacing).isActive = true
                NSLayoutConstraint(item: customView, attribute: .leading, relatedBy: .equal, toItem: scrollContentView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
                let widthConstraint = NSLayoutConstraint(item: customView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentSize.width)
                widthConstraint.priority = UILayoutPriority(rawValue: 999)
                widthConstraint.isActive = true
                
                bottomReferenceItem = customView
            }
            NSLayoutConstraint(item: bottomReferenceItem!, attribute: .bottom, relatedBy: .equal, toItem: scrollContentView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            let scrollViewHeight = NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: scrollContentView, attribute: .height, multiplier: 1.0, constant: 0)
            scrollViewHeight.priority = UILayoutPriority(rawValue: 749)
            scrollViewHeight.isActive = true
        }
        
        // ActionStackView
        if actions.count > 0 {
            var stackViewH = actionHeight
            if actions.count > 2 {
                stackViewH = (actionHeight + .pixel)*CGFloat(actions.count) - .pixel
            }
            
            containerView.addSubview(actionStackView)
            actionStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: actionStackView, attribute: .top, relatedBy: .equal, toItem: buttonStackTopItem, attribute: buttonStackTopAttribute, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: actionStackView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: actionStackView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: actionStackView, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: actionStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: stackViewH).isActive = true
            
            // Actions
            if actions.count == 2 {
                configureTwoActions()
            } else {
                configureDefaultActions()
            }
        }
        
        // closeButton
        containerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: closeButtonSize.width).isActive = true
        NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: closeButtonSize.height).isActive = true
        closeButtonleading = NSLayoutConstraint(item: closeButton, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0)
        closeButtonTrailing = NSLayoutConstraint(item: closeButton, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0)
        closeButtonTrailing?.isActive = true
        reloadCloseButtonConstant()
    }
    
    private func configureDefaultActions() {
        actionStackView.axis = .vertical
        for (i, action) in actions.enumerated() {
            let button = action.button
            actionStackView.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: actionHeight).isActive = true
            
            if i < actions.count - 1 {
                let separatorView = UIView()
                separatorView.backgroundColor = .alertSeparator
                separatorView.tag = button.tag
                actionStackView.addArrangedSubview(separatorView)
                actionSeparatorViews.append(separatorView)
                
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint(item: separatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: .pixel).isActive = true
            }
        }
    }
    
    private func configureTwoActions() {
        actionStackView.axis = .horizontal

        let button1 = actions[0].button
        actionStackView.addArrangedSubview(button1)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .alertSeparator
        separatorView.tag = button1.tag
        actionStackView.addArrangedSubview(separatorView)
        actionSeparatorViews.append(separatorView)
        
        let button2 = actions[1].button
        actionStackView.addArrangedSubview(button2)
        
        button1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: button1, attribute: .height, relatedBy: .equal, toItem: actionStackView, attribute: .height, multiplier: 1.0, constant: 0).isActive = true
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: separatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: .pixel).isActive = true
        
        button2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: button2, attribute: .width, relatedBy: .equal, toItem: button1, attribute: .width, multiplier: 1.0, constant: 0).isActive = true
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        actions.forEach { $0.button.setBackgroundImage(UIColor.highlightBackground.image, for: .highlighted) }
        closeButton.setImage(closeButtonImage, for: .normal)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: -------- Actions --------
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        let duration = sender.userInfo?[UIView.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        let frame = sender.userInfo?[UIView.keyboardFrameEndUserInfoKey] as? CGRect
        let height = frame?.size.height ?? 0
        self.keyboardAlignmentHeight?.constant = height

        UIView.animate(withDuration: duration) {
            if duration > 0 {
                self.view.layoutIfNeeded()
            } else {
                self.view.setNeedsLayout()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        let duration = sender.userInfo?[UIView.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        self.keyboardAlignmentHeight?.constant = 0
        
        UIView.animate(withDuration: duration) {
            if duration > 0 {
                self.view.layoutIfNeeded()
            } else {
                self.view.setNeedsLayout()
            }
        }
    }
    
    @objc private func keyboardDidHide(_ sender: Notification) {
        
    }
    
    @objc private func cancelAction() {
        dismiss(animated: true, completion: nil)
        _onClose?()
    }
    
    @objc private func tapAction() {
        if dismissOnTaped {
            cancelAction()
        }
    }
}

extension KKXAlertController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: containerView) == true {
            return false
        }
        return true
    }
}

public class KKXAlertContainerView: UIView {
    
}

open class KKXAlertAction: NSObject {
    
    /// 点击按钮后是否自动dismiss, 默认true
    open var autoDismiss: Bool = true
    
    public let button = KKXActionButton(type: .custom)
    
    public var handler: ((KKXAlertAction) -> Void)?
    
    public init(handler: ((KKXAlertAction) -> Void)? = nil) {
        self.handler = handler
        super.init()
        
        self.configureButton()
    }
    
    @discardableResult
    fileprivate func onHandler(callback: @escaping (KKXAlertAction) -> Void) -> Self {
        _onHandler = callback
        return self
    }
    private var _onHandler: ((KKXAlertAction) -> Void)?
    
    private func configureButton() {
        addTargetAction()
    }
    
    private func addTargetAction() {
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    @objc private func buttonClicked() {
        handler?(self)
        _onHandler?(self)
    }
}

public class KKXActionButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configuration()
    }
    
    private func configuration() {
        setTitleColor(.kkxSystemBlue, for: .normal)
    }
}

private extension UIColor {
    
    static let lightSeparator = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.3)
    static let darkSeparator = UIColor(red: 142.0/255.0, green: 142.0/255.0, blue: 147.0/255.0, alpha: 0.6)
    static var alertSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return .darkSeparator
                }
                else {
                    return .lightSeparator
                }
            })
        } else {
            return .lightSeparator
        }
    }
    
    static let lightBackground = UIColor(red: 84.0/255.0, green: 84.0/255.0, blue: 88.0/255.0, alpha: 0.2)
    static let darkBackground = UIColor(red: 142.0/255.0, green: 142.0/255.0, blue: 147.0/255.0, alpha: 0.3)
    static var highlightBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return .darkBackground
                }
                else {
                    return .lightBackground
                }
            })
        } else {
            return .lightBackground
        }
    }
}
