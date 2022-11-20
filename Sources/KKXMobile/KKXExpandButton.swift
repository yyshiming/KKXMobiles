//
//  KKXExpandButton.swift
//  KKXMobile
//
//  Created by ming on 2022/5/20.
//  Copyright © 2022 ming. All rights reserved.
//

import UIKit

open class KKXExpandButton: UIButton {

    open var expandInset: UIEdgeInsets = .zero
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.inset(by: expandInset.opposite()).contains(point)
    }

}
