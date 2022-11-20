//
//  KKXImagePreviewController.swift
//  KKXMobile
//
//  Created by ming on 2020/3/23.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit
import Photos

public enum KKXImageSaveState {
    case begin
    case completion(_ status: Bool, _ error: Error?)
}

public protocol KKXImagePreviewDelegate: AnyObject {
    func numberOfImagesInPreview(_ preview: KKXImagePreviewController) -> Int
    func imagePreview(_ preview: KKXImagePreviewController, imageFor imageView: UIImageView, at index: Int, completion: (@escaping (UIImage?) -> Void))
    
    func imagePreview(_ preview: KKXImagePreviewController, sourceViewAt index: Int) -> UIView?
    func imagePreview(_ preview: KKXImagePreviewController, save image: UIImage, state: KKXImageSaveState)
}

public extension KKXImagePreviewDelegate {
    func imagePreview(_ preview: KKXImagePreviewController, sourceViewAt index: Int) -> UIView? { return nil }
    func imagePreview(_ preview: KKXImagePreviewController, save image: UIImage, state: KKXImageSaveState) { }
}

public class KKXImagePreviewController: UIViewController {

    // MARK: -------- Properties --------

    public weak var delegate: KKXImagePreviewDelegate?
    public var currentIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentIndex
        }
    }
    public var placeholder: UIImage?
    public var canDelete: Bool = false
    
    public var currentController: KKXImageContentController? {
        cachedContentViewControllers[currentIndex]
    }
    
    // MARK: -------- Private Properties --------

    private lazy var pageViewController: UIPageViewController = {
        let options = [UIPageViewController.OptionsKey.interPageSpacing: 5]
        let pageVC = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: .horizontal, options: options)
        pageVC.delegate = self
        pageVC.dataSource = self
        return pageVC
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isUserInteractionEnabled = true
        pageControl.currentPage = currentIndex
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    private var cachedContentViewControllers: [Int: KKXImageContentController] = [:]
    
    private var imageCount: Int {
        delegate?.numberOfImagesInPreview(self) ?? 0
    }
    
    private var statubarHidden: Bool = true

    // MARK: -------- View Life Cycle --------
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statubarHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        statubarHidden = false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        configureNavigationBar()
    }
    
    // MARK: -------- Configuration --------
    
    private func configureNavigationBar() {
        
    }
    
    private func configureSubviews() {
        
        view.backgroundColor = .black
        
        if let contentVC = contentViewController(at: currentIndex) {
            pageViewController.setViewControllers([contentVC], direction: .reverse, animated: false, completion: nil)
            cachedContentViewControllers[currentIndex] = contentVC
        }
        pageViewController.view.frame = view.bounds
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageControl.numberOfPages = imageCount
        pageControl.currentPage = currentIndex
        view.addSubview(pageControl)
        configureConstraint()
    }

    private func configureConstraint() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [
            .centerX, .bottom,
        ]
        for attribute in attributes {
            NSLayoutConstraint(item: pageControl, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: 0).isActive = true
        }
        NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44.0).isActive = true
    }
    
    // MARK: -------- Help --------

    private func contentViewController(at index: Int) -> KKXImageContentController? {
        if imageCount == 0 || index >= imageCount {
            return nil
        }
        
        /// 获取缓存的contentViewController
        if let contentVC = cachedContentViewControllers[index] {
            return contentVC
        }
        
        let contentVC = KKXImageContentController()
        contentVC.preview = self
        contentVC.index = index
//        contentVC.didAppearClosure = { [weak self](index) in
//            self?.currentIndex = index
//        }

        cachedContentViewControllers[index] = contentVC
        
        return contentVC
    }
    
    private func contentIndex(of viewController: KKXImageContentController) -> Int {
        return viewController.index
    }
}

extension KKXImagePreviewController {
    public func dismissAction() {
        if let _ = navigationController {
            let hidden: Bool
            if #available(iOS 13.0, *) {
                hidden = kkxWindowScene?.statusBarManager?.isStatusBarHidden ?? false
            } else {
                hidden = UIApplication.shared.isStatusBarHidden
            }
            statubarHidden  = !hidden
            setNeedsStatusBarAppearanceUpdate()
            navigationController?.setNavigationBarHidden(!hidden, animated: true)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - ======== UIPageViewControllerDataSource ========
extension KKXImagePreviewController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! KKXImageContentController
        var index = contentIndex(of: controller)

        guard index > 0 else {
            return nil
        }
        index -= 1
        return contentViewController(at: index)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! KKXImageContentController
        var index = contentIndex(of: controller)

        index += 1
        guard index < imageCount else {
            return nil
        }
        return contentViewController(at: index)
    }
}

// MARK: - ======== UIPageViewControllerDelegate ========
extension KKXImagePreviewController: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let contentVC = pageViewController.viewControllers?.first as? KKXImageContentController {
            currentIndex = contentVC.index
        }
        
    }
    
    public func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    public func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - ======== UIViewControllerTransitioningDelegate ========
extension KKXImagePreviewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ImagePresentTransition()
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = KKXImageDismissTransition()
        return transition
    }
}

extension KKXImagePreviewController {
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    public override var prefersStatusBarHidden: Bool {
        return statubarHidden
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}
