//
//  KKXScanWrapper.swift
//  KKXMobile
//
//  Created by ming on 2020/7/29.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit
import AVFoundation

public struct KKXScanResult {
    
    /// 码内容
    public var string: String?
    
    /// 扫描图像
    public var image: UIImage?
    
    /// 码类型
    public var codeType: String?
    
    /// 码在图像中的位置
    public var corners: [CGPoint]?
}

public class KKXScanWrapper: NSObject {

    public var hasFlash: Bool {
        device != nil && device!.hasFlash && device!.hasTorch
    }
    
    /// 打开或关闭闪光灯
    public var isTorchOn = false {
        didSet {
            torchMode = isTorchOn ? .on:.off
        }
    }
    
    public var results: [KKXScanResult] = []
    
    public var isNeedCaptureImage: Bool = false

    public var successHandler: (([KKXScanResult]) -> Void)?
    
    public var exifBrightnessChangedHandler: ((Double) -> Void)?

    private(set) var isRunning = false
    
    public var maxScaleAndCropFactor: CGFloat {
        photoOutput.connection(with: .video)?.videoMaxScaleAndCropFactor ?? 0
    }
    
    private var torchMode: AVCaptureDevice.TorchMode = .off {
        didSet {
            guard hasFlash else { return }
            do {
                try input?.device.lockForConfiguration()
                input?.device.torchMode = torchMode
                input?.device.unlockForConfiguration()
            } catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
        }
    }
    
    let device = AVCaptureDevice.default(for: AVMediaType.video)
    
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput
    
    let session = AVCaptureSession()
    public var previewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput
    
    /// 初始化
    /// - Parameters:
    ///   - preview: 显示的view
    ///   - objectType: 识别码类型，默认QR
    ///   - cropRect: 识别区域
    ///   - successHandler: 返回识别结果
    public init(preview: UIView,
                objectType: [AVMetadataObject.ObjectType] = [.qr],
                cropRect: CGRect = .zero,
                successHandler: (([KKXScanResult]) -> Void)? = nil) {
        
        self.successHandler = successHandler
        output = AVCaptureMetadataOutput()
        photoOutput = AVCapturePhotoOutput()
        
        super.init()
        
        guard let device = device else { return }
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print("AVCaptureDeviceInput(): \(error)")
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        guard let input = input else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.sessionPreset = AVCaptureSession.Preset.high
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = objectType
        
        if !cropRect.equalTo(.zero) {
            output.rectOfInterest = cropRect
        }
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = preview.bounds
        preview.layer.insertSublayer(layer, at: 0)
        previewLayer = layer
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
            do {
                try input.device.lockForConfiguration()
                input.device.focusMode = .continuousAutoFocus
                input.device.unlockForConfiguration()
            } catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
        }
    }
    
    let backgroundQueue = DispatchQueue(label: "background_queue",
                                            qos: .background)
    public func startRunning() {
        if !session.isRunning {
            backgroundQueue.async {
                self.isRunning = true
                self.session.startRunning()
            }
        }
    }
    
    public func stopRunning() {
        if session.isRunning {
            backgroundQueue.async {
                self.isRunning = false
                self.session.stopRunning()
            }
        }
    }
    
    open func captureOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard isRunning else {
            // 上一帧处理中
            return
        }
        isRunning = false
        
        results.removeAll()
        
        // 识别扫码类型
        for current in metadataObjects {
            guard let code = current as? AVMetadataMachineReadableCodeObject else {
                continue
            }
            let result = KKXScanResult(
                string: code.stringValue,
                image: nil, codeType:
                code.type.rawValue,
                corners: nil
            )
            results.append(result)
        }
        
        if results.isEmpty {
            isRunning = true
        } else {
            if isNeedCaptureImage {
                captureImage()
            } else {
                stopRunning()
                successHandler?(results)
            }
        }
    }
    
    // 拍照
    open func captureImage() {
        var format: [String: Any]!
        if #available(iOS 11.0, *) {
            format = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        } else {
            format = [AVVideoCodecKey: AVVideoCodecJPEG]
        }
        let photoSettings = AVCapturePhotoSettings(format: format)
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    open func connection(with mediaType: AVMediaType, connections: [AnyObject]) -> AVCaptureConnection? {
        for connection in connections {
            guard let connectionTmp = connection as? AVCaptureConnection else {
                continue
            }
            for port in connectionTmp.inputPorts where port.mediaType == mediaType {
                return connectionTmp
            }
        }
        return nil
    }
    
    public func focusOn(_ point: CGPoint) {
        guard let device = self.device else { return }
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.autoFocus) {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            if device.isExposureModeSupported(.autoExpose) {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
        } catch let error as NSError {
            print("device.lockForConfiguration(): \(error)")
        }
    }
    
    //待测试
    open func changeScanRect(_ rect: CGRect) {
        stopRunning()
        output.rectOfInterest = rect
        startRunning()
    }
    //待测试
    open func changeScanType(_ objectTypes: [AVMetadataObject.ObjectType]) {
        output.metadataObjectTypes = objectTypes
    }
    
    
    /// 识别二维码图像
    /// - Parameter image: 二维码图像
    /// - Returns: 返回识别结果
    public static func recognizeQRImage(_ image: UIImage?) -> [KKXScanResult] {
        guard let cgImage = image?.cgImage else { return [] }
        
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )!
        let ciImage = CIImage(cgImage: cgImage)
        let features = detector.features(
            in: ciImage,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        return features.filter {
            $0.isKind(of: CIQRCodeFeature.self)
        }.map {
            $0 as! CIQRCodeFeature
        }.map {
            KKXScanResult(
                string: $0.messageString,
                image: image,
                codeType: AVMetadataObject.ObjectType.qr.rawValue,
                corners: nil
            )
        }
    }
    
    /// 创建二位码
    public static func createCode(with codeType: String,
                           codeString: String,
                           size: CGSize,
                           qrColor: UIColor,
                           bkColor: UIColor) -> UIImage? {
        
        let stringData = codeString.data(using: .utf8)

        // 系统自带能生成的码
        //        CIAztecCodeGenerator
        //        CICode128BarcodeGenerator
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator
        let qrFilter = CIFilter(name: codeType)
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")

        // 上色
        let colorFilter = CIFilter(name: "CIFalseColor",
                                   parameters: [
                                       "inputImage": qrFilter!.outputImage!,
                                       "inputColor0": CIColor(cgColor: qrColor.cgColor),
                                       "inputColor1": CIColor(cgColor: bkColor.cgColor),
                                   ]
        )

        guard let qrImage = colorFilter?.outputImage,
        let cgImage = CIContext().createCGImage(qrImage, from: qrImage.extent) else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = CGInterpolationQuality.none
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return codeImage
    }
    
    /// 创建条形码
    public static func createCode128(codeString: String,
                              size: CGSize,
                              qrColor: UIColor,
                              bkColor: UIColor) -> UIImage? {
        let stringData = codeString.data(using: String.Encoding.utf8)

        // 系统自带能生成的码
        //        CIAztecCodeGenerator 二维码
        //        CICode128BarcodeGenerator 条形码
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator     二维码
        let qrFilter = CIFilter(name: "CICode128BarcodeGenerator")
        qrFilter?.setDefaults()
        qrFilter?.setValue(stringData, forKey: "inputMessage")

        guard let outputImage = qrFilter?.outputImage else {
            return nil
        }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: UIImage.Orientation.up)

        // Resize without interpolating
        return resizeImage(image: image, quality: CGInterpolationQuality.none, rate: 20.0)
    }
    
    // 根据扫描结果，获取图像中得二维码区域图像（如果相机拍摄角度故意很倾斜，获取的图像效果很差）
    static func getConcreteCodeImage(srcCodeImage: UIImage, codeResult: KKXScanResult) -> UIImage? {
        let rect = getConcreteCodeRectFromImage(srcCodeImage: srcCodeImage, codeResult: codeResult)
        guard !rect.isEmpty, let img = imageByCroppingWithStyle(srcImg: srcCodeImage, rect: rect) else {
            return nil
        }
        return imageRotation(image: img, orientation: UIImage.Orientation.right)
    }
    
    // 根据二维码的区域截取二维码区域图像
    public static func getConcreteCodeImage(srcCodeImage: UIImage, rect: CGRect) -> UIImage? {
        guard !rect.isEmpty, let img = imageByCroppingWithStyle(srcImg: srcCodeImage, rect: rect) else {
            return nil
        }
        return imageRotation(image: img, orientation: UIImage.Orientation.right)
    }
    
    // 获取二维码的图像区域
    public static func getConcreteCodeRectFromImage(srcCodeImage: UIImage, codeResult: KKXScanResult) -> CGRect {
        guard let corner = codeResult.corners, corner.count >= 4 else {
            return .zero
        }

        let dicTopLeft = corner[0]
        let dicTopRight = corner[1]
        let dicBottomRight = corner[2]
        let dicBottomLeft = corner[3]

        let xLeftTopRatio = dicTopLeft.x
        let yLeftTopRatio = dicTopLeft.y
        
        let xRightTopRatio = dicTopRight.x
        let yRightTopRatio = dicTopRight.y

        let xBottomRightRatio = dicBottomRight.x
        let yBottomRightRatio = dicBottomRight.y

        let xLeftBottomRatio = dicBottomLeft.x
        let yLeftBottomRatio = dicBottomLeft.y

        // 由于截图只能矩形，所以截图不规则四边形的最大外围
        let xMinLeft = CGFloat(min(xLeftTopRatio, xLeftBottomRatio))
        let xMaxRight = CGFloat(max(xRightTopRatio, xBottomRightRatio))

        let yMinTop = CGFloat(min(yLeftTopRatio, yRightTopRatio))
        let yMaxBottom = CGFloat(max(yLeftBottomRatio, yBottomRightRatio))

        let imgW = srcCodeImage.size.width
        let imgH = srcCodeImage.size.height
        
        // 宽高反过来计算
        return CGRect(x: xMinLeft * imgH,
                      y: yMinTop * imgW,
                      width: (xMaxRight - xMinLeft) * imgH,
                      height: (yMaxBottom - yMinTop) * imgW)
    }
    
    //MARK: ----图像处理
    
    /**

    @brief  图像中间加logo图片
    @param srcImg    原图像
    @param LogoImage logo图像
    @param logoSize  logo图像尺寸
    @return 加Logo的图像
    */
    public static func addImageLogo(srcImg: UIImage, logoImg: UIImage, logoSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(srcImg.size, false, 0)
        srcImg.draw(in: CGRect(x: 0, y: 0, width: srcImg.size.width, height: srcImg.size.height))
        let rect = CGRect(x: srcImg.size.width / 2 - logoSize.width / 2,
                          y: srcImg.size.height / 2 - logoSize.height / 2,
                          width: logoSize.width,
                          height: logoSize.height)
        logoImg.draw(in: rect)
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultingImage!
    }
    
    //图像缩放
    static func resizeImage(image: UIImage, quality: CGInterpolationQuality, rate: CGFloat) -> UIImage? {
        var resized: UIImage?
        let width = image.size.width * rate
        let height = image.size.height * rate

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = quality
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))

        resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized
    }

    // 图像裁剪
    static func imageByCroppingWithStyle(srcImg: UIImage, rect: CGRect) -> UIImage? {
        guard let imagePartRef = srcImg.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: imagePartRef)
    }
    
    // 图像旋转
    static func imageRotation(image: UIImage, orientation: UIImage.Orientation) -> UIImage {
        var rotate: Double = 0.0
        var rect: CGRect
        var translateX: CGFloat = 0.0
        var translateY: CGFloat = 0.0
        var scaleX: CGFloat = 1.0
        var scaleY: CGFloat = 1.0

        switch orientation {
        case .left:
            rotate = .pi / 2
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = 0
            translateY = -rect.size.width
            scaleY = rect.size.width / rect.size.height
            scaleX = rect.size.height / rect.size.width
        case .right:
            rotate = 3 * .pi / 2
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = -rect.size.height
            translateY = 0
            scaleY = rect.size.width / rect.size.height
            scaleX = rect.size.height / rect.size.width
        case .down:
            rotate = .pi
            rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            translateX = -rect.size.width
            translateY = -rect.size.height
        default:
            rotate = 0.0
            rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            translateX = 0
            translateY = 0
        }

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        // 做CTM变换
        context.translateBy(x: 0.0, y: rect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat(rotate))
        context.translateBy(x: translateX, y: translateY)

        context.scaleBy(x: scaleX, y: scaleY)
        // 绘制图片
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension KKXScanWrapper: AVCapturePhotoCaptureDelegate {
    /*
    /// iOS10.0 ~ iOS11.0
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let jpegBuffer = photoSampleBuffer,
            let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: jpegBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
            let image = UIImage(data: data)
            for i in 0..<results.count {
                results[i].image = image
            }
        }
        successHandler?(results)
    }
    */
    @available(iOS 11.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation() {
            let image = UIImage(data: data)
            for i in 0..<results.count {
                results[i].image = image
            }
        }
        successHandler?(results)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension KKXScanWrapper: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureOutput(output, didOutput: metadataObjects, from: connection)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension KKXScanWrapper: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDict = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let metadata = metadataDict as? [AnyHashable: Any]
        let exifDict = metadata?[kCGImagePropertyExifDictionary] as? [AnyHashable: Any]
        if let brightness = exifDict?[kCGImagePropertyExifBrightnessValue] as? Double {
            exifBrightnessChangedHandler?(brightness)
        }
    }
}

public extension AVMetadataObject.ObjectType {
    
    /// 获取系统默认支持的码类型
    static var supportTypes: [AVMetadataObject.ObjectType] {
        let types = [
            AVMetadataObject.ObjectType.qr,
            AVMetadataObject.ObjectType.upce,
            AVMetadataObject.ObjectType.code39,
            AVMetadataObject.ObjectType.code39Mod43,
            AVMetadataObject.ObjectType.ean13,
            AVMetadataObject.ObjectType.ean8,
            AVMetadataObject.ObjectType.code93,
            AVMetadataObject.ObjectType.code128,
            AVMetadataObject.ObjectType.pdf417,
            AVMetadataObject.ObjectType.aztec,
            AVMetadataObject.ObjectType.interleaved2of5,
            AVMetadataObject.ObjectType.itf14,
            AVMetadataObject.ObjectType.dataMatrix
        ]
        return types
    }
}
