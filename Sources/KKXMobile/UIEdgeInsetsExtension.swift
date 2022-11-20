//
//  UIEdgeInsetsExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension UIEdgeInsets {

    /// 初始化 top = left = bottom = right = value
    public init(value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
    
    /// placeholder为占位参数，不传值
    public init(top: CGFloat = 0,
                left: CGFloat = 0,
                bottom: CGFloat = 0,
                right: CGFloat = 0,
                placeholder: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
    
    /// 取各个值得相反数
    public func opposite() -> UIEdgeInsets {
        UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
}

extension UIOffset {
    
    /// placeholder为占位参数，不传值
    public init(horizontal: CGFloat = 0,
                vertical: CGFloat = 0,
                placeholder: CGFloat = 0) {
        self.init(horizontal: horizontal, vertical: vertical)
    }
}
