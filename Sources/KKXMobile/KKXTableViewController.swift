//
//  KKXTableViewController.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

open class KKXTableViewController: UITableViewController, KKXCustomNavigationBarProtocol, KKXCustomBackItemProtocol {
    
    deinit {
        kkxDeinitLog()
    }
    
    convenience init() {
        self.init(style: .plain)
    }
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.kkxMainBackground
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceVertical = true
    }
    
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

extension KKXTableViewController: KKXAdjustmentBehaviorProtocol {
    
    public var kkxAdjustsScrollViewInsets: Bool {
        get {
            if #available(iOS 11.0, *) {
                return tableView.contentInsetAdjustmentBehavior != .never
            }
            else {
                return automaticallyAdjustsScrollViewInsets
            }
        }
        set {
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = newValue ? .always:.never
            }
            else {
                automaticallyAdjustsScrollViewInsets = newValue
            }
        }
    }
}
