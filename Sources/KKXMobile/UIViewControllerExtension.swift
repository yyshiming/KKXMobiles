//
//  UIViewControllerExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit
import Photos
import PhotosUI

// MARK: - ======== 导航栏 Style ========

public struct KKXNavigationBarStyle {
    
    public init(backgroundImage: UIImage? = nil, backgroundColor: UIColor? = nil, itemsColor: UIColor = .kkxBlack, titleTextAttributes: [NSAttributedString.Key: Any] = [:], isTranslucent: Bool = true, statusBarStyle: UIStatusBarStyle = .default, shadowImage: UIImage? = nil, shadowColor: UIColor? = nil) {
        self.backgroundImage = backgroundImage
        self.backgroundColor = backgroundColor
        self.itemsColor = itemsColor
        self.titleTextAttributes = titleTextAttributes
        self.isTranslucent = isTranslucent
        self.statusBarStyle = statusBarStyle
        self.shadowImage = shadowImage
        self.shadowColor = shadowColor
    }
    
    /// 背景图片，默认nil
    public var backgroundImage: UIImage?
    /// 背景色，默认nil
    public var backgroundColor: UIColor?
    /// apply to navigation items and bar button items，默认UIColor.black
    public var itemsColor = UIColor.kkxBlack
    /// 标题文本
    public var titleTextAttributes: [NSAttributedString.Key: Any] = [:]
    /// 是否透明
    public var isTranslucent = true
    /// 状态栏
    public var statusBarStyle = UIStatusBarStyle.default
    /// 阴影图片
    public var shadowImage: UIImage?
    /// 阴影颜色
    public var shadowColor: UIColor?
    
    /// 设置导航栏为默认半透明，item、title、状态栏为黑色
    public static func `default`() -> KKXNavigationBarStyle {
        KKXNavigationBarStyle()
    }
    
    public static func theme() -> KKXNavigationBarStyle {
        var configuration = KKXNavigationBarStyle()
        configuration.backgroundColor = defaultConfiguration.themeColor
        configuration.itemsColor = .white
        configuration.titleTextAttributes = [.foregroundColor: UIColor.white]
        configuration.isTranslucent = false
        configuration.statusBarStyle = .lightContent
        return configuration
    }
    
    /// 设置导航栏为背景色半透明，item、title、状态栏为黑色
    public static func background() -> KKXNavigationBarStyle {
        var configuration = KKXNavigationBarStyle()
        configuration.backgroundColor = defaultConfiguration.mainBackground
        return configuration
    }
    
    /// 设置导航栏为背景色全透明，item、title、状态栏为黑色
    public static func clear() -> KKXNavigationBarStyle {
        var configuration = KKXNavigationBarStyle()
        configuration.backgroundImage = UIColor.clear.image
        return configuration
    }
}


extension UIViewController {
    
    /// 单独设置导航栏风格，默认为default()
    public var kkxNavigationBarStyle: KKXNavigationBarStyle {
        get {
            if let style = objc_getAssociatedObject(self, &navigationBarStyleKey) as? KKXNavigationBarStyle {
                return style
            }
            return defaultConfiguration.navigationBarStyle
        }
        set {
            objc_setAssociatedObject(self, &navigationBarStyleKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    // 应用设置的导航栏效果
    public func applyNavigationBarStyle(_ configuration: KKXNavigationBarStyle) {
        
        var navController: UINavigationController?
        if self is UINavigationController {
            navController = self as? UINavigationController
        } else {
            navController = navigationController
        }
        
        if #available(iOS 15.0, *) {
            let newAppearance = UINavigationBarAppearance()
            newAppearance.backgroundImage = configuration.backgroundImage
            newAppearance.backgroundColor = configuration.backgroundColor
            newAppearance.shadowImage = configuration.shadowImage
            newAppearance.shadowColor = configuration.shadowColor
            newAppearance.titleTextAttributes = configuration.titleTextAttributes
            
            if let navController = self as? UINavigationController {
                navController.navigationBar.standardAppearance = newAppearance
                navController.navigationBar.scrollEdgeAppearance = newAppearance
            } else {
                navigationItem.standardAppearance = newAppearance
                navigationItem.scrollEdgeAppearance = newAppearance
            }
        } else {
            navController?.navigationBar.setBackgroundImage(configuration.backgroundImage, for: .default)
            navController?.navigationBar.barTintColor = configuration.backgroundColor
            setTitleAttributes(configuration.titleTextAttributes)
        }
        
        navController?.navigationBar.tintColor = configuration.itemsColor
        navController?.navigationBar.isTranslucent = configuration.isTranslucent
        kkxStatusBarStyle = configuration.statusBarStyle
        
        children.forEach { $0.applyNavigationBarStyle(configuration) }
    }
    
    /// 设置标题颜色
    public func setTitleAttributes(_ attributes: [NSAttributedString.Key: Any]) {
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    /// 导航栏透明度，默认1.0
    public var kkxNavBarBgAlpha: CGFloat {
        get {
            let alpha = objc_getAssociatedObject(self, &kkxNavBarBgAlphaKey) as? CGFloat
            return alpha ?? 1.0
        }
        set {
            applyNavBarAlpha(newValue)
            objc_setAssociatedObject(self, &kkxNavBarBgAlphaKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public func applyNavBarAlpha(_ alpha: CGFloat) {
        var navigationBar = navigationController?.navigationBar
        if let navController = self as? UINavigationController {
            navigationBar = navController.navigationBar
        }

        if let barBackgroundView = navigationBar?.subviews.first {
            if #available(iOS 13.0, *)  {
                barBackgroundView.alpha = alpha
            } else {
                for view in barBackgroundView.subviews {
                    if view is UIVisualEffectView {
                        view.alpha = alpha
                        break
                    }
                }
            }
        }
    }
}
private var navigationBarStyleKey: UInt8 = 0
private var kkxNavBarBgAlphaKey: UInt8 = 0


extension UIViewController {
    
    // MARK: -------- Properties --------
    
    /// 是否应该刷新数据，默认false
    public var shouldReloadData: Bool {
        get {
            let first = objc_getAssociatedObject(self, &shouldReloadDataKey) as? Bool
            return first ?? false
        }
        set {
            objc_setAssociatedObject(self, &shouldReloadDataKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// TableView  Style: plain
    public var plainTableView: UITableView {
        if let tableView = objc_getAssociatedObject(self, &plainTableViewKey) as? UITableView {
            return tableView
        }
        else {
            let tableView = UITableView(frame: CGRect.zero, style: .plain)
            tableView.tableFooterView = UIView()
            tableView.backgroundColor = .clear
            tableView.alwaysBounceVertical = true
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            view.addSubview(tableView)
            
            objc_setAssociatedObject(self, &plainTableViewKey, tableView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tableView
        }
    }
    
    /// TableView  Style: group
    public var groupedTableView: UITableView {
        if let tableView = objc_getAssociatedObject(self, &groupedTableViewKey) as? UITableView {
            return tableView
        }
        else {
            let tableView = UITableView(frame: CGRect.zero, style: .grouped)
            tableView.tableFooterView = UIView()
            tableView.backgroundColor = .clear
            view.addSubview(tableView)
            view.sendSubviewToBack(tableView)
            
            objc_setAssociatedObject(self, &groupedTableViewKey, tableView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tableView
        }
    }
    
    /// statusBar高度
    public var kkxStatusBarHeight: CGFloat {
        var statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = kkxWindowScene?.statusBarManager?.statusBarFrame ?? .zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        return statusBarFrame.height
    }
    
    /// navbar高度
    public var kkxNavBarHeight: CGFloat {
        navigationController?.navigationBar.frame.height ?? 0
    }
    
    /// tabbar高度
    public var kkxTabBarHeight: CGFloat {
        tabBarController?.tabBar.frame.height ?? 0
    }
    
    /// statusBar + navbar高度
    public var kkxTop: CGFloat {
        var isStatusBarHidden: Bool
        if #available(iOS 13.0, *) {
            isStatusBarHidden = kkxWindowScene?.statusBarManager?.isStatusBarHidden ?? false
        } else {
            isStatusBarHidden = UIApplication.shared.isStatusBarHidden
        }
        var top: CGFloat = 0
        if !isStatusBarHidden {
            top += kkxStatusBarHeight
        }
        if navigationController?.navigationBar.isHidden == false {
            top += kkxNavBarHeight
        }
        return top
    }

    /// tabbar高度
    public var kkxBottom: CGFloat {
        var bottom: CGFloat = 0
        if tabBarController?.tabBar.isHidden == false {
            bottom += kkxTabBarHeight
        }
        return bottom
    }
    
}
private var shouldReloadDataKey: UInt8 = 0
private var plainTableViewKey: UInt8 = 0
private var groupedTableViewKey: UInt8 = 0


extension UIViewController {

    /// 要pop到的viewController
    public weak var pushingViewController: UIViewController? {
        get {
            let viewcontroller = objc_getAssociatedObject(self, &pushingViewControllerKey) as? UIViewController
            return viewcontroller
        }
        set {
            objc_setAssociatedObject(self, &pushingViewControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
private var pushingViewControllerKey: UInt8 = 0

extension UIViewController {
    
    /// 是否隐藏导航栏,默认false
    public var isNavigationBarHidden: Bool {
        get {
            let first = objc_getAssociatedObject(self, &isNavigationBarHiddenKey) as? Bool
            return first ?? false
        }
        set {
            objc_setAssociatedObject(self, &isNavigationBarHiddenKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var kkxAdditionalInsets: UIEdgeInsets {
        get {
            let insets = objc_getAssociatedObject(self, &additionalInsetsKey) as? UIEdgeInsets
            return insets ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &additionalInsetsKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var kkxBackItemHandler: (() -> Void)? {
        get {
            let handler = objc_getAssociatedObject(self, &kkxBackItemHandlerKey) as? () -> Void
            return handler
        }
        set {
            objc_setAssociatedObject(self, &kkxBackItemHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
private var isNavigationBarHiddenKey: UInt8 = 0
private var additionalInsetsKey: UInt8 = 0
private var kkxBackItemHandlerKey: UInt8 = 0

// MARK: - ======== swizzle ========
extension UIViewController {
    
    public class func initializeController() {
        
        kkxSwizzleSelector(self, originalSelector: #selector(viewDidLoad), swizzledSelector: #selector(kkxViewDidLoad))
        kkxSwizzleSelector(self, originalSelector: #selector(viewWillAppear(_:)), swizzledSelector: #selector(kkxViewWillAppear(_:)))
        kkxSwizzleSelector(self, originalSelector: #selector(viewDidAppear(_:)), swizzledSelector: #selector(kkxViewDidAppear(_:)))
        kkxSwizzleSelector(self, originalSelector: #selector(viewWillDisappear(_:)), swizzledSelector: #selector(kkxViewWillDisappear(_:)))
        
        kkxSwizzleSelector(self, originalSelector: #selector(getter: preferredStatusBarStyle), swizzledSelector: #selector(kkxStatusBarUpdateStyle))
        kkxSwizzleSelector(self, originalSelector: #selector(getter: preferredStatusBarUpdateAnimation), swizzledSelector: #selector(kkxStatusBarUpdateAnimation))
    }
}

// MARK: - ======== Life Circle ========

extension UIViewController {
    
    @objc private func kkxViewDidLoad() {
        if self is KKXCustomBackItemProtocol {
            if navigationController?.viewControllers.first == self { return }
            if let backItemImage = defaultConfiguration.customBackBarButtonItemImage {
                let backItem = UIBarButtonItem(image: backItemImage, style: .plain, target: nil, action: nil)
                backItem.imageInsets = defaultConfiguration.customBackImageInsets
                backItem.target = self
                backItem.action = #selector(kkxBackItemAction)
                navigationItem.leftBarButtonItem = backItem
            }
        }
        if self is KKXShowCancelItemOnIpadProtocol, isPad {
            navigationItem.rightBarButtonItem = kkxCancelItem
        }
        
        self.kkxViewDidLoad()
    }
    
    @objc private func kkxViewWillAppear(_ animated: Bool) {
        if self is KKXCustomNavigationBarProtocol {
            applyNavigationBarStyle(kkxNavigationBarStyle)
        }
        kkxIsVisible = true
        self.kkxViewWillAppear(animated)
    }
    
    @objc private func kkxViewDidAppear(_ animated: Bool) {
        self.kkxViewDidAppear(animated)
    }
    
    @objc private func kkxViewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
        kkxIsVisible = false
        self.kkxViewWillDisappear(animated)
    }
    
    @objc public func kkxBackItemAction() {
        if kkxBackItemHandler != nil {
            kkxBackItemHandler?()
        } else {
            if let navigationController = self as? UINavigationController {
                navigationController.popViewController(animated: true)
            } else if navigationController != nil {
                navigationController?.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - ======== 状态栏 Style ========
extension UIViewController {
    
    public var kkxStatusBarAnimation: UIStatusBarAnimation {
        get {
            let style = objc_getAssociatedObject(self, &statusBarAnimationKey) as? UIStatusBarAnimation
            return style ?? UIStatusBarAnimation.none
        }
        set {
            objc_setAssociatedObject(self, &statusBarAnimationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var kkxStatusBarStyle: UIStatusBarStyle {
        get {
            let style = objc_getAssociatedObject(self, &statusBarStyleKey) as? UIStatusBarStyle
            return style ?? UIStatusBarStyle.default
        }
        set {
            objc_setAssociatedObject(self, &statusBarStyleKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc private func kkxStatusBarUpdateStyle() -> UIStatusBarStyle {
        return kkxStatusBarStyle
    }
    
    @objc private func kkxStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return kkxStatusBarAnimation
    }
}
private var statusBarAnimationKey: UInt8 = 0
private var statusBarStyleKey: UInt8 = 0


// MARK: - ======== Custom Items ========
extension UIViewController {

    public var kkxCancelItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &cancelItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(kkxCancelAction))
            objc_setAssociatedObject(self, &cancelItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var kkxCancelButton: UIButton {
        guard let button = objc_getAssociatedObject(self, &cancelButtonKey) as? UIButton else {
            let button = UIButton(type: .system)
            button.setTitle(KKXExtensionString("cancel"), for: .normal)
            button.tintColor = UIColor.kkxBlack
            button.addTarget(self, action: #selector(kkxCancelAction), for: .touchUpInside)
            objc_setAssociatedObject(self, &cancelButtonKey, button, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return button
        }
        return button
    }
    
    @objc private func kkxCancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    public var kkxDefaultBackButton: UIButton {
        guard let button = objc_getAssociatedObject(self, &defaultBackButtonKey) as? UIButton else {
            let button = UIButton(type: .system)
            button.setImage(defaultConfiguration.defaultBackImage, for: .normal)
            button.tintColor = UIColor.kkxBlack
            button.addTarget(self, action: #selector(kkxBackItemAction), for: .touchUpInside)
            objc_setAssociatedObject(self, &defaultBackButtonKey, button, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return button
        }
        return button
    }
    
    /// UIViewController是否正在显示
    @objc open var kkxIsVisible: Bool {
        get {
            let isVisible = objc_getAssociatedObject(self, &isVisibleKey) as? Bool
            return isVisible ?? false
        }
        set {
            objc_setAssociatedObject(self, &isVisibleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
private var cancelItemKey: UInt8 = 0
private var cancelButtonKey: UInt8 = 0
private var defaultBackButtonKey: UInt8 = 0
private var isVisibleKey: UInt8 = 0


public typealias FinishPickingHandler = (([UIImagePickerController.InfoKey : Any]) -> Void)

// MARK: - ======== UIImagePickerController ========
extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    private var finishPickingHandler: FinishPickingHandler? {
        get {
            objc_getAssociatedObject(self, &finishPickingKey) as? (([UIImagePickerController.InfoKey : Any]) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &finishPickingKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var kkxAllowsEditing: Bool {
        get {
            let allowsEditing = objc_getAssociatedObject(self, &allowsEditingKey) as? Bool
            return allowsEditing ?? false
        }
        set {
            objc_setAssociatedObject(self, &allowsEditingKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// 选择照片来源
    public func selectPhoto(_ allowsEditing: Bool = false, completion: FinishPickingHandler? = nil) {
        kkxAllowsEditing = allowsEditing
        finishPickingHandler = completion
        let cancelAction = UIAlertAction(title: KKXExtensionString("cancel"), style: .cancel) { (action) in
            
        }
        let photosAction = UIAlertAction(title: KKXExtensionString("album"), style: .default) { (action) in
            self.selectPhoto(from: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: KKXExtensionString("camera"), style: .default) { (action) in
            self.selectPhoto(from: .camera)
        }
        alert(.actionSheet,
              actions: [cancelAction, cameraAction, photosAction])
    }
    
    public func selectPhoto(from sourceType: UIImagePickerController.SourceType,
                            completion: FinishPickingHandler? = nil) {
        if completion != nil {
            finishPickingHandler = completion
        }
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
//            if #available(iOS 14, *) {
//                showLimitedPicker()
//            }
//            return
            switch sourceType {
            case .photoLibrary, .savedPhotosAlbum:
                photoAuthorized {
                    self.showPickController(sourceType)
                }
            case .camera:
                cameraAuthorized {
                    self.showPickController(sourceType)
                }
            default:
                break
            }
        } else {
            alertRestricted(sourceType != .camera)
        }
    }
    
    private func showPickController(_ sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        controller.allowsEditing = kkxAllowsEditing
        controller.mediaTypes = ["public.image"]
        present(controller, animated: true, completion: nil)
    }
    
    /// 选择相册或拍照后回调
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        finishPickingHandler?(info)
        dismiss(animated: true, completion:nil)
    }
}
private var finishPickingKey: UInt8 = 0
private var allowsEditingKey: UInt8 = 0

// MARK: - ======== 相册、相机授权 ========
extension UIViewController {
    
    // MRK: -------- Helper --------
    
    /// UIAlertController - sourceView 默认nil
    public var kkxSourceView: UIView? {
        get {
            let sourceView = objc_getAssociatedObject(self, &sourceViewKey) as? UIView
            return sourceView
        }
        set {
            objc_setAssociatedObject(self, &sourceViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// UIAlertController - sourceRect 默认 CGRect.zero
    public var kkxSourceRect: CGRect {
        get {
            let sourceRect = objc_getAssociatedObject(self, &sourceRectKey) as? CGRect
            return sourceRect ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &sourceRectKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// UIAlertController - permittedArrowDirections 默认 any
    public var kkxPermittedArrowDirections: UIPopoverArrowDirection {
        get {
            let permittedArrowDirections = objc_getAssociatedObject(self, &permittedArrowDirectionsKey) as? UIPopoverArrowDirection
            return permittedArrowDirections ?? .any
        }
        set {
            objc_setAssociatedObject(self, &permittedArrowDirectionsKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public func alert(_ style: UIAlertController.Style,
                      title: String? = nil,
                      message: String? = nil,
                      actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alertController.addAction(action)
        }
        if isPad, style == .actionSheet {
            let popoverController = alertController.popoverPresentationController
            popoverController?.sourceView = kkxSourceView
            popoverController?.sourceRect = kkxSourceRect
            popoverController?.permittedArrowDirections = kkxPermittedArrowDirections
        }
        present(alertController, animated: true, completion: nil)
    }
    
    public func retry(message: String? = nil, action retryAction: @escaping (() -> Swift.Void)) {
        let alertAction = UIAlertAction(title: KKXExtensionString("retry"), style: .default) { (action) in
            retryAction()
        }
        alert(.alert, title: KKXExtensionString("error"), message: message, actions: [alertAction])
    }
    
    /// 获取相册权限
    public func photoAuthorized(_ authorized: @escaping () -> Void) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.kkx_safe {
                    switch status {
                    case .authorized:
                        authorized()
                    default:
                        self.alertDenied()
                    }
                }
            }
        case .restricted:
            alertRestricted()
        case .denied:
            alertDenied()
        case .authorized:
            authorized()
        default:
            break
        }
    }
    
    /// 获取相机权限
    public func cameraAuthorized(_ authorized: @escaping () -> Void) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                DispatchQueue.kkx_safe {
                    if granted {
                        authorized()
                    }
                    else {
                        self.alertDenied(false)
                    }
                }
            }
        case .restricted:
            alertRestricted(false)
        case .denied:
            alertDenied(false)
        case .authorized:
            authorized()
        @unknown default:
            break
        }
        
    }
    
    /// 设备不支持
    private func alertRestricted(_ photo: Bool = true) {
        let message: String?
        if photo {
            message = KKXExtensionString("device.album.unavailable")
        }
        else {
            message = KKXExtensionString("device.camera.unavailable")
        }
        let action = UIAlertAction(title: KKXExtensionString("ok"), style: .default) { (action) in }
        self.alert(.alert, title: nil, message: message, actions: [action])
    }
    
    /// 用户拒绝开启相册或相机权限提示
    private func alertDenied(_ photo: Bool = true) {
        let name = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "unknown"
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? name
        let message: String?
        if photo {
            message = String(format: KKXExtensionString("device.album.access.format"), appName)
        }
        else {
            message = String(format: KKXExtensionString("device.camera.access.format"), appName)
        }
        let cancelAction = UIAlertAction(title: KKXExtensionString("cancel"), style: .cancel) { (action) in }
        let goAction = UIAlertAction(title: KKXExtensionString("go.to.settings"), style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        self.alert(.alert, title: nil, message: message, actions: [cancelAction, goAction])
    }
    
}
private var sourceViewKey: UInt8 = 0
private var sourceRectKey: UInt8 = 0
private var permittedArrowDirectionsKey: UInt8 = 0

// MARK: - ======== 保存图片到相册 ========
extension UIViewController {
    
    public func kkxSavePhoto(_ image: UIImage?, began: (() -> Void)? = nil, completion: ((Bool, String, Error?) -> Void)? = nil) {
        guard let _ = image else { return }
        
        photoAuthorized {
            began?()
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }) { (success, error) in
                DispatchQueue.kkx_safe {
                    var text: String
                    if success {
                        text = KKXExtensionString("saved.to.album")
                    } else {
                        text = KKXExtensionString("save.failure")
                    }
                    completion?(success, text, error)
                }
            }
        }
    }
    
}

// MARK: - ======== 自定义backItem、rightItems ========

/// 自定义barItemSize
public let kkxBarItemSize = CGSize(width: 36, height: 44)
public struct ItemsSettingsConfiguration {
    
    public init (minMarginTop: CGFloat = 0, itemSpacing: CGFloat = 5, itemSize: CGSize = kkxBarItemSize, itemsLeft: CGFloat = 5, itemsRight: CGFloat = 5) {
        self.minMarginTop = minMarginTop
        self.itemSpacing = itemSpacing
        self.itemSize = itemSize
        self.itemsLeft = itemsLeft
        self.itemsRight = itemsRight
    }
    
    public var minMarginTop: CGFloat = 0
    public var itemSpacing: CGFloat = 5
    public var itemSize = kkxBarItemSize
    public var itemsLeft: CGFloat = 5
    public var itemsRight: CGFloat = 5
}

extension UIViewController {
    
    public var kkxBackItem: UIView? {
        get {
            let item = objc_getAssociatedObject(self, &backItemKey) as? UIView
            return item
        }
        set {
            if let item = kkxBackItem {
                item.removeFromSuperview()
            }
            if let newItem = newValue {
                view.addSubview(newItem)
                newItem.translatesAutoresizingMaskIntoConstraints = false
                
                let minTopMargin = _kkxBackItemSettings.minMarginTop
                if #available(iOS 11.0, *) {
                    let leftConstant = CGFloat(view.safeAreaInsets.left > 0 ? 0 : _kkxBackItemSettings.itemsLeft)
                    NSLayoutConstraint(item: newItem, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1.0, constant: leftConstant).isActive = true
                    
                    NSLayoutConstraint(item: newItem, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: minTopMargin).isActive = true
                } else {
                    NSLayoutConstraint(item: newItem, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: _kkxBackItemSettings.itemsLeft).isActive = true
                    NSLayoutConstraint(item: newItem, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: minTopMargin).isActive = true
                }
                
                NSLayoutConstraint(item: newItem, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: _kkxBackItemSettings.itemSize.width).isActive = true
                NSLayoutConstraint(item: newItem, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: _kkxBackItemSettings.itemSize.height).isActive = true
            }
            objc_setAssociatedObject(self, &backItemKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func kkxSetBackItem(_ item: UIView?, settings: ItemsSettingsConfiguration? = nil) {
        if let settings = settings {
            _kkxBackItemSettings = settings
        }
        kkxBackItem = item
    }
    
    public var kkxBackItemSettings: ItemsSettingsConfiguration? {
        _kkxBackItemSettings
    }
    
    private var _kkxBackItemSettings: ItemsSettingsConfiguration {
        get {
            let settings = objc_getAssociatedObject(self, &backItemSettingsKey) as? ItemsSettingsConfiguration
            return settings ?? ItemsSettingsConfiguration()
        }
        set {
            objc_setAssociatedObject(self, &backItemSettingsKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var kkxRightItems: [UIView]? {
        get {
            let items = objc_getAssociatedObject(self, &rightItemsKey) as? [UIView]
            return items
        }
        set {
            objc_setAssociatedObject(self, &rightItemsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let items = kkxRightItems, !items.isEmpty {
                for subview in kkxRightItemsStackView.arrangedSubviews {
                    kkxRightItemsStackView.removeArrangedSubview(subview)
                }
                for newSubview in newValue ?? [] {
                    kkxRightItemsStackView.insertArrangedSubview(newSubview, at: 0)
                    NSLayoutConstraint(item: newSubview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: _kkxRightItemsSettings.itemSize.width).isActive = true
                    NSLayoutConstraint(item: newSubview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: _kkxRightItemsSettings.itemSize.height).isActive = true
                }
            } else {
                kkxRightItemsStackView.removeFromSuperview()
                objc_setAssociatedObject(self, &rightItemsStackViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public func kkxSetRightItems(_ items: [UIView]?, settings: ItemsSettingsConfiguration? = nil) {
        if let settings = settings {
            _kkxRightItemsSettings = settings
        }
        kkxRightItems = items
    }
    
    public var kkxRightItemsSettings: ItemsSettingsConfiguration? {
        _kkxRightItemsSettings
    }
    
    private var _kkxRightItemsSettings: ItemsSettingsConfiguration {
        get {
            let settings = objc_getAssociatedObject(self, &rightItemsSettingsKey) as? ItemsSettingsConfiguration
            return settings ?? ItemsSettingsConfiguration()
        }
        set {
            objc_setAssociatedObject(self, &rightItemsSettingsKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var kkxRightItemsStackView: UIStackView {
        guard let stackView = objc_getAssociatedObject(self, &rightItemsStackViewKey) as? UIStackView else {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            stackView.spacing = _kkxRightItemsSettings.itemSpacing
            objc_setAssociatedObject(self, &rightItemsStackViewKey, stackView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            configureRightItemsConstraint(stackView)
            
            return stackView
        }
        return stackView
    }
    
    private func configureRightItemsConstraint(_ stackView: UIView) {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let minTopMargin = _kkxRightItemsSettings.minMarginTop
        if #available(iOS 11.0, *) {
            let rightConstant = CGFloat(view.safeAreaInsets.right > 0 ? 0 : _kkxRightItemsSettings.itemsRight)
            NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .right, relatedBy: .equal, toItem: stackView, attribute: .right, multiplier: 1.0, constant: rightConstant).isActive = true
            
            NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: minTopMargin).isActive = true
        } else {
            NSLayoutConstraint(item: view!, attribute: .right, relatedBy: .equal, toItem: stackView, attribute: .right, multiplier: 1.0, constant: _kkxRightItemsSettings.itemsRight).isActive = true
            NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: minTopMargin).isActive = true
        }
        
        if kkxRightItems?.count ?? 0 > 0 {
            NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kkxBarItemSize.width).isActive = true
            NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kkxBarItemSize.height).isActive = true
        }
    }
}
private var backItemKey: UInt8 = 0
private var backItemSettingsKey: UInt8 = 0
private var rightItemsKey: UInt8 = 0
private var rightItemsSettingsKey: UInt8 = 0
private var rightItemsStackViewKey: UInt8 = 0

extension UIViewController {
    
    public var weakNavigationController: UINavigationController? {
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
