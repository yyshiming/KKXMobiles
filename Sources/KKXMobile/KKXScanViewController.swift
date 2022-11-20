//
//  KKXScanViewController.swift
//  KKXMobile
//
//  Created by ming on 2020/10/23.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit
import AVFoundation

public enum KKXScanButtonItem {
    case flash
    case photo
}
open class KKXScanViewController: KKXViewController {

    // MARK: -------- Properties --------
    
    public var showPhotoButton = true {
        didSet {
            reloadBottomView()
        }
    }
    
    // 识别码的类型
    public var arrayCodeType: [AVMetadataObject.ObjectType] = [.qr, .ean13, .code128]
    
    public var scanWrapper: KKXScanWrapper?

    public var scanView: KKXScanView!
    
    public var scanStyle = KKXScanView.Style()
    
    public var handleResult: ((String?) -> Void)?
    
    public var stopOnCapturePhoto: Bool = false
    
    // MARK: -------- Private Properties --------
    
    private var isFlashOpen: Bool = false
    
    private let buttonSize = CGSize(width: 65, height: 65)
    
    /// 记录开始的缩放比例
    private var beginGestureScale: CGFloat = 1.0
    /// 最后的缩放比例
    private var effectiveScale: CGFloat = 1.0
    
    private lazy var bottomToolView: UIView = {
        let toolView = UIView()
        return toolView
    }()
    
    private lazy var flashButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(flashAction), for: .touchUpInside)
        button.setImage(Image(named: "scan.flash.off"), for: .normal)
        button.setImage(Image(named: "scan.flash.on"), for: .selected)
        return button
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
        button.setImage(Image(named: "scan.photo"), for: .normal)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage.itemImage(with: UIImage.ItemConfiguration(direction: .left, lineWidth: 2.0, tintColor: .white, width: 12))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: -------- View Life Cycle --------
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        configureNavigationBar()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScan()
    }
    
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScan()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scanView.frame = view.bounds
        
        let maxWidth = view.frame.width
        let maxHeight = view.frame.height
        
        let toolViewH: CGFloat = 100
        let toolViewY = maxHeight - toolViewH - view.kkxSafeAreaInsets.bottom - 20
        bottomToolView.frame = CGRect(x: 0, y: toolViewY, width: maxWidth, height: toolViewH)
        
        reloadBottomView()
    }
    
    private func reloadBottomView() {
        photoButton.isHidden = !showPhotoButton
        if showPhotoButton {
            let buttonMargin: CGFloat = 40
            let flashX = buttonMargin
            let buttonY = (bottomToolView.frame.height - buttonSize.height)/2
            flashButton.frame = CGRect(x: flashX, y: buttonY, width: buttonSize.width, height: buttonSize.height)
            
            let photoX = bottomToolView.frame.width - buttonSize.width - buttonMargin
            photoButton.frame = CGRect(x: photoX, y: buttonY, width: buttonSize.width, height: buttonSize.height)
        } else {
            let flashX = (bottomToolView.frame.width - buttonSize.width)/2
            let buttonY = (bottomToolView.frame.height - buttonSize.height)/2
            flashButton.frame = CGRect(x: flashX, y: buttonY, width: buttonSize.width, height: buttonSize.height)
        }
    }
    
    // MARK: -------- Configuration --------
    
    open func didHandleResult(_ string: String?) {
        
    }
    
    private func configureNavigationBar() {
        kkxBackItem = backButton
    }
    
    private func configureSubviews() {
        isNavigationBarHidden = true
        view.backgroundColor = UIColor.black

        scanStyle.photoframeAngleStyle = .inner
        scanStyle.animationImage = Image(named: "scan.line")
        
        scanWrapper = KKXScanWrapper(
            preview: view,
            objectType: arrayCodeType,
            successHandler: { [weak self](result) in
                guard let self = self else { return }
                if self.stopOnCapturePhoto {
                    self.scanWrapper?.stopRunning()
                }
                let string = result.first?.string
                self.handleResult?(string)
                self.didHandleResult(string)
            }
        )
        scanStyle.colorRetangleLine = UIColor.clear
        scanView = KKXScanView(frame: .zero, vstyle: scanStyle)
        view.addSubview(scanView)
        view.addSubview(bottomToolView)
        
        bottomToolView.addSubview(flashButton)
        bottomToolView.addSubview(photoButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        view.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
//        tapGesture.shouldRequireFailure(of: pinchGesture)
    }
    
    public func startScan() {
        scanWrapper?.startRunning()
        scanView.startScanAnimation()
    }
    
    public func stopScan() {
        scanView.stopScanAnimation()
        scanWrapper?.stopRunning()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: -------- Actions --------

    private func hideFlashButton(_ animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.flashButton.alpha = 0
            }
        } else {
            self.flashButton.alpha = 0
        }
    }
    
    private func showFlashButton(_ animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.flashButton.alpha = 1
            }
        } else {
            self.flashButton.alpha = 1
        }
    }
    
    @objc private func choosePhoto() {
        selectPhoto(from: .photoLibrary) { [weak self](info) in
            guard let self = self else { return }
            
            let image = info[.originalImage] as? UIImage
            let result = KKXScanWrapper.recognizeQRImage(image)
            
            let string = result.first?.string
            self.handleResult?(string)
            self.didHandleResult(string)
        }
    }
    
    @objc private func flashAction() {
        if scanWrapper?.isTorchOn == true {
            scanWrapper?.isTorchOn = false
            flashButton.isSelected = false
            isFlashOpen = false
        } else {
            scanWrapper?.isTorchOn = true
            flashButton.isSelected = true
            isFlashOpen = true
        }
    }
    
    @objc private func tapAction(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let focusPoint = CGPoint(x: location.x/view.frame.width, y: location.y/view.frame.height)
        scanWrapper?.focusOn(focusPoint)
    }
    
    @objc private func pinchAction(_ gesture: UIPinchGestureRecognizer) {
        var allTouchesAreOntheView: Bool = true
        let number = gesture.numberOfTouches
        for i in 0..<number {
            let location = gesture.location(ofTouch: i, in: view)
            if let convertedLocation = scanWrapper?.previewLayer?.convert(location, from: view.layer) {
                if !view.layer.contains(convertedLocation) {
                    allTouchesAreOntheView = false
                    break
                }
            } else {
                allTouchesAreOntheView = false
                break
            }
            
        }
        
        if allTouchesAreOntheView {
            effectiveScale = beginGestureScale * gesture.scale
            if effectiveScale < 1.0 {
                effectiveScale = 1.0
            }
            
            let maxScaleAndCropFactor = scanWrapper?.maxScaleAndCropFactor ?? 0
            if effectiveScale > maxScaleAndCropFactor {
                effectiveScale = maxScaleAndCropFactor
            }
            
            self.scanWrapper?.previewLayer?.setAffineTransform(CGAffineTransform(scaleX: self.effectiveScale, y: self.effectiveScale))
        }
    }
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension KKXScanViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer {
            beginGestureScale = effectiveScale
        }
        return true
    }
}
