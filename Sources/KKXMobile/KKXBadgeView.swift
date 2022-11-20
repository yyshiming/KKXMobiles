//
//  KKXBadgeView.swift
//  KKXMobile
//
//  Created by ming on 2021/4/30.
//  Copyright © 2021 ming. All rights reserved.
//

import UIKit

open class KKXBadgeView: UIView {

    // MARK: -------- Properties --------
    
    open var badgeValue: String? {
        didSet {
            reloadBadgeValue()
        }
    }
    
    open var badgeColor: UIColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0) {
        didSet {
            backgroundColor = badgeColor
        }
    }
    
    open func setBadgeTextAttributes(_ textAttributes: [NSAttributedString.Key : Any]?) {
        _textAttributes = textAttributes
        reloadBadgeValue()
    }
    
    private func reloadBadgeValue() {
        if let attributes = _textAttributes {
           if let text = badgeValue {
                textLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
           }
        } else {
            textLabel.text = badgeValue
        }
    }
    
    private let textLabel = UILabel()
    
    private let maxHeight: CGFloat = 18

    private var _textAttributes: [NSAttributedString.Key : Any]?
        
    private var _textObservation: NSKeyValueObservation?
    private var _attributedTextObservation: NSKeyValueObservation?

    public override init(frame: CGRect) {
        super.init(frame:frame)
        configureSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    
    private func configureSubviews() {
        backgroundColor = badgeColor
        clipsToBounds = true
        layer.cornerRadius = maxHeight/2
        
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 13)
        _textObservation = textLabel.observe(\.text) { label, change in
            self.invalidateIntrinsicContentSize()
        }
        _attributedTextObservation = textLabel.observe(\.attributedText) { label, change in
            self.invalidateIntrinsicContentSize()
        }
        addSubview(textLabel)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        textLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    override open var intrinsicContentSize: CGSize {
        textLabel.sizeToFit()
        let left: CGFloat = 5.0
        let textWidth = ceil(textLabel.frame.width)
        var contentWidth = maxHeight
        if textWidth > maxHeight - left * 2 {
            contentWidth = textWidth + left * 2
        }
        return CGSize(width: contentWidth, height: maxHeight)
    }
}
