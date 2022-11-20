//
//  UINavigationControllerExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension UINavigationController {
    
    // MARK: -------- swizzle --------
    
    public static func initializeNavController() {
        kkxSwizzleSelector(self, originalSelector: #selector(pushViewController(_:animated:)), swizzledSelector: #selector(kkxPushViewController(_:animated:)))
        kkxSwizzleSelector(self, originalSelector: #selector(setViewControllers(_:animated:)), swizzledSelector: #selector(kkxSetViewControllers(_:animated:)))
        
        /*
        kkxSwizzleSelector(self, originalSelector: #selector(popViewController(animated:)), swizzledSelector: #selector(kkxPopViewController(animated:)))
        
        let originalSelector = NSSelectorFromString("_updateInteractiveTransition:")
        kkxSwizzleSelector(self, originalSelector: originalSelector, swizzledSelector: #selector(kkxUpdateInteractiveTransition(_:)))
        */
    }
    
    @objc private func kkxPushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.viewControllers.count >= 1 { viewController.hidesBottomBarWhenPushed = true
        }
        
        self.kkxPushViewController(viewController, animated: animated)
    }
    
    @objc private func kkxSetViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        for (i, viewController) in viewControllers.enumerated() {
            if i > 0 {
                viewController.hidesBottomBarWhenPushed = true
            }
        }
        self.kkxSetViewControllers(viewControllers, animated: animated)
    }
    /*
    @objc private func kkxPopViewController(animated: Bool) -> UIViewController? {
        let popVC = self.kkxPopViewController(animated: animated)
        if viewControllers.count <= 0 { return popVC }
        if let coordinator = viewControllers.last?.transitionCoordinator {
            if coordinator.isInteractive {
                coordinator.notifyWhenInteractionChanges { (context) in
                    if context.isCancelled {
                        // 侧滑返回取消
                        let animatedDuration = context.transitionDuration * TimeInterval(context.percentComplete)
                        if let fromVCAlpha = context.viewController(forKey: UITransitionContextViewControllerKey.from)?.kkxNavBarBgAlpha {
                            UIView.animate(withDuration: animatedDuration) {
                                self.kkxNavBarBgAlpha = fromVCAlpha
                            }
                        }
                    } else {
                        let animatedDuration = context.transitionDuration * TimeInterval(1 - context.percentComplete)
                        if let toVCAlpha = context.viewController(forKey: UITransitionContextViewControllerKey.to)?.kkxNavBarBgAlpha {
                            UIView.animate(withDuration: animatedDuration) {
                                self.kkxNavBarBgAlpha = toVCAlpha
                            }
                        }
                    }
                }
            } else {
                if let toVCAlpha = coordinator.viewController(forKey: UITransitionContextViewControllerKey.to)?.kkxNavBarBgAlpha {
                    UIView.animate(withDuration: coordinator.transitionDuration) {
                        self.kkxNavBarBgAlpha = toVCAlpha
                    }
                }
            }
        }
        return popVC
    }
    
    
    @objc private func kkxUpdateInteractiveTransition(_ percentComplete: CGFloat) {
        self.kkxUpdateInteractiveTransition(percentComplete)
        if let coordinator = topViewController?.transitionCoordinator {
            if let fromVCAlpha = coordinator.viewController(forKey: UITransitionContextViewControllerKey.from)?.kkxNavBarBgAlpha,
                let toVCAlpha = coordinator.viewController(forKey: UITransitionContextViewControllerKey.to)?.kkxNavBarBgAlpha {
                if toVCAlpha != fromVCAlpha {
                    let newAlpha = fromVCAlpha + (toVCAlpha - fromVCAlpha)*percentComplete
                    kkxNavBarBgAlpha = newAlpha
                }
            }
        }
    }
    */
}

public protocol KKXWeakNavigationController {
    var weakNavigationController: UINavigationController? { get set }
}

extension KKXWeakNavigationController where Self: UIViewController {
    
    var weakNavigationController: UINavigationController? {
        get {
            let value = objc_getAssociatedObject(self, &weakNavigationControllerKey) as? UINavigationController
            return value ?? navigationController
        }
        set {
            objc_setAssociatedObject(self, &weakNavigationControllerKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
private var weakNavigationControllerKey: UInt8 = 0
