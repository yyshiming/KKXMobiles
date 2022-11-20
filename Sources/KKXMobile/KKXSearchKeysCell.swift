//
//  KKXSearchKeysCell.swift
//  KKXMobile
//
//  Created by ming on 2020/8/11.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

public class KKXSearchKeysCell: KKXCollectionViewCell {
    
    public let textLabel = UILabel()
    
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            leftConstraint?.constant = contentInset.left
            rightConstraint?.constant = -contentInset.right
        }
    }
    
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    
    open override func configureSubviews() {
        super.configureSubviews()
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.kkxGray
        
        textLabel.textColor = UIColor.kkxAlphaBlack

        contentView.addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        leftConstraint = NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        leftConstraint?.isActive = true
        rightConstraint = NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        rightConstraint?.isActive = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.frame.height/2
    }
}
