//
//  KKXViewController.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

open class KKXViewController: UIViewController, KKXCustomNavigationBarProtocol, KKXCustomBackItemProtocol {

    deinit {
        kkxDeinitLog()
    }
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = defaultConfiguration.mainBackground
    }
}

extension KKXViewController {
    
    open override var shouldAutorotate: Bool {
        if isPad { return kkx_autorotateOnIpad.shouldAutorotate }
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if isPad { return kkx_autorotateOnIpad.supportedInterfaceOrientations }
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if isPad { return kkx_autorotateOnIpad.preferredInterfaceOrientationForPresentation }
        return .portrait
    }
}
