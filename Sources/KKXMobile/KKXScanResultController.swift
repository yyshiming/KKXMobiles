//
//  KKXScanResultController.swift
//  KKXMobile
//
//  Created by ming on 2021/1/24.
//  Copyright © 2021 ming. All rights reserved.
//

import UIKit

public class KKXScanResultController: KKXScrollViewController {

    // MARK: -------- Properties --------
    
    public let textLabel = UILabel()
    
    // MARK: -------- Private Properties --------
    
    // MARK: -------- View Life Cycle --------
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        configureNavigationBar()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: -------- Configuration --------
    
    private func configureNavigationBar() {
        navigationItem.title = KKXExtensionString("scan.result.title")
    }
    
    private func configureSubviews() {
        textLabel.numberOfLines = 0
        contentView.addSubview(textLabel)
        
        let contentMargin: CGFloat = 10
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: contentMargin).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: contentMargin).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -contentMargin).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -contentMargin).isActive = true
    }
}
