//
//  KKXTableViewCell.swift
//  KKXMobile
//
//  Created by ming on 2021/5/11.
//

import UIKit

open class KKXTableViewCell: UITableViewCell {
    
    // MARK: -------- Init --------
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    // MARK: -------- Configure --------
    
    open func configureSubviews() {
        backgroundColor = .clear
    }
}
