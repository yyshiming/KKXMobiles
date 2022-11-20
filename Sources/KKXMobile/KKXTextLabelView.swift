//
//  KKXTextLabelView.swift
//  Demo
//
//  Created by ming on 2021/6/2.
//

import UIKit

open class KKXTextLabelView: UIView {

    // MARK: -------- Properties --------
    
    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            textLabelTop?.constant = contentInset.top
            textLabelLeft?.constant = contentInset.left
            textLabelBottom?.constant = -contentInset.bottom
            textLabelRight?.constant = -contentInset.right
        }
    }

    public let textLabel = UILabel()
    
    // MARK: -------- Private Properties --------
    
    private var textLabelTop: NSLayoutConstraint?
    private var textLabelLeft: NSLayoutConstraint?
    private var textLabelBottom: NSLayoutConstraint?
    private var textLabelRight: NSLayoutConstraint?

    // MARK: -------- Init --------
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        configureSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    // MARK: -------- Configure --------
    
    private func configureSubviews() {
        addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabelTop = NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: contentInset.top)
        textLabelTop?.isActive = true
        
        textLabelLeft = NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: contentInset.left)
        textLabelLeft?.isActive = true
        
        textLabelBottom = NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -contentInset.right)
        textLabelBottom?.isActive = true
        
        textLabelRight = NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .right, multiplier: 1.0, constant: -contentInset.right)
        textLabelRight?.isActive = true
    }
}
