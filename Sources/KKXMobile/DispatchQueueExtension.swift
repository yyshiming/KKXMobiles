//
//  DispatchQueueExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension DispatchQueue {
    
    /// 在主线程调用block
    /// - Parameter block: 要调用的block
    public class func kkx_safe(_ block: @escaping () -> ()) {
        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    /// Execute the provided closure after a `TimeInterval`.
    ///
    /// - Parameters:
    ///   - delay:   `TimeInterval` to delay execution.
    ///   - closure: Closure to execute.
    public func kkx_after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
}
