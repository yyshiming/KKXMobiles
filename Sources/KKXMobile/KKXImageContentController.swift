//
//  KKXImageContentController.swift
//  KKXMobile
//
//  Created by ming on 2020/3/23.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit
import Photos

public class KKXImageContentController: UIViewController {

    // MARK: -------- Properties --------
    
    public var index: Int = 0
    public weak var preview: KKXImagePreviewController?

    public var willAppearClosure: ((Int) -> Void)?
    public var didAppearClosure: ((Int) -> Void)?
    
    // MARK: -------- Private Properties --------
    
    public let scrollView = KKXImageScrollView()
    
    // MARK: -------- View Life Cycle --------
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppearClosure?(index)
        scrollView.zoomScale = 1.0
        
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppearClosure?(index)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        configureNavigationBar()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
    
    // MARK: -------- Configuration --------
    
    private func configureNavigationBar() {
        
    }
    
    private func configureSubviews() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.5
        
        view.addSubview(scrollView)
        scrollView.imageView.kkxLoadingView.color = .white
        
        let singleGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        view.addGestureRecognizer(singleGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        singleGesture.require(toFail: doubleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapAction(_:)))
        view.addGestureRecognizer(longPressGesture)
        
        guard let preview = preview else { return }
        
        preview.delegate?.imagePreview(preview, imageFor: scrollView.imageView, at: index, completion: { [weak self](image) in
            self?.scrollView.imageView.image = image
            self?.scrollView.updateContentFrame()
        })
    }
    
    // MARK: -------- Actions --------

    @objc private func singleTapAction() {
        preview?.dismissAction()
    }
    
    @objc private func doubleTapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if scrollView.zoomScale < scrollView.maximumZoomScale {
                scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
            }
            else {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
        }
    }
    
    @objc private func longTapAction(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if let image = scrollView.imageView.image {
                kkxSourceView = view
                kkxSourceRect = scrollView.convert(scrollView.imageView.frame, to: kkxSourceView)
                let saveAction = UIAlertAction(title: KKXExtensionString("save.to.album"), style: .default) { [weak self](action) in
                    self?.savePhoto(image)
                }
                let cancelAction = UIAlertAction(title: KKXExtensionString("cancel"), style: .cancel) { (action) in
                    
                }
                alert(.actionSheet, actions: [saveAction, cancelAction])
            }
        default:
            break
        }
    }
    
    
    // MARK: -------- Helps --------

    private func savePhoto(_ image: UIImage) {
        guard let preview = preview else { return }
            
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                DispatchQueue.kkx_safe {
                    preview.delegate?.imagePreview(preview, save: image, state: .begin)
                }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { (success, error) in
                    DispatchQueue.kkx_safe {
                        preview.delegate?.imagePreview(preview, save: image, state: .completion(success, error))
                    }
                }
            default:
                DispatchQueue.kkx_safe {
                    preview.delegate?.imagePreview(preview, save: image, state: .completion(false, nil))
                }
                break
            }
        }
    }
}

extension KKXImageContentController {
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        scrollView.setNeedsUpdateContentFrame()
    }
}

extension KKXImageContentController {
    
    public override var shouldAutorotate: Bool {
        true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .allButUpsideDown
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    public override var prefersStatusBarHidden: Bool {
        true
    }
}
