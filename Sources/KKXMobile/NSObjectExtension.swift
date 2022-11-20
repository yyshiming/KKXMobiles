//
//  NSObjectExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

// MARK: - ======== Observations ========

extension NSObject {
    
    public var observations: [String: NSKeyValueObservation] {
        get {
            guard let observations = objc_getAssociatedObject(self, &observationsKey) as? [String: NSKeyValueObservation] else {
                let value: [String: NSKeyValueObservation] = [:]
                objc_setAssociatedObject(self, &observationsKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
            return observations
        }
        set {
            objc_setAssociatedObject(self, &observationsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
private var observationsKey: UInt8 = 0


// MARK: - ======== deinitLog ========

extension NSObject {

    public func kkxDeinitLog() {
        kkxPrint(NSStringFromClass(self.classForCoder) + " deinit")
    }
}


// MARK: - ======== KeyboardShow\Hide ========

public struct KeybordObserverType: OptionSet {
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static var none     = KeybordObserverType(rawValue: 0)
    public static var willShow = KeybordObserverType(rawValue: 1 << 0)
    public static var didShow  = KeybordObserverType(rawValue: 1 << 1)
    public static var willHide = KeybordObserverType(rawValue: 1 << 2)
    public static var didHide  = KeybordObserverType(rawValue: 1 << 3)
    
    public static let all: KeybordObserverType = [.willShow, .didShow, .willHide, .didHide]
}

extension NSObject {
    
    public func kkx_addKeyboardObserver(_ observerType: KeybordObserverType = [.willShow, .willHide]) {
        if observerType.contains(.willShow) {
            NotificationCenter.default.addObserver(self, selector: #selector(kkx_keyboardWillShow(_:)), name: UIView.keyboardWillShowNotification, object: nil)
        }
        if observerType.contains(.didShow) {
            NotificationCenter.default.addObserver(self, selector: #selector(kkx_keyboardDidShow(_:)), name: UIView.keyboardDidShowNotification, object: nil)
        }
        if observerType.contains(.willHide) {
            NotificationCenter.default.addObserver(self, selector: #selector(kkx_keyboardWillHide(_:)), name: UIView.keyboardWillHideNotification, object: nil)
        }
        if observerType.contains(.didHide) {
            NotificationCenter.default.addObserver(self, selector: #selector(kkx_keyboardDidHide(_:)), name: UIView.keyboardDidHideNotification, object: nil)
        }
    }
    
    public func kkx_removeKeyboardObserver(_ observerType: KeybordObserverType = [.willShow, .willHide]) {
        if observerType.contains(.willShow) {
            NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillShowNotification, object: nil)
        }
        if observerType.contains(.didShow) {
            NotificationCenter.default.removeObserver(self, name: UIView.keyboardDidShowNotification, object: nil)
        }
        if observerType.contains(.willHide) {
            NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillHideNotification, object: nil)
        }
        if observerType.contains(.didHide) {
            NotificationCenter.default.removeObserver(self, name: UIView.keyboardDidHideNotification, object: nil)
        }
    }
    
    @objc open func kkx_keyboardWillShow(_ sender: Notification) {
        
    }
    
    @objc open func kkx_keyboardDidShow(_ sender: Notification) {
        
    }
    
    @objc open func kkx_keyboardWillHide(_ sender: Notification) {
        
    }
    
    @objc open func kkx_keyboardDidHide(_ sender: Notification) {
        
    }
}

/// 存储计时信息的对象
public class TimerObject {
    
    /// 计时秒数，默认 60
    public var timerCount: Int = 60 {
        didSet {
            currentCount = timerCount
        }
    }
    
    /// 定时器当前数值
    public fileprivate(set) var currentCount: Int = 60
    /// 定时器是否倒计时中
    public fileprivate(set) var isCountDown: Bool = false
    
    public fileprivate(set) var isTiming: Bool = false
    
    fileprivate var timer: Timer?
    
    /// 继续
    public func resume() {
        if timer?.isValid == true, !isTiming {
            isTiming = true
            timer?.fireDate = Date()
        }
    }
    
    /// 暂停
    public func pause() {
        if timer?.isValid == true {
            isTiming = false
            timer?.fireDate = Date.distantFuture
        }
    }
    
    /// 销毁定时器
    public func invalidateTimer() {
        isCountDown = false
        isTiming = false
        timer?.invalidate()
        timer = nil
        currentCount = timerCount
    }
    
    deinit {
        invalidateTimer()
    }
}

/// 计时器代理
///
///     Class Object: NSObject, TimerDelegate { }
///     let obj = Object()
///     obj.timerObject.timerCount = 60
///     obj.startTimer()
public protocol TimerDelegate: AnyObject {
        
    /// 存储计时信息的对象
    var timerObject: TimerObject { get }
    
    /// 将要开始计时回调
    func onWillRunning(handler: @escaping (TimerDelegate) -> Void) -> Self
    /// 计时中回调
    func onRunning(handler: @escaping (TimerDelegate, Int) -> Void) -> Self
    /// 计时结束回调
    func onStoped(handler: @escaping (TimerDelegate) -> Void) -> Self
    
    /// 开始计时
    func kkxStartTimer()
}

extension TimerDelegate {
        
    public var timerObject: TimerObject {
        guard let obj = objc_getAssociatedObject(self, &timerObjectKey) as? TimerObject else {
            let obj = TimerObject()
            objc_setAssociatedObject(self, &timerObjectKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return obj
        }
        return obj
    }
    
    @discardableResult
    public func onWillRunning(handler: @escaping (TimerDelegate) -> Void) -> Self {
        willRunningHandler = handler
        return self
    }
    
    @discardableResult
    public func onRunning(handler: @escaping (TimerDelegate, Int) -> Void) -> Self {
        runningHandler = handler
        return self
    }
    
    @discardableResult
    public func onStoped(handler: @escaping (TimerDelegate) -> Void) -> Self {
        stopHandler = handler
        return self
    }
    
    public func kkxStartTimer() {
        if timerObject.isCountDown {
            return
        }

        timerObject.invalidateTimer()
        timerObject.isCountDown = true
        timerObject.isTiming = true
        willRunningHandler?(self)

        let timer = Timer.kkxTimer(timeInterval: 1.0, repeats: true, block: { [weak self](timer) in
            self?.timerFired(timer)
        })
        RunLoop.current.add(timer, forMode: .common)
        timerObject.timer = timer

        runningHandler?(self, timerObject.currentCount)
    }
    
    private func timerFired(_ timer: Timer) {
        
        timerObject.currentCount -= 1
        guard timerObject.currentCount > 0 else {
            timerObject.invalidateTimer()
            stopHandler?(self)
            return
        }
        runningHandler?(self, timerObject.currentCount)
    }
    
    private var willRunningHandler: ((Self) -> Void)? {
        get {
            objc_getAssociatedObject(self, &willRunningHandlerKey) as? (Self) -> Void
        }
        set {
            objc_setAssociatedObject(self, &willRunningHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var runningHandler: ((Self, Int) -> Void)? {
        get {
            objc_getAssociatedObject(self, &runningHandlerKey) as? (Self, Int) -> Void
        }
        set {
            objc_setAssociatedObject(self, &runningHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var stopHandler: ((Self) -> Void)? {
        get {
            objc_getAssociatedObject(self, &stopHandlerKey) as? (Self) -> Void
        }
        set {
            objc_setAssociatedObject(self, &stopHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
private var timerObjectKey: UInt8 = 0
private var willRunningHandlerKey: UInt8 = 0
private var runningHandlerKey: UInt8 = 0
private var stopHandlerKey: UInt8 = 0
