//
//  UICollectionViewCellExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension UICollectionViewCell {

    public var kkxIndexPath: IndexPath? {
        get {
            let obj = objc_getAssociatedObject(self, &kkxIndexPathKey) as? IndexPath
            return obj
        }
        set {
            objc_setAssociatedObject(self, &kkxIndexPathKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var deleteAction: ((IndexPath?) -> Void)? {
        get {
            let action = objc_getAssociatedObject(self, &deleteActionKey) as? ((IndexPath?) -> Void)
            return action
        }
        set {
            objc_setAssociatedObject(self, &deleteActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if deleteAction != nil && action == #selector(delete(_:)) {
            return true
        }
        return false
    }
    
    open override func delete(_ sender: Any?) {
        deleteAction?(kkxIndexPath)
    }
    
}

private var kkxIndexPathKey: UInt8 = 0
private var deleteActionKey: UInt8 = 0

