//
//  KKXSearchKeysHeader.swift
//  KKXMobile
//
//  Created by ming on 2020/8/11.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

open class KKXSearchKeysHeader: UICollectionReusableView {
    
    // MARK: -------- Properties --------
    
    public var clearButtonClickHandler: (() -> Void)?
    
    public let textLabel = UILabel()
    
    public var clearButton = UIButton(type: .custom)
    
    public var showClearButton = true {
        didSet {
            clearButton.isHidden = !showClearButton
            setNeedsUpdateConstraints()
        }
    }
    
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            textLabelLeft?.constant = contentInset.left
            clearButtonRight?.constant = -contentInset.right
            setNeedsUpdateConstraints()
        }
    }
    
    // MARK: -------- Private Properties --------
    
    private var textLabelLeft: NSLayoutConstraint?
    private var textLabelRight: NSLayoutConstraint?
    private var clearButtonRight: NSLayoutConstraint?
    
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
    
    private func configureSubviews() {
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        clearButton.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addSubview(textLabel)
        addSubview(clearButton)
        
        textLabelLeft = NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: contentInset.left)
        textLabelLeft?.isActive = true
        NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: clearButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        clearButtonRight = NSLayoutConstraint(item: clearButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -contentInset.right)
        clearButtonRight?.isActive = true
        NSLayoutConstraint(item: clearButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: clearButton, attribute: .height, relatedBy: .equal,toItem: self, attribute: .height, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: clearButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40).isActive = true
    }
    
    // MARK: -------- Actions --------
    
    @objc private func clearAction() {
        clearButtonClickHandler?()
    }
    
    open override func updateConstraints() {
        textLabelRight?.isActive = false
        if showClearButton {
            textLabelRight = NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: clearButton, attribute: .left, multiplier: 1.0, constant: -5)
        } else {
            textLabelRight = NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: self, attribute: .right, multiplier: 1.0, constant: -contentInset.right)
        }
        textLabelRight?.isActive = true
        super.updateConstraints()
    }
}
