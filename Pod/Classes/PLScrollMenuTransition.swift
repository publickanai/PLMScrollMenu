//
//  PLMScrollMenuTransition.swift
//  PLMScrollMenu
//
//  Created by Tatsuhiro Kanai on 2016/03/29.
//  Copyright © 2016年 Adways Inc. All rights reserved.
//

import UIKit

// MARK: -
// MARK: - PLMScrollMenuTransitionDelegate

protocol PLMScrollMenuTransitionDelegate
{
    func animatedTransitioning(menuBarController menuBarController : PLMScrollMenuViewController ,
        animationControllerForDirection : PLMScrollMenuDirection ,
        fromViewController : UIViewController ,
        toViewController : UIViewController
        ) -> UIViewControllerAnimatedTransitioning?
    
    func interactiveTransitioning(menuBarController menuBarController : PLMScrollMenuViewController ,
        interactionControllerForAnimationController : UIViewControllerAnimatedTransitioning ) -> UIViewControllerInteractiveTransitioning?
}

// MARK: -
// MARK: - PLMScrollMenuTransition

public class PLMScrollMenuTransition: NSObject , PLMScrollMenuTransitionDelegate
{
    private var _menuViewController : PLMScrollMenuViewController!
    
    private var _direction : PLMScrollMenuDirection!
    private var _panGesture : UIPanGestureRecognizer!
    
    private var _animatedTransition : PLMScrollMenuAnimator!
    private var _interactiveTransition : PLMScrollMenuInteractiveTransition!
    
    /** Init
     */
    convenience init(menuViewController : PLMScrollMenuViewController )
    {
        self.init()
        _menuViewController = menuViewController
        setup()
    }
    
    private func setup()
    {
        _animatedTransition = PLMScrollMenuAnimator()
        _panGesture = UIPanGestureRecognizer.init(target: self, action: "didDetectPanGesture:" )
        _menuViewController.containerView.addGestureRecognizer(_panGesture)
    }
    
    /** Pangesture
     */
    internal func didDetectPanGesture ( gesture: UIPanGestureRecognizer)
    {
        let view : UIView  = _menuViewController.containerView
        
        // Began
        if (gesture.state == .Began)
        {
            let location:CGPoint = gesture.locationInView(view)
            
            // to Left Side
            if (location.x <  CGRectGetMidX(view.bounds)
                && _menuViewController.viewControllers!.count > 1)
            {
                
                // Normal
                if(_menuViewController.menuBar.style == .Normal
                    && _menuViewController.selectedIndex > 0)
                {
                    _direction = .Left
                    
                    // Create InteractiveTransition
                    _interactiveTransition = PLMScrollMenuInteractiveTransition(animator: _animatedTransition)
                    
                    // Set SelectedViewController
                    let vc : UIViewController = _menuViewController.viewControllers![_menuViewController.selectedIndex-1] as! UIViewController
                    _menuViewController.selectedViewController = vc
                    
                    // Infinity
                }else if(_menuViewController.menuBar.style == .InfinitePaging
                    && _menuViewController.selectedIndex >= 0)
                {
                    
                    _direction = .Left
                    
                    // Create InteractiveTransition
                    _interactiveTransition = PLMScrollMenuInteractiveTransition(animator: _animatedTransition)
                    
                    // Set SelectedViewController
                    var index : NSInteger = _menuViewController.selectedIndex-1
                    if(index < 0){ index = _menuViewController.viewControllers!.count - 1}
                    let vc:UIViewController = _menuViewController.viewControllers![index] as! UIViewController
                    _menuViewController.selectedViewController = vc
                    
                }
                
            // to Right Side
            } else if ( location.x >=  CGRectGetMidX(view.bounds) && _menuViewController.viewControllers!.count > 1)
            {
                // Normal
                if(_menuViewController.menuBar.style == .Normal
                    && _menuViewController.selectedIndex < _menuViewController.viewControllers!.count - 1)
                {
                    _direction = .Right
                    
                    // Create InteractiveTransition
                    _interactiveTransition = PLMScrollMenuInteractiveTransition(animator: _animatedTransition)
                    
                    let vc : UIViewController = _menuViewController.viewControllers![_menuViewController.selectedIndex+1] as! UIViewController
                    
                    // Set SelectedViewController
                    _menuViewController.selectedViewController = vc
                    
                // Infenity
                }else if(_menuViewController.menuBar.style == .InfinitePaging
                    && _menuViewController.selectedIndex <= _menuViewController.viewControllers!.count-1)
                {
                    _direction = .Right
                    
                    // Create InteractiveTransition
                    _interactiveTransition = PLMScrollMenuInteractiveTransition(animator: _animatedTransition)
                    
                    // Set SelectedViewController
                    var index : NSInteger = _menuViewController.selectedIndex+1;
                    if(index > _menuViewController.viewControllers!.count - 1) { index = 0 }
                    let vc : UIViewController = _menuViewController.viewControllers![index] as! UIViewController
                    _menuViewController.selectedViewController = vc
                    
                }
            }
            
            // Changed
        } else if (gesture.state == .Changed)
        {
            
            let translation : CGPoint = gesture.translationInView(view)
            if _direction == nil { return }
            
            // Update
            // Only if moving direction was matched, Updates the interaction controller.
            if let direction = _direction where
                ( direction == .Left && translation.x > 0.0) || (direction == .Right && translation.x < 0.0 )
            {
                let d : CGFloat = fabs(translation.x / CGRectGetWidth(view.bounds))
                if let interactiveTransition = _interactiveTransition {
                    interactiveTransition.updateInteractiveTransition(d)
                }
            }
            
        // End
        } else if (gesture.state == .Ended)
        {
            
            // Finish
            // If progress is less than 15%, Cancel transition.
            if let interactiveTransition = _interactiveTransition where interactiveTransition.percentComplete > 0.15
            {
                _interactiveTransition.finishInteractiveTransition()
                
            // Cancel Completion
            } else {
                
                if let _ = _interactiveTransition
                {
                    // be disabled recognizing pan gesture during animation for canceling transition.
                    _panGesture.enabled = false
                    _interactiveTransition.cancelInteractiveTransitionWithCompletion(
                        { [weak self] () in
                            if let weakSelf = self {
                                weakSelf._panGesture.enabled = true
                            }
                        })
                }
            }
            
            // clear interactiveTransition
            _interactiveTransition = nil;
            
        }
    }
    
    /** PLMScrollMenuBarControllerTransition Delegate
     */
    internal func animatedTransitioning(menuBarController menuBarController : PLMScrollMenuViewController ,
        animationControllerForDirection : PLMScrollMenuDirection ,
        fromViewController : UIViewController ,
        toViewController : UIViewController
        ) -> UIViewControllerAnimatedTransitioning?
    {
        return _animatedTransition
    }
    
    internal func interactiveTransitioning(menuBarController menuBarController : PLMScrollMenuViewController ,
        interactionControllerForAnimationController : UIViewControllerAnimatedTransitioning ) -> UIViewControllerInteractiveTransitioning?
    {
        return _interactiveTransition
    }
    
}


// MARK: -
// MARK: - PLMScrollMenuTransitionContext

public class PLMScrollMenuTransitionContext : NSObject , UIViewControllerContextTransitioning {
    
    private(set) var direction          : PLMScrollMenuDirection!
    
    private var _presentationStyle      : UIModalPresentationStyle!
    private var _menuViewController     : PLMScrollMenuViewController?
    
    private var _containerView          : UIView?
    private var _animated               : Bool = false
    private var _cancelled              : Bool = false
    private var _interactive            : Bool = false
    
    private var _appearingFromRect      : CGRect!
    private var _appearingToRect        : CGRect!
    private var _disappearingFromRect   : CGRect!
    private var _disappearingToRect     : CGRect!
    
    private var _fromOffsetX            : CGFloat!
    
    private var _viewControllers        : NSDictionary!
    private var _animator               : PLMScrollMenuAnimator!
    private var _completion             : ((Bool) -> ())?
    
    // init
    override init() {
        super.init()
    }
    
    convenience init( menuViewController:PLMScrollMenuViewController,
        fromViewController:UIViewController,
        toViewController:UIViewController,
        direction:PLMScrollMenuDirection,
        animator:PLMScrollMenuAnimator,
        interactionController:UIViewControllerInteractiveTransitioning?,
        completion:(didComplete : Bool) -> ()
        )
    {
        self.init()
        
        _menuViewController = menuViewController
        _presentationStyle = UIModalPresentationStyle.None
        
        if let _ = interactionController{
            _interactive =  true
        } else {
            _interactive =  false
        }
        
        // Set ContainerView
        _containerView = _menuViewController!.containerView
        
        // Set ViewControllers
        _viewControllers = [UITransitionContextFromViewControllerKey:fromViewController,UITransitionContextToViewControllerKey:toViewController]
        
        // Set Direction
        self.direction = direction
        
        // Set Animator
        _animator = animator
        
        // Set Completion
        _completion = completion
        
        _cancelled = false
        
        // Offset Size
        var offset : CGFloat = _containerView!.bounds.size.width
        offset *= (direction == .Right) ? -1 : 1
        
        // Bounds Rect
        _disappearingFromRect   =   _containerView!.bounds
        _appearingToRect        =   _containerView!.bounds
        
        _disappearingToRect = CGRectOffset (_containerView!.bounds, offset, 0)
        _appearingFromRect  = CGRectOffset (_containerView!.bounds, -offset, 0)
    }
    
    /** UIViewControllerContextTransitioning Protocol
     */
     
    // The view in which the animated transition should take place.
    public func containerView() -> UIView?
    {
        return _containerView
    }
    
    // Most of the time this is YES. For custom transitions that use the new UIModalPresentationCustom
    // presentation type we will invoke the animateTransition: even though the transition should not be
    // animated. This allows the custom transition to add or remove subviews to the container view.
    public func isAnimated() -> Bool
    {
        return _animated
    }
    
    // This indicates whether the transition is currently interactive.
    public func isInteractive() -> Bool
    {
        return _interactive
    }
    
    public func transitionWasCancelled() -> Bool
    {
        return _cancelled
    }
    
    @objc public func presentationStyle() -> UIModalPresentationStyle
    {
        return _presentationStyle
    }
    
    // It only makes sense to call these from an interaction controller that
    // conforms to the UIViewControllerInteractiveTransitioning protocol and was
    // vended to the system by a container view controller's delegate or, in the case
    // of a present or dismiss, the transitioningDelegate.
    @objc public func updateInteractiveTransition ( percentComplete: CGFloat )
    {
        //print("Context updateInteractiveTransition percentComplete:\(percentComplete) ")
        
        if !_animated {
            _fromOffsetX = _menuViewController?.menuBar.scrollOffsetX
        }
        
        _animated = true
        
        // MenuBar Scrolling By Ratio
        if let menuViewController = _menuViewController {
            menuViewController.menuBar.scrollByRatio( percentComplete * ((direction == PLMScrollMenuDirection.Right) ? 1 : -1) , from: _fromOffsetX)
        }
        
    }
    
    /** Context Finish InteractiveTransition
     */
    @objc public func finishInteractiveTransition()
    {
        _cancelled = false
        _animated = false
    }
    
    /** Context Cancel InteractiveTransition
     */
    @objc public func cancelInteractiveTransition()
    {
        _cancelled = true
        _animated = false
    }
    
    // This must be called whenever a transition completes (or is cancelled.)
    // Typically this is called by the object conforming to the
    // UIViewControllerAnimatedTransitioning protocol that was vended by the transitioning
    // delegate.  For purely interactive transitions it should be called by the
    // interaction controller. This method effectively updates internal view
    // controller state at the end of the transition.
    public func completeTransition(didComplete: Bool)
    {
        if let completion = _completion {
            completion(didComplete)
        }
        
        _animated = false
    }
    
    // Currently only two keys are defined by the
    // system - UITransitionContextToViewControllerKey, and
    // UITransitionContextFromViewControllerKey.
    // Animators should not directly manipulate a view controller's views and should
    // use viewForKey: to get views instead.
    public func viewControllerForKey(key: String) -> UIViewController?
    {
        return _viewControllers.objectForKey(key) as? UIViewController
    }
    
    // Currently only two keys are defined by the system -
    // UITransitionContextFromViewKey, and UITransitionContextToViewKey
    // viewForKey: may return nil which would indicate that the animator should not
    // manipulate the associated view controller's view.
    public func viewForKey(key: String) -> UIView?
    {
        return (_viewControllers.objectForKey(key) as? UIViewController)?.view
    }
    
    @objc public func targetTransform() -> CGAffineTransform
    {
        return CGAffineTransformIdentity
    }
    
    // The frame's are set to CGRectZero when they are not known or
    // otherwise undefined.  For example the finalFrame of the
    // fromViewController will be CGRectZero if and only if the fromView will be
    // removed from the window at the end of the transition. On the other
    // hand, if the finalFrame is not CGRectZero then it must be respected
    // at the end of the transition.
    public func initialFrameForViewController(vc: UIViewController) -> CGRect
    {
        if vc == self.viewControllerForKey(UITransitionContextFromViewControllerKey){
            return _disappearingFromRect
        } else {
            return _appearingFromRect
        }
    }
    
    public func finalFrameForViewController(vc: UIViewController) -> CGRect
    {
        if vc == self.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            return _disappearingToRect
        } else {
            return _appearingToRect
        }
    }
    
    
}

