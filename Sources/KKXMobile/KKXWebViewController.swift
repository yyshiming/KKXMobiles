//
//  KKXWebViewController.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit
import WebKit

public typealias WebViewInterceptCallback = (KKXWebViewController, WKNavigationAction) -> WKNavigationActionPolicy

open class KKXWebViewController: KKXViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    // MARK: -------- Properties --------
    
    @objc
    public let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    /// 导航栏下方进度条
    public let progressView = UIProgressView(progressViewStyle: .bar)
        
    /// webView.scrollView.contentInsetAdjustmentBehavior
    @available(iOS 11.0, *)
    open var adjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior = .automatic {
        didSet {
            if isViewLoaded {
                webView.scrollView.contentInsetAdjustmentBehavior = adjustmentBehavior
            }
        }
    }
    
    /// 给H5界面传cookies
    open var cookies: [String: Any] = [:]

    /// 用在runJavaScriptTextInputPanelWithPrompt回调方法传参数
    open var customPrompt: [String: String] = [:]
    
    /// 是否显示输入弹框，默认发false
    open var showTextInputPanel = false
    
    /// 是否显示菊花动画，默认false
    open var showActivity: Bool = false
    
    /// 是否显示进度条，默认true
    open var showProgress: Bool = true {
        didSet {
            if isViewLoaded {
                progressView.isHidden = !showProgress
            }
        }
    }
    /// 是否显示取消按钮，默认false
    open var showCancelItem: Bool = false {
        didSet {
            reloadRightItems()
        }
    }
    /// 是否显示刷新按钮，默认false
    open var showRefreshItem: Bool = false {
        didSet {
            reloadRightItems()
        }
    }
    /// 是否显示底部工具view，默认true，显示
    open var isShowToolBar: Bool = true {
        didSet {
            reloadWebViewFrame()
        }
    }
    
    open var url: URL?
    
    open var request: URLRequest?
    
    open var fileURL: URL?
    open var readAccessURL: URL?
    
    /// html字符串
    open var htmlString: String?
    open var baseURL: URL?
    
    /// url拦截和回调
    public var intercepts: [String: WebViewInterceptCallback] {
        _intercepts
    }
    
    // MARK: -------- Public Function --------
    
    @discardableResult
    open func load(_ request: URLRequest) -> WKNavigation? {
        webView.load(request)
    }
    
    @available(iOS 9.0, *)
    @discardableResult
    open func loadFileURL(_ url: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
        webView.loadFileURL(url, allowingReadAccessTo: readAccessURL)
    }
    
    @discardableResult
    open func loadHTMLString(_ string: String, baseURL: URL? = nil)-> WKNavigation? {
        webView.loadHTMLString(string, baseURL: baseURL)
    }
    
    open func reload() {
        webView.reload()
    }
    
    open func goBack() {
        webView.goBack()
    }
    
    open func goForward() {
        webView.goForward()
    }
    
    /// 清理缓存
    open func clearAllCaches() {
        let types: Set = [WKWebsiteDataTypeMemoryCache]
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: dateFrom) {
            
        }
    }
    
    @discardableResult
    public func addIntercept(for prefix: String, callback: @escaping WebViewInterceptCallback) -> Self {
        _intercepts[prefix] = callback
        return self
    }
    
    private var _titleChangedHandler: ((String) -> Void)?
    /// 标题发生变化调用
    @discardableResult
    public func onTitleChanged(handler: @escaping (String) -> Void) -> Self {
        _titleChangedHandler = handler
        return self
    }

    private var _getContentHeightHandler: ((WKWebView, CGFloat) -> Void)?
    /// 加载完毕后获取web content的高度回调
    @discardableResult
    public func onGetContentHeight(handler: @escaping (WKWebView, CGFloat) -> Void) -> Self {
        _getContentHeightHandler = handler
        return self
    }
    
    private var _finishedHandler: ((WKWebView) -> Void)?
    /// 加载完成回调
    @discardableResult
    public func onFinished(handler: @escaping (WKWebView) -> Void) -> Self {
        _finishedHandler = handler
        return self
    }

    // MARK: -------- Private Properties --------

    /// url拦截和回调
    private var _intercepts: [String: WebViewInterceptCallback] = [:]
    
    private var refreshItem: UIBarButtonItem!
    
    private let toolBar = UIToolbar()
    
    private var goBackItem: UIBarButtonItem!
    private var goForwardItem: UIBarButtonItem!
    
    private var toolBarHeight: CGFloat {
        view.kkxSafeAreaInsets.bottom + 49
    }
    
    private var _isShowToolBar: Bool {
        isShowToolBar && webView.canGoBack && webView.canGoForward
    }
    
    private var webViewTitleObservation: NSKeyValueObservation?
    private var webViewProgressObservation: NSKeyValueObservation?
    private var webViewCanGoBackObservation: NSKeyValueObservation?
    private var webViewCanGoForwardObservation: NSKeyValueObservation?

    // MARK: -------- Init --------
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public init(url: URL?) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    public init(request: URLRequest?) {
        super.init(nibName: nil, bundle: nil)
        self.request = request
    }
    
    public init(fileURL: URL, allowingReadAccessTo readAccessURL: URL) {
        super.init(nibName: nil, bundle: nil)
        self.fileURL = fileURL
        self.readAccessURL = readAccessURL
    }
    
    public init(htmlString: String?, baseURL: URL? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.htmlString = htmlString
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.contentInsetAdjustmentBehavior = adjustmentBehavior
        
        configureSubviews()
        configureNavigationBar()
        configureProgressView()
        
        if !cookies.isEmpty {
            for (key, value) in cookies {
                let source = "document.cookie='\(key)=\(value)';"
                let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                kkxPrint(source)
                webView.configuration.userContentController.addUserScript(userScript)
            }
        }
        
        if let req = request {
            load(req)
        }
        else if let url = url {
            load(URLRequest(url: url))
        } else if let string = htmlString {
            loadHTMLString(string, baseURL: baseURL)
        } else if let fileURL = fileURL,
                    let readAccessURL = readAccessURL {
            loadFileURL(fileURL, allowingReadAccessTo: readAccessURL)
        }
        
        webViewTitleObservation = observe(\.webView.title) { object, _ in
            if let title = object.webView.title {
                object.navigationItem.title = title
                object._titleChangedHandler?(title)
            }
        }
        webViewProgressObservation = observe(\.webView.estimatedProgress) { object, _ in
            if object.showProgress {
                let progress = object.webView.estimatedProgress
                object.progressView.setProgress(Float(progress), animated: true)
                object.progressView.isHidden = (progress == 1.0)
            }
        }
        webViewCanGoBackObservation = observe(\.webView.title) { object, _ in
            object.reloadWebViewFrame()
        }
        webViewCanGoForwardObservation = observe(\.webView.title) { object, _ in
            object.reloadWebViewFrame()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadWebViewFrame()
        if #available(iOS 13.0, *), UITraitCollection.current.userInterfaceStyle == .dark {
            webView.scrollView.indicatorStyle = .white
        } else {
            webView.scrollView.indicatorStyle = .default
        }
    }
    
    private func reloadWebViewFrame() {
        guard isViewLoaded
        else { return }
        
        goBackItem.isEnabled = webView.canGoBack
        goForwardItem.isEnabled = webView.canGoForward
        toolBar.isHidden = !_isShowToolBar
        let webViewTop = view.safeAreaInsets.top
        var webViewHeight = view.bounds.height - webViewTop
        if !toolBar.isHidden {
            let offset = -view.kkxSafeAreaInsets.bottom / 2
            goBackItem.setBackgroundVerticalPositionAdjustment(offset, for: .default)
            goForwardItem.setBackgroundVerticalPositionAdjustment(offset, for: .default)
            toolBar.frame = CGRect(x: 0, y: view.bounds.height - toolBarHeight, width: view.bounds.width, height: toolBarHeight)
            webViewHeight -= toolBarHeight
        }
        
        webView.frame = CGRect(x: 0, y: webViewTop, width: view.bounds.width, height: webViewHeight)
    }
    
    // MARK: -------- Configuration --------
    
    private func configureNavigationBar() {
        reloadRightItems()
    }
    
    private func configureSubviews() {
        webView.backgroundColor = UIColor.kkxMainBackground
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        
        if let interactiveGesture = navigationController?.interactivePopGestureRecognizer {
            webView.scrollView.panGestureRecognizer.require(toFail: interactiveGesture)
        }
        
        toolBar.frame = CGRect(x: 0, y: view.bounds.height - toolBarHeight, width: view.bounds.width, height: toolBarHeight)
        
        view.addSubview(webView)
        view.addSubview(toolBar)
        
        let backConfiguration = UIImage.ItemConfiguration(direction: .left, lineWidth: 2.0, tintColor: .kkxAccessoryBar, width: 12)
        let forwardConfiguration = UIImage.ItemConfiguration(direction: .right, lineWidth: 2.0, tintColor: .kkxAccessoryBar, width: 12)
        let goBackImage = UIImage.itemImage(with: backConfiguration)
        let goForwardImage = UIImage.itemImage(with: forwardConfiguration)
        
        goBackItem = UIBarButtonItem(image: goBackImage, style: .plain, target: self, action: #selector(goBackAction))
        goBackItem.tintColor = .kkxAccessoryBar
        goBackItem.isEnabled = false
        
        goForwardItem = UIBarButtonItem(image: goForwardImage, style: .plain, target: self, action: #selector(goForwardAction))
        goForwardItem.tintColor = .kkxAccessoryBar
        goForwardItem.isEnabled = false
        
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceItem.width = 60
        let flexibleSpaceItem1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpaceItem2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.items = [flexibleSpaceItem1, goBackItem, fixedSpaceItem, goForwardItem, flexibleSpaceItem2]
        toolBar.isHidden = true
        
        refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
    }
    
    private func configureProgressView() {
        progressView.tintColor = UIColor.kkxSystemBlue
        view.addSubview(progressView)
        progressView.isHidden = !showProgress
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [
            .left, .width
        ]
        for attribute in attributes {
            NSLayoutConstraint(item: progressView, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: 0).isActive = true
        }
        NSLayoutConstraint(item: progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2.0).isActive = true
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint(item: progressView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        } else {
            NSLayoutConstraint(item: progressView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        }
    }
    
    private func reloadRightItems() {
        guard isViewLoaded
        else { return }
        
        var rightItems: [UIBarButtonItem] = []
        if showCancelItem {
            rightItems.append(kkxCancelItem)
        }
        if let item = refreshItem, showRefreshItem {
            rightItems.append(item)
        }
        navigationItem.rightBarButtonItems = rightItems
    }
    
    private func interceptCallback(for urlString: String) -> WebViewInterceptCallback? {
        var callback: WebViewInterceptCallback?
        for (key, value) in _intercepts {
            if urlString.hasPrefix(key) {
                callback = value
                break
            }
        }
        return callback
    }
    
    // MARK: -------- Actions --------
    
    @objc private func goBackAction() {
        webView.goBack()
    }
    
    @objc private func goForwardAction() {
        webView.goForward()
    }
    
    @objc private func refreshAction() {
        reload()
    }

    // MARK: ======== WKNavigationDelegate ========
    
    /// 发送请求之前，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        let requestUrl = navigationAction.request.url
        let urlString = requestUrl?.absoluteString ?? ""
        kkxPrint("decidePolicyFor:")
        kkxPrint("    ", urlString)
        if let callback = interceptCallback(for: urlString) {
            let actionPolicy = callback(self, navigationAction)
            decisionHandler(actionPolicy)
        } else {
            decisionHandler(.allow)
        }
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        let requestUrl = navigationAction.request.url
        let urlString = requestUrl?.absoluteString ?? ""
        kkxPrint("decidePolicyFor:")
        kkxPrint("    ", urlString)
        if let callback = interceptCallback(for: urlString) {
            let actionPolicy = callback(self, navigationAction)
            decisionHandler(actionPolicy, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
    }
    
    /// 收到响应之后，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        decisionHandler(.allow)
    }
    
    /// 页面开始加载
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if showActivity {
            view.kkxLoading = true
        }
    }
    
    /// 接收到服务器跳转请求
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        kkxPrint("webView didReceiveServerRedirectForProvisionalNavigation")
    }
    
    /// 页面加载失败
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        kkxPrint("webView didFailProvisionalNavigation", error)
    }
    
    /// 内容开始返回
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    
    /// 页面加载完成
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if showActivity { view.kkxLoading = false }
        
        kkxPrint("webView didFinish navigation")
        
        _finishedHandler?(webView)
        
        if _getContentHeightHandler != nil {
            var jsString = "document.body.scrollHeight"
            if #available(iOS 13.0, *) {
                jsString = "document.documentElement.scrollHeight"
            }
            webView.evaluateJavaScript(jsString) { [weak self](height, error) in
                if let h = height as? CGFloat {
                    self?._getContentHeightHandler?(webView, h)
                }
            }
        }
    }
    
    /// 页面加载失败
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        kkxPrint("webView didFail navigation")
        if showActivity { view.kkxLoading = false }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodServerTrust {
            completionHandler(.performDefaultHandling, nil)
        } else {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
    
    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        kkxPrint("webContent process did terminate")
    }
    
    public func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        decisionHandler(false)
    }
    
//    @available(iOS 14.5, *)
//    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
//        
//    }
//    
//    @available(iOS 14.5, *)
//    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
//        
//    }

    // MARK: ======== WKUIDelegate ========
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        kkxPrint("webView createWebViewWith")
        if navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        kkxPrint("webViewDidClose")
    }
    
    /// 警告框
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let action = UIAlertAction.init(title: KKXExtensionString("ok"), style: .default) { (action) in
            completionHandler()
        }
        alert(.alert, title: nil, message: message, actions: [action])
    }
    
    
    /// 确认框
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let action = UIAlertAction.init(title: KKXExtensionString("ok"), style: .default) { (action) in
            completionHandler(true)
        }
        alert(.alert, title: nil, message: message, actions: [action])
    }
    
    /// 输入框
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if customPrompt.keys.contains(prompt) {
            completionHandler(customPrompt[prompt])
        } else {
            if showTextInputPanel {
                var inputTextField: UITextField?
                let alertController = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
                let action = UIAlertAction.init(title: KKXExtensionString("ok"), style: .default) { (action) in
                    completionHandler(inputTextField?.text)
                }
                alertController.addAction(action)
                alertController.addTextField { textField in
                    inputTextField = textField
                }
                present(alertController, animated: true, completion: nil)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKContextMenuElementInfo) -> Bool {
        true
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKContextMenuElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        nil
    }
    
    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        true
    }
    
    public func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        nil
    }
    
    public func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        completionHandler(nil)
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
        
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
        
    }
    
    // MARK: - WKScriptMessageHandler
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        kkxPrint(message)
    }
}

public func fullHTMLString(_ bodyString: String) -> String {
    return """
    <head>
        \(HtmlSring.meta)
        <style>
            img {
                width:100%;
                height: auto;
            }
            @media (prefers-color-scheme: dark) {
                h, h1, h2, h3, h4, h5, h6, b, p, span {
                    color: rgba(235,235,245,0.8) !important;
                }
                body {
                    background: #1C1C1E;
                }
            }
        </style>
    </head>
    <body>
        \(bodyString)
    </body>
    """
}

public struct HtmlSring {
    public static let meta = "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>"
}
