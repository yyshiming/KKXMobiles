//
//  KKXScanLineAnimation.swift
//  KKXMobile
//
//  Created by ming on 2020/7/30.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

class KKXScanLineAnimation: UIImageView {

    var isAnimationing = false
    var animationRect = CGRect.zero
    
    func startAnimatingWithRect(animationRect: CGRect, parentView: UIView, image: UIImage?) {
        self.image = image
        self.animationRect = animationRect
        parentView.addSubview(self)
        
        isHidden = false
        isAnimationing = true
        if image != nil {
            stepAnimation()
        }
    }
    
    @objc func stepAnimation() {
        guard isAnimationing else {
            return
        }
        var frame = animationRect
        let hImg = image!.size.height * animationRect.size.width / image!.size.width

        frame.origin.y -= hImg
        frame.size.height = hImg
        self.frame = frame
        alpha = 0.0

        UIView.animate(withDuration: 1.4, animations: {
            self.alpha = 1.0
            var frame = self.animationRect
            let hImg = self.image!.size.height * self.animationRect.width / self.image!.size.width
            frame.origin.y += (frame.height - hImg)
            frame.size.height = hImg
            self.frame = frame
        }, completion: { _ in
            self.perform(#selector(KKXScanLineAnimation.stepAnimation), with: nil, afterDelay: 0.3)
        })
    }
    
    func stopStepAnimating() {
        isHidden = true
        isAnimationing = false
    }
    
    deinit {
        stopStepAnimating()
    }
}
