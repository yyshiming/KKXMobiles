//
//  Protocol.swift
//  Demo
//
//  Created by ming on 2021/5/10.
//

import UIKit

/// 在ipad上运行时，右上角添加取消item的viewController需要实现的协议
public protocol KKXShowCancelItemOnIpadProtocol: NSObjectProtocol { }

/// 自定义导航栏
public protocol KKXCustomNavigationBarProtocol: NSObjectProtocol {
    
    /// 自定义导航栏
    var kkxNavigationBar: KKXCustomNavigationBar { get }
}
extension KKXCustomNavigationBarProtocol where Self: UIViewController {
    
    /// 自定义导航栏
    public var kkxNavigationBar: KKXCustomNavigationBar {
        var obj = objc_getAssociatedObject(self, &kkxNavigationBarKey) as? KKXCustomNavigationBar
        if obj == nil {
            let newObj = KKXCustomNavigationBar()
            newObj.onBackTap { [weak self] in
                self?.kkxBackItemAction()
            }
            objc_setAssociatedObject(self, &kkxNavigationBarKey, newObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            obj = newObj
        }
        return obj!
    }
}
private var kkxNavigationBarKey: UInt8 = 0

/// 自定义返回按钮
public protocol KKXCustomBackItemProtocol: NSObjectProtocol { }

/// 刷新数据
public protocol KKXReloadDataProtocol: NSObjectProtocol {
    func kkxReloadData(_ isRefresh: Bool)
}

public protocol KKXAdjustmentBehaviorProtocol {
    var kkxAdjustsScrollViewInsets: Bool { get set }
}

// MARK: - 数据对象转字典

/// 数据对象转字典
public protocol KKXModelToDictionaryProtocol {
    
    func dictValue() -> [String: Any]
}

extension KKXModelToDictionaryProtocol where Self: Encodable {
    
    public func dictValue() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else {
            return [:]
        }
        
        let parameters = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
        guard let param = parameters, !param.isEmpty else {
            return [:]
        }
        return param
    }
}

// MARK: - 键盘显示/隐藏时，修改scrollView的contentInset.bottom

/// 键盘显示/隐藏时，修改scrollView的contentInset.bottom，使得scrollView滚动时可以显示所有内容
public protocol KKXKeyboardShowHideProtocol: NSObjectProtocol {
    
    /// scrollView，必须实现的
    var aScrollView: UIScrollView { get }
    
    /// 键盘是否显示
    var isKeyboardShow: Bool { get }
    
    /// 添加键盘监听
    func addKeyboardObserver()
    
    /// 移除键盘监听
    func removeKeyboardObserver()
}

extension KKXKeyboardShowHideProtocol {
    
    public var isKeyboardShow: Bool {
        _isKeyboardShow
    }
    
    public func addKeyboardObserver() {
        
        NotificationCenter.default.addObserver(forName: UIView.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] note in
            guard let self = self else { return }
            if isPad { return }
            
            /// 键盘开始显示时记录scrollView的contentInset，用于隐藏时重置contentInset
            if !self._isKeyboardShow {
                self._isKeyboardShow = true
                self.previousContentInset = self.aScrollView.contentInset
            }
            
            /// 转换scrollView.frame的坐标到window
            let scrollViewRect = self.aScrollView.superview?.convert(self.aScrollView.frame, to: nil) ?? .zero
            /// 获取键盘显示后的frame
            let frame = note.userInfo?[UIView.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            
            /// scrollView的bottom距离keyboard的top的高度
            let defferHeight = scrollViewRect.maxY - frame.minY
            /// 高度大于零时，修改scrollView.contentInset.bottom
            if defferHeight > 0 {
                var bottom: CGFloat = defferHeight
                if self.aScrollView.contentInsetAdjustmentBehavior != .never {
                    bottom = defferHeight - self.aScrollView.safeAreaInsets.bottom
                }
                var contentInset = self.aScrollView.contentInset
                contentInset.bottom = bottom
                self.aScrollView.contentInset = contentInset
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIView.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] note in
            guard let self = self else { return }
            if isPad { return }
            
            self._isKeyboardShow = false
            self.aScrollView.contentInset = self.previousContentInset
        }
    }
    
    public func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillHideNotification, object: nil)
    }
    
    private var previousContentInset: UIEdgeInsets {
        get {
            let inset = objc_getAssociatedObject(self, &previousContentInsetKey) as? UIEdgeInsets
            return inset ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &previousContentInsetKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var _isKeyboardShow: Bool {
        get {
            let show = objc_getAssociatedObject(self, &isKeyboardShowKey) as? Bool
            return show ?? false
        }
        set {
            objc_setAssociatedObject(self, &isKeyboardShowKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
private var previousContentInsetKey: UInt8 = 0
private var isKeyboardShowKey: UInt8 = 0
 
// MARK: - 视频时长转字符串
/// 视频时长转字符串
public protocol KKXVideoDurationProtocol {
    /// 视频时长（秒）转字符串（00:00:00）
    func videoDuration() -> String
}

extension Int: KKXVideoDurationProtocol {
    public func videoDuration() -> String {
        let formater = "%.2d"
        let duration = self
        
        var durationString: String
        if duration < Int.aHour {
            let minute = duration/Int.aMinute
            let second = duration%Int.aMinute
            durationString = String(format: "\(formater):\(formater)", minute, second)
        }
        else {
            let hour = duration/Int.aHour
            let minute = duration%Int.aHour/Int.aMinute
            let second = duration%Int.aMinute
            durationString = String(format: "\(formater):\(formater):\(formater)", hour, minute, second)
        }
        return durationString
    }
}
extension Double: KKXVideoDurationProtocol {
    public func videoDuration() -> String {
        Int(self).videoDuration()
    }
}
extension Float: KKXVideoDurationProtocol {
    public func videoDuration() -> String {
        Int(self).videoDuration()
    }
}

extension CGFloat: KKXVideoDurationProtocol {
    public func videoDuration() -> String {
        Int(self).videoDuration()
    }
}

// MARK: - InputDelegate

public protocol InputDelegate: NSObjectProtocol {
    
    var inputResponders: [UIView?] { get }
    
    func inputCancelButtonAction()
    func inputDoneButtonAction()

    func inputWillFocusPreviousStep()
    func inputDidFocusPreviousStep()
    
    func inputWillFocusNextStep()
    func inputDidFocusNextStep()
}

extension InputDelegate {
    public var inputResponders: [UIView?] { [] }
    
    public func inputCancelButtonAction() { }
    public func inputDoneButtonAction() { }
    
    public func inputWillFocusPreviousStep() { }
    public func inputDidFocusPreviousStep() { }
    
    public func inputWillFocusNextStep() { }
    public func inputDidFocusNextStep() { }
}

// MARK: - DatePickerDelegate

public protocol DatePickerDelegate: NSObjectProtocol {
    var kkxDatePicker: UIDatePicker { get }
    func kkxDatePickerValueChanged(_ datePicker: UIDatePicker)
}

extension DatePickerDelegate {
    /// UITextField().inputView = datePicker
    /// 年月 datePickerMode = UIDatePicker.Mode(rawValue: 4269)!
    public var kkxDatePicker: UIDatePicker {
        if let datePicker = objc_getAssociatedObject(self, &kkxDatePickerKey) as? UIDatePicker {
            return datePicker
        }
        else {
            // 设置最小、最大时间
            /*
             let maximumDate = Date()
             let calendar = Calendar.current
             let dateComponents = DateComponents(year: -100, month: 1 - calendar.component(.month, from: maximumDate), day: 1 - calendar.component(.day, from: maximumDate))
             let minimumDate = calendar.date(byAdding: dateComponents, to: maximumDate)
             picker.maximumDate = maximumDate
             picker.minimumDate = minimumDate
             
             /// 年月
             datePicker.datePickerMode = UIDatePicker.Mode(rawValue: 4269)!
             */
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(kkxDatePickerHandler, action: #selector(kkxDatePickerHandler.kkxValueChanged(_:)), for: .valueChanged)
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            objc_setAssociatedObject(self, &kkxDatePickerKey, datePicker, .OBJC_ASSOCIATION_RETAIN)
            return datePicker
        }
    }
    
    private var kkxDatePickerHandler: DatePickerDelegateHander {
        guard let handler = objc_getAssociatedObject(self, &kkxDatePickerHandlerKey) as? DatePickerDelegateHander else {
            let newHandler = DatePickerDelegateHander(delegate: self)
            objc_setAssociatedObject(self, &kkxDatePickerHandlerKey, newHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newHandler
        }
        return handler
    }
    public func kkxDatePickerValueChanged(_ datePicker: UIDatePicker) { }
}
private var kkxDatePickerKey: UInt8 = 0
private var kkxDatePickerHandlerKey: UInt8 = 0

fileprivate class DatePickerDelegateHander: NSObject {
    
    init(delegate: DatePickerDelegate?) {
        self.delegate = delegate
    }
    weak var delegate: DatePickerDelegate?
    
    @objc func kkxValueChanged(_ datePicker: UIDatePicker) {
        delegate?.kkxDatePickerValueChanged(datePicker)
    }
}

// MARK: - InputAccessoryBarStyle

public enum InputAccessoryBarStyle {
    /// 取消  完成
    case `default`
    
    /// 完成
    case done
    
    /// 上一个 下一个  完成
    case stepArrow
    case stepText
}

public protocol AccessoryBarDelegate: InputDelegate {
    
    var inputAccessoryBar: UIToolbar { get }
    
    var accessoryBarStyle: InputAccessoryBarStyle { get set }
    
    var kkxFirstResponder: UIView? { get set }
    
    var inputCancelItem: UIBarButtonItem { get }
    
    var inputDoneItem: UIBarButtonItem { get }
    
    var previousStepItem: UIBarButtonItem { get }
    
    var nextStepItem: UIBarButtonItem { get }
    
    func kkxFocusPreviousResponder()
    
    func kkxFocusNextResponder()
}

extension AccessoryBarDelegate {
    
    /// UITextField().inputAccessoryView = inputAccessoryBar
    public var inputAccessoryBar: UIToolbar {
        if let bar = objc_getAssociatedObject(self, &inputAccessoryBarKey) as? UIToolbar {
            return bar
        }
        else {
            let bar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
            bar.tintColor = .kkxAccessoryBar
            objc_setAssociatedObject(self, &inputAccessoryBarKey, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            accessoryBarStyle = .stepArrow
            return bar
        }
    }
    
    public var accessoryBarStyle: InputAccessoryBarStyle {
        get {
            let style = objc_getAssociatedObject(self, &inputAccessoryBarStyleKey) as? InputAccessoryBarStyle
            return style ?? .default
        }
        set {
            switch newValue {
            case .default:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                inputAccessoryBar.items = [inputCancelItem, flexibleSpaceItem, inputDoneItem]
            case .done:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                inputAccessoryBar.items = [flexibleSpaceItem, inputDoneItem]
            case .stepArrow:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                fixedSpaceItem.width = 10
                
                let upConfiguration = UIImage.ItemConfiguration(direction: .up, lineWidth: 2.0, tintColor: .kkxAccessoryBar, width: 10)
                let downConfiguration = UIImage.ItemConfiguration(direction: .down, lineWidth: 2.0, tintColor: .kkxAccessoryBar, width: 10)
                let upImage = UIImage.itemImage(with: upConfiguration)
                let downImage = UIImage.itemImage(with: downConfiguration)
                
                previousStepItem.image = upImage
                previousStepItem.title = nil
                nextStepItem.image = downImage
                nextStepItem.title = nil
                inputAccessoryBar.items = [previousStepItem, fixedSpaceItem, nextStepItem, flexibleSpaceItem, inputDoneItem]
            case .stepText:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                previousStepItem.image = nil
                previousStepItem.title = KKXExtensionString("previous.step")
                nextStepItem.image = nil
                nextStepItem.title = KKXExtensionString("next.step")
                inputAccessoryBar.items = [previousStepItem, nextStepItem, flexibleSpaceItem, inputDoneItem]
            }
            objc_setAssociatedObject(self, &inputAccessoryBarStyleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var kkxFirstResponder: UIView? {
        get {
            let responder = objc_getAssociatedObject(self, &theFirstResponderKey) as? UIView
            return responder
        }
        set {
            objc_setAssociatedObject(self, &theFirstResponderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func kkxFocusPreviousResponder() {
        kkxAccessoryBarHandler.kkxFocusPreviousResponder()
    }
    
    public func kkxFocusNextResponder() {
        kkxAccessoryBarHandler.kkxFocusNextResponder()
    }
    
    public var inputCancelItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &inputCancelItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: kkxAccessoryBarHandler, action: #selector(kkxAccessoryBarHandler.kkxInputCancelAction))
            objc_setAssociatedObject(self, &inputCancelItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var inputDoneItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &inputDoneItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: kkxAccessoryBarHandler, action: #selector(kkxAccessoryBarHandler.kkxDoneAction))
            objc_setAssociatedObject(self, &inputDoneItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var previousStepItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &previousStepItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(title: KKXExtensionString("previous.step"), style: .plain, target: kkxAccessoryBarHandler, action: #selector(kkxAccessoryBarHandler.kkxPreviousStepAction))
            item.tintColor = .kkxAccessoryBar
            objc_setAssociatedObject(self, &previousStepItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var nextStepItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &nextStepItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(title: KKXExtensionString("next.step"), style: .plain, target: kkxAccessoryBarHandler, action: #selector(kkxAccessoryBarHandler.kkxNextStepAction))
            item.tintColor = .kkxAccessoryBar
            objc_setAssociatedObject(self, &nextStepItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    private var kkxAccessoryBarHandler: AccessoryBarDelegateHander {
        guard let handler = objc_getAssociatedObject(self, &kkxAccessoryBarHanderKey) as? AccessoryBarDelegateHander else {
            let newHandler = AccessoryBarDelegateHander(delegate: self)
            objc_setAssociatedObject(self, &kkxAccessoryBarHanderKey, newHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newHandler
        }
        return handler
    }
}
private var inputAccessoryBarKey: UInt8 = 0
private var inputAccessoryBarStyleKey: UInt8 = 0
private var theFirstResponderKey: UInt8 = 0
private var inputCancelItemKey: UInt8 = 0
private var inputDoneItemKey: UInt8 = 0
private var previousStepItemKey: UInt8 = 0
private var nextStepItemKey: UInt8 = 0
private var kkxAccessoryBarHanderKey: UInt8 = 0

fileprivate class AccessoryBarDelegateHander: NSObject {
    
    init(delegate: AccessoryBarDelegate?) {
        self.delegate = delegate
    }
    weak var delegate: AccessoryBarDelegate?
    
    @objc func kkxInputCancelAction() {
        if let view = delegate as? UIView {
            view.endEditing(true)
        } else if let viewController = delegate as? UIViewController {
            viewController.view.endEditing(true)
        }
        delegate?.inputCancelButtonAction()
    }
    
    @objc func kkxPreviousStepAction() {
        delegate?.inputWillFocusPreviousStep()
        kkxFocusPreviousResponder()
        delegate?.inputDidFocusPreviousStep()
    }
    
    @objc func kkxNextStepAction() {
        delegate?.inputWillFocusNextStep()
        kkxFocusNextResponder()
        delegate?.inputDidFocusNextStep()
    }
    
    @objc func kkxDoneAction() {
        if let view = delegate as? UIView {
            view.endEditing(true)
        } else if let viewController = delegate as? UIViewController {
            viewController.view.endEditing(true)
        }
        delegate?.kkxFirstResponder = nil
        delegate?.inputDoneButtonAction()
    }
    
    func kkxFocusPreviousResponder() {
        if let responder = delegate?.kkxFirstResponder,
            responder.isFirstResponder,
            let inputResponders = delegate?.inputResponders,
            let index = inputResponders.firstIndex(of: responder),
            index > 0 {
            
            inputResponders[index - 1]?.becomeFirstResponder()
        }
    }
    
    func kkxFocusNextResponder() {
        if let responder = delegate?.kkxFirstResponder,
            responder.isFirstResponder,
            let inputResponders = delegate?.inputResponders,
            let index = inputResponders.firstIndex(of: responder) {
            
            if index < inputResponders.count - 1 {
                inputResponders[index + 1]?.becomeFirstResponder()
            } else if index == inputResponders.count - 1 {
                inputResponders[index]?.resignFirstResponder()
            }
        }
    }
}
