//
//  PLMScrollMenuAnimator.swift
//  PLMScrollMenu
//
//  Created by Tatsuhiro Kanai on 2016/03/16.
//  Copyright © 2016年 Adways Inc. All rights reserved.
//

import UIKit

internal class PLMScrollMenuAnimator: NSObject , UIViewControllerAnimatedTransitioning
{
    
    private var _transitionContext : PLMScrollMenuTransitionContext!
    
    // This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
    // synchronize with the main animation.
    internal func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return 0.2
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    internal func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        //print("start animateTransition")
        let tc:PLMScrollMenuTransitionContext = transitionContext as! PLMScrollMenuTransitionContext
        
        let toViewController :UIViewController = tc.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController :UIViewController = tc.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        transitionContext.containerView()?.addSubview(toViewController.view)
        transitionContext.containerView()?.insertSubview( toViewController.view, belowSubview: fromViewController.view)
        
        _transitionContext = tc;
        
        let fromInitialFrame = tc.initialFrameForViewController(fromViewController)
        let fromFinalFrame = tc.finalFrameForViewController(fromViewController)
        let toInitialFrame = tc.initialFrameForViewController(toViewController)
        let toFinalFrame = tc.finalFrameForViewController(toViewController)
        
        fromViewController.view.frame = fromInitialFrame;
        toViewController.view.frame = toInitialFrame;
        //fromViewController.view.alpha = 1.0;
        //toViewController.view.alpha = 1.0;
        
        CATransaction.begin()
        
        var point : CGPoint
        
        // Animation of fromView
        let fromViewAnimation : CABasicAnimation = CABasicAnimation(keyPath: "position")
        
        // fromValue
        point = fromInitialFrame.origin;
        point.x += fromInitialFrame.size.width*0.5;
        point.y += fromInitialFrame.size.height*0.5;
        
        fromViewAnimation.fromValue = NSValue(CGPoint: point)
        
        // toValue
        point = fromFinalFrame.origin;
        point.x += fromFinalFrame.size.width*0.5;
        point.y += fromFinalFrame.size.height*0.5;
        
        fromViewAnimation.toValue = NSValue(CGPoint: point)
        fromViewAnimation.duration = self.transitionDuration(transitionContext)
        fromViewAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        // Maintain final animation state.
        fromViewAnimation.removedOnCompletion = false
        fromViewAnimation.fillMode = kCAFillModeForwards
        fromViewController.view.layer.addAnimation(fromViewAnimation,forKey:"from_transition")
        
        // Animation of toView
        let toViewAnimation : CABasicAnimation = CABasicAnimation(keyPath: "position")
        
        //
        point = toInitialFrame.origin
        point.x += toInitialFrame.size.width*0.5
        point.y += toInitialFrame.size.height*0.5
        toViewAnimation.fromValue = NSValue(CGPoint: point)
        
        point = toFinalFrame.origin
        point.x += toFinalFrame.size.width*0.5
        point.y += toFinalFrame.size.height*0.5
        
        toViewAnimation.toValue = NSValue(CGPoint: point)
        toViewAnimation.duration =  self.transitionDuration(transitionContext)
        
        toViewAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        // Maintain final animation state.
        toViewAnimation.removedOnCompletion = false
        toViewAnimation.fillMode = kCAFillModeForwards
        toViewAnimation.delegate = self
        
        toViewController.view.layer.addAnimation(toViewAnimation, forKey: "to_transition")
        
        CATransaction.commit()
        
    }
    
    internal override func animationDidStart(animation:CAAnimation){
    
    }
    
    internal override func animationDidStop( animation : CAAnimation , finished : Bool )
    {
        let toViewController = _transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = _transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        if _transitionContext.transitionWasCancelled()
        {
            fromViewController!.view.frame = _transitionContext.initialFrameForViewController(fromViewController!)
            toViewController!.view.frame = _transitionContext.initialFrameForViewController(toViewController!)
        }else{
            fromViewController!.view.frame = _transitionContext.finalFrameForViewController(fromViewController!)
            toViewController!.view.frame = _transitionContext.finalFrameForViewController(toViewController!)
        }
        _transitionContext.completeTransition(!_transitionContext.transitionWasCancelled())
        
        // Remove animations
        fromViewController!.view.layer.removeAllAnimations()
        toViewController!.view.layer.removeAllAnimations()
        
    }
    
}
