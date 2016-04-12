//
//  PLMScrollMenuViewController.swift
//  PLMScrollMenu
//
//  Created by Tatsuhiro Kanai on 2016/03/29.
//  Copyright © 2016年 Adways Inc. All rights reserved.
//

import UIKit

// MenuBar Direction
public enum PLMScrollMenuDirection: Int {
    case Left
    case Right
}

/**
 * ScrollMenuBarController Delegate Protocol
 */
public protocol PLMScrollMenuViewControllerDelegate {
    func menuBarController(menuBarController: PLMScrollMenuViewController, willSelectViewController: UIViewController?)
    func menuBarController(menuBarController: PLMScrollMenuViewController, didSelectViewController: UIViewController?)
    func menuBarController(menuBarController: PLMScrollMenuViewController, didCancelViewController: UIViewController?)
    func menuBarController(menuBarController: PLMScrollMenuViewController, menuBarItemAtIndex: NSInteger) -> (PLMScrollMenuBarItem)
}

public class PLMScrollMenuViewController: UIViewController, PLMScrollMenuBarDelegate
{
    /** Delegate object.
     */
    private var delegate: PLMScrollMenuViewControllerDelegate?
    
    /** MenuBar
     */
    public var menuBar:PLMScrollMenuBar!
    
    /** MenuBar Item
     */
    private var _menuItemInsets:UIEdgeInsets = UIEdgeInsetsZero
    public var menuItemInsets:UIEdgeInsets{
        set{
            _menuItemInsets = newValue
            if let menuBar = self.menuBar {
                menuBar.itemInsets = _menuItemInsets
            }
        }
        get{ return _menuItemInsets }
    }
    
    /** Container view for presenting view of child view controller.
     */
    public var containerView : UIView!
    
    /** Index of selected view controller.
     */
    private var _selectedIndex:Int = 0
    public var selectedIndex : Int {
        set{
            if( newValue > -1
                && newValue < _viewControllers!.count
                && newValue != _selectedIndex)
            {
                self.selectedViewController  = _viewControllers![newValue] as? UIViewController
            }
        }
        get{
            return _selectedIndex
        }
    }
    
    /** Items
     */
    private var _items:NSArray?
    
    /** transition
     */
    private var _transition:PLMScrollMenuTransition?
    
    /** Transition Delegate object
     */
    private var transitionDelegate: PLMScrollMenuTransitionDelegate?
    
    /** MenuBarDirection
     */
    private var _menuBarDirection:PLMScrollMenuBarDirection?
    
    /** Selected view controller.
     */
    private var _selectedViewController:UIViewController?
    public var selectedViewController:UIViewController?{
        set{
            if _viewControllers!.indexOfObject(newValue!) > -1 {
                self.transitionToViewController(newValue!)
            }
        }
        get{
            return _selectedViewController
        }
    }
    
    /**  NSArray of child view controllers.
     */
    private var _viewControllers : NSArray?
    public var viewControllers : NSArray? {
        set {
            self.setViewControllers(newValue, animated: false)
        }
        get {
            return _viewControllers
        }
    }
    
    public func setViewControllers(viewControllers:NSArray? , animated:Bool = false)
    {
        _viewControllers = viewControllers
        
        if let _ = menuBar {
            self.updateMenuBarWithViewControllers(_viewControllers!, animated:animated)
        }
        
        if let viewControllers = _viewControllers where _viewControllers!.count > 0
        {
            self.selectedViewController = viewControllers[_selectedIndex] as? UIViewController
        }
    }
    
    // MARK: -
    public override func loadView()
    {
        super.loadView()
        
        var rect : CGRect
        rect = CGRectMake(0,0,self.view.bounds.size.width, PLMScrollMenuBar.kPLMScrollMenuBarDefaultBarHeight)
        
        // MenuBar
        menuBar = PLMScrollMenuBar(frame: rect)
        menuBar.itemInsets = menuItemInsets
        self.view.addSubview(menuBar)
        menuBar.sizeToFit()
        
        rect = menuBar.frame
        rect.origin.y = self.topLayoutGuide.length
        menuBar.frame = rect
        menuBar.delegate = self
        menuBar.backgroundColor = self.view.backgroundColor
        
        // ContainerView
        let y = CGRectGetMaxY(menuBar.frame)
        rect = CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.height - y)
        containerView = UIView(frame: rect)
        containerView.backgroundColor = UIColor(white: 0.8, alpha : 1.0)
        self.view.addSubview(containerView)
        self.view.insertSubview(self.containerView, belowSubview:self.menuBar)
        
        // Transition
        _transition = PLMScrollMenuTransition.init(menuViewController: self)
        self.transitionDelegate = _transition
        
        // MenuBar & SelectedViewController
        if let viewControllers = _viewControllers where viewControllers.count > 0 {
            // SetUpMenuBar
            self.updateMenuBarWithViewControllers(viewControllers, animated: false)
            // Set selectedViewController -> transitionToViewController
            self.selectedViewController = viewControllers[selectedIndex] as? UIViewController
        }
        
    }
    
    /** Setup and Update MenuBar
     */
    private func updateMenuBarWithViewControllers( viewControllers:NSArray, animated:Bool )
    {
        //print("updateMenuBarWithViewControllers viewControllers \(viewControllers) " )
        
        // Setup
        // Update menu bar items.
        let items :NSMutableArray = NSMutableArray()
        var item : PLMScrollMenuBarItem? = nil
        
        var i = 0
        for vc in viewControllers as! [UIViewController]
        {
            if let delegate = self.delegate
            {
                item = delegate.menuBarController(self, menuBarItemAtIndex: i)
                
            } else {
                item = PLMScrollMenuBarItem.item()
                item!.title = vc.title!
                item!.tag = i;
            }
            
            items.addObject(item!)
            i++
        }
        
        _items = NSArray(array: items)
        
        //print("updateMenuBarWithViewControllers -> menuBar.setItems")
        
        menuBar.setItems(_items!, animated: animated)
        
    }
    
    // MARK: -
    /** transaction
    */
    private func transitionToViewController(toViewController:UIViewController)
    {
        //print("transitionToViewController")
        
        // fromViewController
        let fromViewController:UIViewController? = selectedViewController
        
        //print("transitionToViewController(toViewController fromViewController: \(fromViewController)")
        //print("transitionToViewController(toViewController toViewController: \(toViewController)")
        //print("transitionToViewController(toViewController containerView: \(containerView)")
        //print("transitionToViewController(toViewController userInteractionEnabled : \(menuBar.userInteractionEnabled)")
        
        // Abort transition
        if toViewController == fromViewController || containerView == nil {
            return
        }
        
        // Disabled the interaction of menu bar
        menuBar!.userInteractionEnabled = false
        
        // ViewController Transition
        // Add ToViewControler
        let toView  = toViewController.view
        toView.frame = containerView!.bounds
        toView.translatesAutoresizingMaskIntoConstraints = true
        toView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        if let fromViewController = fromViewController {
            fromViewController.willMoveToParentViewController(nil)
        }
        
        self.addChildViewController(toViewController)
        
        // Call Delegate Method MenuBarController WillSelectViewController
        if let delegate = self.delegate {
            delegate.menuBarController(self, willSelectViewController: toViewController)
        }
        
        // Present toViewController if not exist fromViewController
        // finishTransitionWithViewController without animation
        if fromViewController == nil {
            containerView.addSubview(toViewController.view)
            toViewController.didMoveToParentViewController(nil)
            self.finishTransitionWithViewController(toViewController, cancelViewController: nil)
            
            return
        }
        
        // Switch views with animation
        let fromIndex:NSInteger = _viewControllers!.indexOfObject(fromViewController!)
        let toIndex = _viewControllers!.indexOfObject(toViewController)
        
        // Direction
        var direction : PLMScrollMenuDirection = .Left
        if(toIndex > fromIndex) {
            direction = .Right
        }
        
        
        if menuBar.style == .InfinitePaging
        {
            if(fromIndex == _viewControllers!.count - 1 && toIndex == 0 ) {
                //print("XXX Right")
                direction = .Right;
            }else if(toIndex == _viewControllers!.count-1 && fromIndex == 0 ){
                //print("XXX Left")
                direction = .Left;
            }
            
            if(_menuBarDirection ==  .Right){
                //print("XXX Right")
                direction = .Right;
            }else if(_menuBarDirection == .Left){
                //print("XXX Left")
                direction = .Left;
            }
            
            _menuBarDirection = .None;
        }
        
        // Create Animator
        var animator:UIViewControllerAnimatedTransitioning? = nil
        
        if let transitionDelegate = transitionDelegate
        {
            animator = transitionDelegate.animatedTransitioning(menuBarController:self,
                animationControllerForDirection: direction,
                fromViewController: fromViewController!,
                toViewController: toViewController)
        }
        
        animator = animator ?? PLMScrollMenuAnimator()
        
        // Interactive Transition
        // UIPercentDrivenInteractiveTransition
        var interactionController : UIViewControllerInteractiveTransitioning? = nil
        
        //print("MenuBarController transitionDelegate: \(transitionDelegate) ")
        
        if let transitionDelegate = self.transitionDelegate
        {
            //interactionController = transitionDelegate.menuBarController(self, interactionControllerForAnimationController: animator!) as? UIPercentDrivenInteractiveTransition
            
            interactionController = transitionDelegate.interactiveTransitioning(menuBarController : self, interactionControllerForAnimationController: animator!)
        }
        
        // completion
        let completion: (Bool)->() = { didComplete -> () in
            if (didComplete)
            {
                fromViewController?.view.removeFromSuperview()
                fromViewController?.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
                
                // Reflect selection state
                //print("-> finishTransitionWithViewController did comp")
                self.finishTransitionWithViewController(toViewController, cancelViewController: nil)
                
            } else {
                
                // Remove toViewController from parent view controller by cancelled
                toViewController.view.removeFromSuperview()
                toViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(nil)
                
                // Reflect selection state
                //print("-> finishTransitionWithViewController not comp")
                self.finishTransitionWithViewController(fromViewController!, cancelViewController: toViewController)
            }
        }
        
        // Create transition Context
        // PLMScrollMenuBarControllerTransitionContext -> UIViewControllerContextTransitioning
        var transitionContext:PLMScrollMenuTransitionContext? = nil
        
        //print("MenuBarController interactionController: \(interactionController) ")
        transitionContext = PLMScrollMenuTransitionContext(
            menuViewController: self,
            fromViewController: fromViewController!,
            toViewController: toViewController ,
            direction: direction,
            animator: animator as! PLMScrollMenuAnimator,
            interactionController: interactionController,
            completion: completion)
        
        // Start Animation
        // Infinity
        if transitionContext!.isInteractive() {
            interactionController?.startInteractiveTransition(transitionContext!)
            // Normal
        } else {
            animator!.animateTransition(transitionContext!)
        }
        
    }
    
    /** finish transaction
     */
    private func finishTransitionWithViewController(viewController:UIViewController?, cancelViewController:UIViewController?)
    {
        //print("finishTransition ")
        
        //print("finishTransitionWithViewController ")
        let lastIndex = _selectedIndex
        let lastViewController : UIViewController? = selectedViewController
        
        // Reflect selection state
        _selectedViewController = viewController
        _selectedIndex = _viewControllers!.indexOfObject(_selectedViewController!)
        
        //Update menu bar
        let item : PLMScrollMenuBarItem = menuBar!.items![selectedIndex] as! PLMScrollMenuBarItem
        if let menuBar = menuBar  where
            item != menuBar.selectedItem
        {
            self.menuBar.selectedItem = item
        }
        
        // Call delegate method.
        if lastIndex != _selectedIndex || lastViewController != _selectedViewController {
            if let delegate = self.delegate{
                delegate.menuBarController(self, didSelectViewController:_selectedViewController!)
            }
            
        }else {
            if let delegate = self.delegate{
                delegate.menuBarController(self, didCancelViewController: cancelViewController)
            }
        }
        
        //print("finishTransitionWithViewController end0 %d",menuBar.userInteractionEnabled);
        menuBar!.userInteractionEnabled = true
        //print("finishTransitionWithViewController end1 %d",menuBar.userInteractionEnabled);
        
    }
    
    // MARK: -
    // MARK: - MenuBarController Delegate Method
    internal func menuBar(menuBar:PLMScrollMenuBar, didSelectItem:PLMScrollMenuBarItem , direction: PLMScrollMenuBarDirection )
    {
        //print(" didSelectItem direction:\(direction) ")
        
        let index = _items!.indexOfObject(didSelectItem)
        
        if index != NSNotFound && index != self.selectedIndex
        {
            _menuBarDirection = direction
            self.selectedIndex = index
        }
    }
    
}
