//
//  UITabBarControllerExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension UITabBarController {
    
    open override var shouldAutorotate: Bool {
        if let vc = selectedViewController {
            return vc.shouldAutorotate
        }
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let vc = selectedViewController {
            return vc.supportedInterfaceOrientations
        }
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let vc = selectedViewController {
            return vc.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    open override var prefersStatusBarHidden: Bool {
        if let vc = selectedViewController {
            return vc.prefersStatusBarHidden
        }
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let vc = selectedViewController {
            return vc.preferredStatusBarStyle
        }
        return .default
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        if let vc = selectedViewController {
            return vc.preferredStatusBarUpdateAnimation
        }
        return .none
    }
    
}
