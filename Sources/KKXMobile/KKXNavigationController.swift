//
//  KKXNavigationController.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

open class KKXNavigationController: UINavigationController, KKXCustomNavigationBarProtocol {

    deinit {
        kkxDeinitLog()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = defaultConfiguration.mainBackground
        
        // 导航栏阴影
        if defaultConfiguration.isHideNavigationBarShadowImage {
            navigationBar.shadowImage = UIImage()
        } else {
            navigationBar.shadowImage = nil
        }
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
    
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return topViewController
    }
    
    open override var shouldAutorotate: Bool {
        if let vc = topViewController {
            return vc.shouldAutorotate
        }
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let vc = topViewController {
            return vc.supportedInterfaceOrientations
        }
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let vc = topViewController {
            return vc.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    open override var prefersStatusBarHidden: Bool {
        if let vc = topViewController {
            return vc.prefersStatusBarHidden
        }
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let vc = topViewController {
            return vc.preferredStatusBarStyle
        }
        return .default
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        if let vc = topViewController {
            return vc.preferredStatusBarUpdateAnimation
        }
        return .none
    }
}

extension KKXNavigationController {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is KKXCustomNavigationBarProtocol {
            let isHidden = viewController.isNavigationBarHidden
            navigationController.setNavigationBarHidden(isHidden, animated: animated)
        }
    }
}

extension KKXNavigationController: UIGestureRecognizerDelegate {
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if viewControllers.count == 1 {
            return false
        }
        return true
    }
}
