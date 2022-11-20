//
//  KKXImageScrollView.swift
//  KKXMobile
//
//  Created by ming on 2020/3/23.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

public class KKXImageScrollView: UIScrollView {

    // MARK: -------- Properties --------
    
    public let imageView = UIImageView()
    
    private var needsUpdateContent: Bool = true
    
    // MARK: -------- Init --------
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    // MARK: -------- Configure --------
    
    private func configureSubviews() {
        delegate = self
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        addSubview(imageView)
    }
    
    // MARK: -------- Actions --------
    
    public func setNeedsUpdateContentFrame() {
        needsUpdateContent = true
    }
    
    public func updateContentFrame() {
        
        let defaultW = min(frame.width, frame.height)
        let defaultH = defaultW
        var imageFitSize = CGSize(width: defaultW, height: defaultH)
        if let imageSize = imageView.image?.size {
            imageFitSize = imageSize.fitSize(in: bounds.size)
        }

        imageView.frame.size = imageFitSize
        contentSize = imageFitSize
        
        let scrollViewSize = bounds.size
        let verticalPadding = imageFitSize.height < scrollViewSize.height ? (scrollViewSize.height - imageFitSize.height)/2:0
        let horizontalPadding = imageFitSize.width < scrollViewSize.width ? (scrollViewSize.width - imageFitSize.width)/2:0
        
        contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        
    }
    
    private func updateZoomContentInset() {
        contentSize = imageView.frame.size
        
        let contentSize = self.contentSize;
        let scrollViewSize = self.bounds.size;
        
        let verticalPadding = contentSize.height < scrollViewSize.height ? (scrollViewSize.height - contentSize.height) / 2 : 0;
        let horizontalPadding = contentSize.width < scrollViewSize.width ? (scrollViewSize.width - contentSize.width) / 2 : 0;
        contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    // MARK: -------- Layout --------
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if needsUpdateContent {
            updateContentFrame()
            needsUpdateContent = false
        }
    }
}

// MARK: - ======== UIScrollViewDelegate ========
extension KKXImageScrollView: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateZoomContentInset()
    }
}

extension CGSize {
    /// size范围内等比缩放
    public func fitSize(in size: CGSize) -> CGSize {
        guard height > 0, size.height > 0 else {
            return .zero
        }
        
        let scale1 = width/height
        let scale2 = size.width/size.height
        
        var newWidth = size.width
        var newHeight = size.height
        if scale1 > scale2 {
            newHeight = newWidth/scale1
        } else {
            newWidth = newHeight*scale1
        }
        return CGSize(width: newWidth, height: newHeight)
    }
}
