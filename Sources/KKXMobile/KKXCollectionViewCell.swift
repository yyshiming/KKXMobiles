//
//  KKXCollectionViewCell.swift
//  KKXMobile
//
//  Created by ming on 2021/5/11.
//

import UIKit

open class KKXCollectionViewCell: UICollectionViewCell {
    
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
    
    open func configureSubviews() {
        
    }
}
