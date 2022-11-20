//
//  KKXImageTransition.swift
//  KKXMobile
//
//  Created by ming on 2020/3/23.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

public class KKXImageTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.25
    }
    
}

/// 自定义Present动画
public class ImagePresentTransition: KKXImageTransition {
    
    public override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // 获取目标viewController
        guard let toViewController = transitionContext.viewController(forKey: .to) as? KKXImagePreviewController,
            let toView = transitionContext.view(forKey: .to) else {
            return
        }
        
        // 获取容器view
        let containerView = transitionContext.containerView
        containerView.backgroundColor = .black
        containerView.addSubview(toView)
        
        // 获取点击view
        guard let tapView = toViewController.delegate?.imagePreview(toViewController, sourceViewAt: toViewController.currentIndex) else {
            transitionContext.completeTransition(true)
            return
        }
        
        toView.isHidden = true

        // 获取动画开始位置
        let startFrame = tapView.superview!.convert(tapView.frame, to: containerView)
        // 获取动画结束位置
        var endSize = startFrame.size.fitSize(in: containerView.frame.size)
        
        var animateImage: UIImage?
        if let imageView = tapView as? UIImageView {
            animateImage = imageView.image
        } else if let button = tapView as? UIButton {
            animateImage = button.currentImage
        }
        if let size = animateImage?.size, size != .zero {
            endSize = size.fitSize(in: containerView.frame.size)
        }
        
        // 创建动画view，动画结束后移除
        let animationImageView = UIImageView()
        animationImageView.contentMode = .scaleAspectFill
        animationImageView.clipsToBounds = true
        containerView.addSubview(animationImageView)
        
        animationImageView.image = animateImage
        animationImageView.frame = startFrame
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            animationImageView.frame.size = endSize
            animationImageView.center = CGPoint(x: containerView.frame.width/2, y: containerView.frame.height/2)
        }) { (finished) in
            toView.isHidden = false
            animationImageView.removeFromSuperview()
            
            let wasCancelled = transitionContext.transitionWasCancelled
            if wasCancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!wasCancelled)
        }
    }
}

/// 自定义dismiss动画
class KKXImageDismissTransition: KKXImageTransition {
    
    public override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        // 获取目标viewController
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? KKXImagePreviewController,
            let startView = fromViewController.currentController?.scrollView.imageView,
            let endView = fromViewController.delegate?.imagePreview(fromViewController, sourceViewAt: fromViewController.currentIndex) else {
            transitionContext.completeTransition(true)
            return
        }
           
        // 把点击视图的位置转换到containerView中
        let endFrame = endView.superview!.convert(endView.frame, to: containerView)
        var startSize = endFrame.size.fitSize(in: containerView.frame.size)
        
        let animateImage = startView.image
        if let size = animateImage?.size, size != .zero {
            startSize = size.fitSize(in: containerView.frame.size)
        }
        
        // 创建动画view，动画结束后移除
        let animationImageView = UIImageView()
        animationImageView.contentMode = .scaleAspectFill
        animationImageView.clipsToBounds = true
        containerView.addSubview(animationImageView)
        
        animationImageView.image = animateImage
        animationImageView.frame.size = startSize
        animationImageView.center = CGPoint(x: containerView.frame.width/2, y: containerView.frame.height/2)
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            animationImageView.frame = endFrame
        }) { (finished) in
            animationImageView.removeFromSuperview()
            let wasCancelled = transitionContext.transitionWasCancelled
            if wasCancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!wasCancelled)
        }
    }
    
}

