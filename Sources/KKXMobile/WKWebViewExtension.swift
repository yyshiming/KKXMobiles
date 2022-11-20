//
//  WKWebViewExtension.swift
//  Demo
//
//  Created by ming on 2021/8/26.
//

import UIKit
import WebKit

extension WKWebView {

    /// 创建长图片
    /// - Parameters:
    ///   - completionHandler: 创建完成回调
    public func takeSnapshot(completionHandler: @escaping (UIImage?) -> Void) {
        self.createPDFData { result in
            switch result {
            case .success(let data):
                if let provider = CGDataProvider(data: data as CFData),
                      let pdfPage = CGPDFDocument(provider)?.page(at: 1) {
                    let image = UIImage.image(for: pdfPage)
                    completionHandler(image)
                } else {
                    kkxPrint("Create pdf page failure")
                    completionHandler(nil)
                }
            case .failure(let error):
                kkxPrint("Create pdf data failure", error)
                completionHandler(nil)
            }
        }
    }
    
    /// 创建pdfData
    /// - Parameters:
    ///   - completionHandler: 创建完成回调
    public func createPDFData(completionHandler: @escaping (Result<Data, Error>) -> Void) {
        if #available(iOS 14.0, *) {
            self.createPDF(completionHandler: completionHandler)
        } else {
            scrollView.setContentOffset(.zero, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let contentSize = self.scrollView.contentSize
                let printPageRenderer = PrintPageRenderer(contentSize: contentSize)
                printPageRenderer.addPrintFormatter(self.viewPrintFormatter(), startingAtPageAt: 0)
                let data = printPageRenderer.pdfData()
                if data.count > 0 {
                    completionHandler(.success(data as Data))
                } else {
                    completionHandler(.failure(CreatePDFDataError()))
                }
            }
        }
    }
    
    public struct CreatePDFDataError: Error {
        public let domain = "KKXCreatePDFDataErrorDomain"
        public let userInfo = [NSLocalizedDescriptionKey: "Create pdf data failure"]
    }
}

fileprivate class PrintPageRenderer: UIPrintPageRenderer {
    
    public let contentSize: CGSize
        
    public init(contentSize: CGSize) {
        self.contentSize = contentSize
    }
    
    public override var paperRect: CGRect {
        CGRect(origin: .zero, size: contentSize)
    }
    
    public override var printableRect: CGRect {
        CGRect(origin: .zero, size: contentSize)
    }
    
    public func pdfData() -> NSData {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, paperRect, nil)
        prepare(forDrawingPages: NSMakeRange(0, numberOfPages))
        
        let rect = UIGraphicsGetPDFContextBounds()
        for i in 0..<numberOfPages {
            UIGraphicsBeginPDFPage()
            drawPage(at: i, in: rect)
        }
        UIGraphicsEndPDFContext()
        return data
    }
}
