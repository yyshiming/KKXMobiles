//
//  TimerExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension Timer {

    /// iOS 10.0之前避免循环引用
    public class func kkxTimer(timeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        if #available(iOS 10.0, *) {
            return Timer(timeInterval: timeInterval, repeats: repeats, block: block)
        } else {
            return Timer(timeInterval: timeInterval, target: self, selector: #selector(blockInvoke(_:)), userInfo: block, repeats: repeats)
        }
    }
    
    public class func kkxTimer(fireAt date: Date, interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        if #available(iOS 10.0, *) {
            return Timer(fire: date, interval: interval, repeats: repeats, block: block)
        } else {
            return Timer(fireAt: date, interval: interval, target: self, selector: #selector(blockInvoke(_:)), userInfo: block, repeats: repeats)
        }
    }
    
    @objc static private func blockInvoke(_ timer: Timer) {
        let block = timer.userInfo as? ((Timer) -> Void)
        if timer.isValid {
            block?(timer)
        }
    }
}

/*
timer.fireDate = Date()             // 继续
timer.fireDate = Date.distantPast   // 开启
timer.fireDate = Date.distantFuture // 暂停
timer.invalidate()                  // 销毁
 */
extension Timer {
    
    // 开始
    public func start() {
        fireDate = .distantPast
    }
    
    // 暂停
    public func pause() {
        fireDate = .distantFuture
    }
    
    // 继续
    public func resume() {
        fireDate = Date()
    }
}
