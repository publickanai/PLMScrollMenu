//
//  PLMScrollMenuAnimator.swift
//  PLMScrollMenu
//
//  Created by Tatsuhiro Kanai on 2016/03/16.
//  Copyright © 2016年 Adways Inc. All rights reserved.
//

import UIKit

// MARK: -
// MARK: - PLMScrollMenuAnimator

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
    
    internal override func animationDidStart(animation:CAAnimation) {
    
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


// MARK: -
// MARK: - PLMScrollMenuInteractiveTransition

public class PLMScrollMenuInteractiveTransition : NSObject , UIViewControllerInteractiveTransitioning
{
    public var percentComplete: CGFloat! = 0.0
    
    private var _animator    : UIViewControllerAnimatedTransitioning!
    private var _context     : UIViewControllerContextTransitioning!
    private var _displayLink : CADisplayLink!
    private var _completion  : (()->())?
    
    /** Init
     */
    override init()
    {
        super.init()
    }
    
    convenience init (animator: UIViewControllerAnimatedTransitioning )
    {
        self.init()
        _animator = animator
    }
    
    /** Values for Transitioning
     */
    @objc public func completionCurve() -> UIViewAnimationCurve
    {
        return UIViewAnimationCurve.Linear
    }
    
    @objc public func completionSpeed() -> CGFloat
    {
        return 1.0
    }
    
    /** Start Transition
     */
    public func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        _context = transitionContext
        _context.containerView()!.layer.speed = 0
        _animator.animateTransition(_context)
    }
    
    /** Update
     */
    internal func updateInteractiveTransition( percentComplete:CGFloat )
    {
        //print("InteractiveTransition updateInteractiveTransition percentComplete:\(percentComplete) context:\(_context) ")
        // Set PercentComplete
        self.percentComplete = percentComplete
        
        // Get Duration
        let duration : NSTimeInterval  = _animator.transitionDuration(_context)
        
        if let context = _context , containerView = context.containerView()
        {
            // Set TimeOffset
            containerView.layer.timeOffset = CFTimeInterval( percentComplete * CGFloat(duration) )
            // Update
            context.updateInteractiveTransition( self.percentComplete )
        }
    }
    
    /** Cancel
     */
    internal func cancelInteractiveTransitionWithCompletion(completion: (()->()) )
    {
        _completion = completion
        _displayLink = CADisplayLink(target: self, selector: "updateCancelAnimation")
        _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    /** Finish
     */
    internal func finishInteractiveTransition()
    {        
        // Animation
        _context.containerView()?.layer.speed = Float ( self.completionSpeed() )
        let pausedTimeOffset : CFTimeInterval =  _context.containerView()!.layer.timeOffset
        _context.containerView()!.layer.timeOffset = 0.0
        _context.containerView()!.layer.beginTime = 0.0
        let newBeginTime : CFTimeInterval = _context.containerView()!.layer.convertTime( CACurrentMediaTime() , fromLayer: nil) - pausedTimeOffset
        _context.containerView()!.layer.beginTime = newBeginTime;
        
        // context transition
        _context.finishInteractiveTransition()
        
    }
    
    /** Update Cancel Animation
     */
    internal func updateCancelAnimation()
    {
        
        let timeOffset : NSTimeInterval = _context.containerView()!.layer.timeOffset - _displayLink.duration * 0.3
        
        if timeOffset < 0 {
            
            _displayLink.invalidate()
            _displayLink = nil
            
            _context.containerView()!.layer.speed = Float(self.completionSpeed())
            _context.containerView()!.layer.timeOffset = 0.0
            
            _context.updateInteractiveTransition( CGFloat( timeOffset / _animator.transitionDuration(_context) ) )
            
            let toViewController : UIViewController = _context.viewControllerForKey(UITransitionContextToViewControllerKey)!
            toViewController.view.layer.removeAllAnimations()
            
            let fromViewController : UIViewController = _context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            fromViewController.view.layer.removeAllAnimations()
            
            _context.cancelInteractiveTransition()
            
            if let completion = _completion {
                completion();
            }
            
        } else {
            
            _context.containerView()?.layer.timeOffset = timeOffset
            _context.updateInteractiveTransition( CGFloat( timeOffset/_animator.transitionDuration(_context) ) )
        }
    }
    
}

