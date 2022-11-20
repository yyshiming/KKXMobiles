//
//  ForceTouchProtocol.swift
//  Demo
//
//  Created by ming on 2022/9/21.
//

import UIKit

/// 注册force touch
public protocol ForceTouchProtocol: UIViewControllerPreviewingDelegate {
    
    @available(iOS 13.0, *)
    var menuConfiguration: UIContextMenuConfiguration? { get set }
    
    func registerForceTouch(for view: UIView)
}

extension ForceTouchProtocol where Self: UIViewController {
    
    public func registerForceTouch(for view: UIView) {
        if view.traitCollection.forceTouchCapability == .available {
            if #available(iOS 13.0, *) {
                let interaction = UIContextMenuInteraction(delegate: interactionDelegate)
                view.addInteraction(interaction)
            } else {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
    }
    
    @available(iOS 13.0, *)
    public var menuConfiguration: UIContextMenuConfiguration? {
        get { interactionDelegate.configuration }
        set {
            interactionDelegate.configuration = newValue
        }
    }
    
    @available(iOS 13.0, *)
    private var interactionDelegate: MenuInteractionDelegate {
        guard let delegate = objc_getAssociatedObject(self, &interactionDelegateKey) as? MenuInteractionDelegate else {
            let delegate = MenuInteractionDelegate()
            objc_setAssociatedObject(self, &interactionDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return delegate
        }
        return delegate
    }
}

private var menuConfigurationKey: UInt8 = 0
private var interactionDelegateKey: UInt8 = 0

@available(iOS 13.0, *)
private class MenuInteractionDelegate: NSObject, UIContextMenuInteractionDelegate {
    
    var configuration: UIContextMenuConfiguration?
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        configuration
    }
}
