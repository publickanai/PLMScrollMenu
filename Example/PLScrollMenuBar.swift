//
//  PLMScrollMenuBar.swift
//  PLMScrollMenu
//
//  Created by Tatsuhiro Kanai on 2016/03/14.
//  Copyright © 2016年 Adways Inc. All rights reserved.
//

import UIKit


// MARK: - ScrollView
/** MenuBarScrollView
*/
public class PLMScrollMenuBarScrollView:UIScrollView {
    
    // タッチ領域の拡張
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        //print("PLMScrollMenuBarScrollView hitTestwithEvent :\(event) \(event?.type) \(event?.subtype)")
        
        if let view : UIView = super.hitTest(point, withEvent: event) {
            return view
        }else{
            var view:UIView? = nil
            for subview in self.subviews {
                let covertedPoint = self.convertPoint(point, toView: subview)
                if CGRectContainsPoint(subview.bounds, covertedPoint) {
                    view = subview
                }
            }
            return view
        }
    }
    
}

// MARK: - MenuBar

/** MenuBar Style
*/
public enum PLMScrollMenuBarStyle: UInt {
    case Normal
    case InfinitePaging
}

/** MenuBar Direction
 */
public enum PLMScrollMenuBarDirection: Int {
    case None
    case Left
    case Right
}

/** MenuBar Protocol
 */
protocol PLMScrollMenuBarDelegate {
    func menuBar(menuBar:PLMScrollMenuBar, didSelectItem:PLMScrollMenuBarItem , direction: PLMScrollMenuBarDirection )
}

/** MenuBar
 */
public class PLMScrollMenuBar: UIView , UIScrollViewDelegate {
    
    /** Constant
     */
    static let kPLMScrollMenuBarDefaultBarHeight:CGFloat =  36.0
    
    /** Delegate
     */
    internal var delegate    : PLMScrollMenuBarDelegate?
    
    /** UI
     */
    private var _scrollView     : PLMScrollMenuBarScrollView!
    private var _indicatorView  : UIView!
    private var _border         : UIView!
    private var _bg             : UIView!
    
    /** MenuBar Style
     */
    private var _style:PLMScrollMenuBarStyle = PLMScrollMenuBarStyle.Normal
    public var style:PLMScrollMenuBarStyle {
        set { self.setStyle(newValue)}
        get { return _style }
    }
    
    internal func setStyle(style:PLMScrollMenuBarStyle) {
        _style = style
        if let items = _items  where items.count > 0 {
            self.setItems(items , animated: true)
        }
    }
    
    /** MenuBar ItemInsets
     */
    private var _itemInsets  : UIEdgeInsets = UIEdgeInsetsZero
    public var itemInsets : UIEdgeInsets
        {
        set{
            _itemInsets = newValue
            
            // reset menubar
            if let items = _items where items.count > 0{
                
                // Clear all of menu items
                for view in _scrollView.subviews {
                    if view.isKindOfClass(PLMScrollMenuBarButton) {
                        view.removeFromSuperview()
                    }
                }
                
                // Apply Style
                if( _style == PLMScrollMenuBarStyle.Normal )
                {
                    self.setupMenuBarButtonsForNormalStyle(false)
                } else
                    if( _style == PLMScrollMenuBarStyle.InfinitePaging ){
                        self.setupMenuBarButtonsForInfinitePagingStyle(false)
                }
            }
        }
        
        get{
            return _itemInsets
        }
    }
    
    /** flags
     */
    private var _showsIndicator:Bool!
    private var _showsSeparatorLine:Bool!
    
    /** BarHeight
     */
    private var _barHeight   : CGFloat?
    
    /** Indicator Color
     */
    private var _indicatorColor:UIColor!
    public func setIndicatorColor(color: UIColor) {
        _indicatorColor = color
        if let indicator = _indicatorView {
            indicator.backgroundColor = _indicatorColor
        }
    }
    
    /** Border Color
     */
    private var _borderColor:UIColor = UIColor(white: 0.698, alpha: 1.000)
    public var setBorderColor:UIColor {
        set{_borderColor = newValue
            if let border = _border{
                border.backgroundColor = _borderColor
            }
        }
        get{ return _borderColor }
    }
    
    /** Selected Item
     */
    private var _selectedItem: PLMScrollMenuBarItem?
    public var selectedItem:PLMScrollMenuBarItem? {
        set { self.setSelectedItem(newValue!, animated: true) }
        get { return _selectedItem }
    }
    
    public func setSelectedItem(item : PLMScrollMenuBarItem ,animated:Bool)
    {
        //print("setSelectedItem")
        //print("setSelectedItem _scrollView.contentOffset:\(_scrollView.contentOffset)")
        
        if ( _selectedItem == item ) { return }
        
        self.userInteractionEnabled = false
        
        if _selectedItem != nil {
            _selectedItem!.selected = false
        }
        
        var direction : PLMScrollMenuBarDirection = PLMScrollMenuBarDirection.None
        
        // InfinitePaging Direction
        if(_style == PLMScrollMenuBarStyle.InfinitePaging)
        {
            var lastIndex = -1
            
            if let selectedItem = _selectedItem {
                lastIndex = _items!.indexOfObject(selectedItem)
            }
            
            let nextIndex = _items!.indexOfObject(item)
            
            if nextIndex - lastIndex > 0 {
                if (nextIndex - lastIndex) < _items!.count/2 {
                    direction = PLMScrollMenuBarDirection.Right
                } else {
                    direction = PLMScrollMenuBarDirection.Left
                }
            } else {
                if ( (lastIndex - nextIndex) < _items!.count/2 ) {
                    direction = PLMScrollMenuBarDirection.Left
                } else {
                    direction = PLMScrollMenuBarDirection.Right
                }
            }
        }
        
        // New Position
        _selectedItem = item
        _selectedItem!.selected = true
        
        // Selected item want to be displayed to center as possible.
        var offset : CGPoint = CGPointZero
        var newPosition : CGPoint = CGPointZero
        
        if _style == PLMScrollMenuBarStyle.Normal
        {
            if _selectedItem!.button().center.x > _scrollView!.bounds.size.width*0.5 &&
                NSInteger(_scrollView.contentSize.width - _selectedItem!.button().center.x) >= NSInteger(_scrollView.bounds.size.width*0.5)
            {
                offset = CGPointMake( _selectedItem!.button().center.x - _scrollView!.frame.size.width * 0.5 , 0 )
                
            } else if ( _selectedItem!.button().center.x < _scrollView.bounds.size.width*0.5)
            {
                offset = CGPointMake(0, 0)
                
            } else if ( NSInteger( _scrollView.contentSize.width - _selectedItem!.button().center.x ) < NSInteger(_scrollView.bounds.size.width*0.5))
            {
                offset = CGPointMake(_scrollView.contentSize.width-_scrollView.bounds.size.width, 0)
            }
            
            _scrollView.setContentOffset(offset, animated: animated)
            
            newPosition = _scrollView.convertPoint(CGPointZero, fromCoordinateSpace: _selectedItem!.button())
            
        } else if _style == PLMScrollMenuBarStyle.InfinitePaging
        {
            let margin : CGFloat = (_infinitePagingBoundsWidth! - _selectedItem!.width) * 0.5
            offset = CGPointMake(_selectedItem!.button().frame.origin.x - margin, 0.0)
            newPosition.x = _infinitePagingOffsetX! + itemInsets.left
        }
        
        // Indicator set NewPosition
        if(_indicatorView.frame.origin.x == 0.0 &&
            _indicatorView.frame.size.width == 0.0)
        {
            var f = _indicatorView.frame
            f.origin.x = newPosition.x - 3
            f.size.width = _selectedItem!.button().frame.size.width + 6
            _indicatorView.frame = f
            
            //print("setSelectedItem 0 indicatorView.frame: \(_indicatorView.frame)")
            
        } else if(_style == PLMScrollMenuBarStyle.Normal)
        {
            //print("setSelectedItem Normal")
            var dur:NSTimeInterval = NSTimeInterval(fabs(newPosition.x - _indicatorView!.frame.origin.x)) / 160.0 * 0.4 * 0.8
            
            if(dur < 0.38){
                dur = 0.1;
            } else if (dur > 0.6){
                dur = 0.2;
            }
            
            UIView.animateWithDuration(dur,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.1,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { [weak self] () -> Void in
                    
                    if let weakSelf =  self
                    {
                        var f : CGRect = weakSelf._indicatorView!.frame;
                        f.origin.x = newPosition.x - 3;
                        f.size.width = weakSelf._selectedItem!.button().frame.size.width + 6;
                        weakSelf._indicatorView!.frame = f;
                    }
                    
                }, completion: { [weak self] (finished) -> Void in
                    if let weakSelf =  self {
                        weakSelf.userInteractionEnabled = true;
                        weakSelf.delegate!.menuBar(weakSelf, didSelectItem: weakSelf._selectedItem! , direction: direction)
                        
                    }
                    
                })
            
        }else if(_style == PLMScrollMenuBarStyle.InfinitePaging)
        {
            // Move Indicator
            //print("setSelectedItem InfinitePaging")
            
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue(),
                {
                    
                    self.reorderItemsForInfinitePaging()
                    
                    // Indicator Position
                    var f : CGRect = self._indicatorView.frame
                    f.origin.x = self._selectedItem!.button().frame.origin.x - 3
                    f.size.width = self._selectedItem!.button().frame.size.width + 6
                    self._indicatorView.frame = f
                    
                    self.userInteractionEnabled = true
                    
                    // PLMScrollMenuBar Delegate Method
                    if let delegate = self.delegate {
                        delegate.menuBar(self, didSelectItem: self._selectedItem! , direction: direction)
                    }
                    
                    self._infinitePagingIsTappedItem = false
                    
            })
            
        }
        
    }
    
    /** OffsetX for ScrollView
     */
    public var scrollOffsetX : CGFloat! {
        get{
            if let v = _scrollView {
                return v.contentOffset.x
            }
            return nil
        }
    }
    
    /** Scroll with Ratio
     */
    public func scrollByRatio(ratio:CGFloat, from:CGFloat)
    {
        //print("scrollByRatio ratio:\(ratio) from:\(from)")
        
        if _style == PLMScrollMenuBarStyle.Normal
        {
            let index = _items!.indexOfObject(_selectedItem!)
            let ignoreCount = NSInteger(_scrollView.frame.size.width*0.5/(_scrollView.contentSize.width/CGFloat(_items!.count)))
            
            for(var i = 0; i < ignoreCount; i++) {
                if (index == i) {
                    return
                } else if (index == _items!.count-1-i) {
                    return
                }
            }
            
            if(index == ignoreCount && ratio < 0.0) {
                return
            } else if(index == _items!.count-1-ignoreCount && ratio > 0.0) {
                return
            }
            
        }
        
        _scrollView.contentOffset = CGPointMake(from + _scrollView.contentSize.width/CGFloat(_items!.count) * ratio, 0)
    }
    
    /** items
     */
    private var _items       : NSArray!
    public var items: NSArray! {
        set{ self.setItems(newValue) }
        get{ return _items}
    }
    
    // setItems
    public func setItems(items:NSArray! , animated:Bool = false)
    {
        //print("k1 \(items) ")
        _selectedItem = nil
        //print("k2 \(items) ")
        _items = items
        //print("k3 \(_items) ")
        
        // Clear all of menu items
        for view in _scrollView.subviews {
            if view.isKindOfClass(PLMScrollMenuBarButton) {
                view.removeFromSuperview()
            }
        }
        //print("k3 \(_items) ")
        // Abort
        if let itm = items where itm.count == 0 {
            return
        }
        
        //print("k4 _style:\(_style)  \(_items) ")
        
        // Apply Style
        if( _style == PLMScrollMenuBarStyle.Normal )
        {
            self.setupMenuBarButtonsForNormalStyle(animated)
            
        } else if( _style == PLMScrollMenuBarStyle.InfinitePaging )
        {
            self.setupMenuBarButtonsForInfinitePagingStyle(animated)
        }
    }
    
    /** Infinite Paging
     */
    private var _infinitePagingBoundsWidth  : CGFloat?
    private var _infinitePagingOffsetX      : CGFloat?
    private var _infinitePagingOrder        : NSMutableArray?
    private var _infinitePagingIsTappedItem : Bool?
    private var _infinitePagingLastContentOffsetX : CGFloat?
    
    // MARK: -
    // MARK: - hitTest
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        if(!self.userInteractionEnabled) { return nil }
        
        // Expands ScrollView's tachable area
        var view : UIView? = _scrollView.hitTest( self.convertPoint(point, toView: _scrollView) , withEvent: event )
        
        if view == nil && CGRectContainsPoint(self.bounds,point) {
            view = self._scrollView
        }
        
        return view
    }
    
    // MARK: -
    // MARK: - init
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.initialize()
    }
    
    convenience init () {
        self.init(frame:CGRectZero)
    }
    
    // from nib
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    // initialize
    private func initialize()
    {
        
        // flag
        _showsIndicator = true
        _showsSeparatorLine = true
        
        //
        _items  =   NSArray()
        _barHeight = PLMScrollMenuBar.kPLMScrollMenuBarDefaultBarHeight;
        _indicatorColor = UIColor(red: 0.988, green: 0.224, blue: 0.129, alpha: 1.000)
        
        // BG
        self.backgroundColor = UIColor.clearColor()
        
        // ScrollView
        _scrollView = PLMScrollMenuBarScrollView(frame: self.bounds )
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.contentOffset = CGPointZero
        _scrollView.scrollsToTop = false
        self.addSubview(_scrollView)
        
        // Indicator
        let indicator = UIView(frame: CGRectMake(0, self.bounds.size.height - 4, 0, 4) )
        _indicatorView = indicator;
        _indicatorView.backgroundColor = _indicatorColor
        _scrollView.addSubview(_indicatorView)
        
        //
        _border = UIView(frame:CGRectMake(0, self.bounds.size.height - 0.25, self.bounds.size.width, 0.25) )
        _border.backgroundColor = _borderColor
        self.addSubview(_border)
        
    }
    
    // MARK: -
    // MARK: - Setup
    
    /** NormalStyle
    */
    private func setupMenuBarButtonsForNormalStyle( animated:Bool )
    {
        print("Setup as Normal")
        
        // scroll view
        var f : CGRect
        _scrollView.pagingEnabled = false
        _scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        _scrollView.clipsToBounds = true
        _scrollView.delegate = nil
        
        // setup menu button frame
        var offset : CGFloat = itemInsets.left
        var c : Int  = 0
        for  item in _items! as! [PLMScrollMenuBarItem]
        {
            let b : PLMScrollMenuBarButton = item.button()
            f = CGRectMake(offset,
                itemInsets.top,
                item.width,
                _scrollView.bounds.size.height - itemInsets.top + itemInsets.bottom )
            
            offset += f.size.width + itemInsets.right + itemInsets.left
            b.frame = f
            b.alpha = 0.0
            b.tag = c
            c++
            _scrollView.addSubview(b)
            b.addTarget(self, action: "didTapMenuButton:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        // content size
        var contentWidth = offset - itemInsets.left
        
        // case contentsWidth is smaller than width
        if contentWidth < _scrollView.bounds.size.width
        {
            // Align items to center if number of items is less
            // (_scrollView.bounds.size.width - contentWidth) == Insets.left + Insets.right
            offset = (_scrollView.bounds.size.width - contentWidth) * 0.5
            
            contentWidth = _scrollView.bounds.size.width
            
            // Align items
            for v in _scrollView.subviews {
                if v.isKindOfClass(PLMScrollMenuBarButton) {
                    f = v.frame
                    f.origin.x += offset // adding inset.left
                    v.frame = f
                }
            }
        }
        
        // Set scrollView's contentsSize
        _scrollView.contentSize = CGSizeMake( contentWidth , _scrollView.bounds.size.height )
        
        // Animate to Display Button Items
        if !animated {
            //Without Animate
            for v in _scrollView.subviews {
                if v.isKindOfClass(PLMScrollMenuBarButton) {
                    v.alpha = 1.0
                }
            }
        } else {
            // With Animate
            var i = 0
            for v in _scrollView.subviews {
                if v.isKindOfClass(PLMScrollMenuBarButton) {
                    self.animateButton(v, atIndex: i)
                    i++
                }
            }
        }
        
        // SelectedItem
        if _selectedItem == nil && _items!.count > 0 {
            self.selectedItem = _items![0] as? PLMScrollMenuBarItem
        }
        
    }
    
    /** InfinitePagingStyle
     */
    private func setupMenuBarButtonsForInfinitePagingStyle( animated:Bool )
    {
        //print("Setup as InfinitePaging")
        
        var f :CGRect
        _scrollView.pagingEnabled = true
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        _scrollView.clipsToBounds = false
        _scrollView.delegate = self
        
        // Get max width
        var maxWidth : CGFloat = 0.0
        var totalWidth : CGFloat = 0.0
        
        for item in _items as! [PLMScrollMenuBarItem]
        {
            if  maxWidth < item.width { maxWidth = item.width }
            
            totalWidth += item.width + itemInsets.right + itemInsets.left
            //print("setup InfinitePaging item.width: \(item.width) totalWidth:\(totalWidth) ")
        }
        
        //maxWidth = maxWidth + 0.5 // comment off this line
        //print("setup InfinitePaging maxWidth:\(maxWidth) totalWidth:\(totalWidth) _scrollView.bounds.size.width:\(_scrollView.bounds.size.width)")
        
        // Display normal style if can show all items
        if totalWidth < _scrollView.bounds.size.width
        {
            //print("Can not infinite paging, because the number of items is too small")
            _style = PLMScrollMenuBarStyle.Normal
            self.setupMenuBarButtonsForNormalStyle(animated)
            return
        }
        
        // Set up menu button
        _infinitePagingOrder = NSMutableArray()
        
        var offset:CGFloat = itemInsets.left
        let totalCount = _items!.count
        let halfCount = totalCount/2
        let evenFactor = totalCount%2 > 0 ? 0 : 1
        
        var firstItemOriginX : CGFloat = 0.0
        
        // _items[0] In Center ex) -3 -2 -1 0 1 2 3
        for( var i = -( halfCount - evenFactor); i <= halfCount ; i++ )
        {
            // CountIndex to Real Index of Array
            let index = (totalCount + i) % totalCount
            let item : PLMScrollMenuBarItem = _items![index] as! PLMScrollMenuBarItem
            
            if let b : PLMScrollMenuBarButton = item.button()
            {
                let diffWidth = maxWidth - item.width
                //print("create button index \(index)\toffset:\(offset)\tbuttonX:\(offset + diffWidth*0.5)\tmaxWidth:\(maxWidth)\titem.width:\(item.width)\tdiffWidth:\(diffWidth)\tdiffWidth*0.5:\(diffWidth*0.5)")
                
                f = CGRectMake(offset + diffWidth*0.5,
                    itemInsets.top,
                    item.width,
                    _scrollView.bounds.size.height - itemInsets.top + itemInsets.bottom)
                offset += diffWidth*0.5 + f.size.width + diffWidth*0.5 + _itemInsets.right + _itemInsets.left
                b.frame = f
                b.alpha = 0.0
                
                _scrollView.addSubview(b)
                
                b.addTarget(self, action: "didTapMenuButton:", forControlEvents: UIControlEvents.TouchUpInside)
                
                if index == 0 {
                    // OffsetX for Center Item
                    firstItemOriginX = f.origin.x - (itemInsets.left + diffWidth*0.5)
                }
                
                _infinitePagingOrder?.addObject(NSValue(nonretainedObject: item))
            }
            
        }
        
        // BoundsWidth for a Menu Button
        _infinitePagingBoundsWidth = itemInsets.left + maxWidth + itemInsets.right
        
        // Scroll view size same as one button bounds
        _scrollView.frame = CGRectMake(
            (_scrollView.frame.size.width - _infinitePagingBoundsWidth!)*0.5,
            0,
            _infinitePagingBoundsWidth!,
            _scrollView.frame.size.height)
        let contentWidth : CGFloat = offset - itemInsets.left // remove _itemInsets.left of Next Item
        
        _scrollView.contentSize = CGSizeMake(contentWidth,_scrollView.bounds.size.height)
        _scrollView.contentOffset = CGPointMake(firstItemOriginX, 0)
        
        // set value
        _infinitePagingOffsetX = firstItemOriginX
        _infinitePagingLastContentOffsetX = firstItemOriginX
        
        // remove this line
        //_scrollView.setNeedsLayout()
        
        // Display Buttons
        if animated {
            
            // with Animate
            for (var i = 0; i <= halfCount ; i++ ) {
                
                let index1 = (totalCount + i) % totalCount
                let item1 : PLMScrollMenuBarItem = _items![index1] as! PLMScrollMenuBarItem
                
                if let view1 : PLMScrollMenuBarButton = item1.button() where view1.isKindOfClass(PLMScrollMenuBarButton) {
                    self.animateButton(view1, atIndex: i)
                }
                
                let index2 : NSInteger = (totalCount-1) % totalCount
                
                if index1 == index2 {
                    continue
                }
                
                let item2 : PLMScrollMenuBarItem = items![index2] as! PLMScrollMenuBarItem
                let view2 : PLMScrollMenuBarButton = item2.button()
                
                if view2.isKindOfClass(PLMScrollMenuBarButton) {
                    self.animateButton(view2, atIndex: i)
                }
            }
            
        } else {
            
            // Without Animate
            for view in (_scrollView.subviews) {
                if view.isKindOfClass(PLMScrollMenuBarButton) {
                    view.alpha = 1.0;
                }
            }
        }
        
        // set SelectedItem
        if _selectedItem != nil
        {
            dispatch_async(dispatch_get_main_queue(),
                { [weak self] () -> Void in
                    if let weakSelf = self {
                        //print("setupMenuBarButtonsForInfinitePagingStyle - > setSelectedItem ")
                        weakSelf.setSelectedItem(weakSelf._items[0] as! PLMScrollMenuBarItem ,animated: false)
                    }
                })
        }
        
    }
    
    // MARK: -
    // MARK: - ReOrder Button's Order
    private func reorderItemsForInfinitePaging()
    {
        //print("ReOrder Button's Order")
        
        let diffX : CGFloat = _scrollView.contentOffset.x - _infinitePagingOffsetX!
        let moveCount : NSInteger = NSInteger( fabs(diffX)/_infinitePagingBoundsWidth! )
        
        if( diffX > 0 )
        {
            //Right Item
            if (_infinitePagingOrder!.count > 0 ) {
                for(var i = 0 ; i < moveCount ; i++ ) {
                    let firstObj = _infinitePagingOrder![0]
                    _infinitePagingOrder!.addObject(firstObj)
                    _infinitePagingOrder!.removeObjectAtIndex(0)
                }
            }
            
        } else if (diffX < 0 ) {
            //Left Item
            if (_infinitePagingOrder!.count > 0 ) {
                for(var i = 0 ; i < moveCount ; i++ ) {
                    let lastObj = _infinitePagingOrder!.lastObject
                    _infinitePagingOrder!.insertObject(lastObj!, atIndex: 0)
                    _infinitePagingOrder!.removeObjectAtIndex( _infinitePagingOrder!.count - 1 )
                }
            }
        }
        
        var index : NSInteger = 0
        var f : CGRect
        
        for val in _infinitePagingOrder! {
            
            let item  = val.nonretainedObjectValue as! PLMScrollMenuBarItem
            f = item.button().frame
            f.origin.x = CGFloat(index) * _infinitePagingBoundsWidth! + itemInsets.left
            item.button().frame = f
            index++
            
        }
        
        // Content Offset
        _scrollView.contentOffset = CGPointMake(_selectedItem!.button().frame.origin.x - (_infinitePagingBoundsWidth! - _selectedItem!.width) * 0.5, 0)
    }
    
    // MARK: -
    // MARK: - Animate with UIView and Button Index
    private func animateButton(view:UIView, atIndex index : NSInteger )
    {
        view.transform = CGAffineTransformMakeScale(1.4, 1.4)
        
        UIView.animateWithDuration(0.24,
            delay:0.06 + 0.10 * Double(index),
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                view.alpha = 1
                view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }) { (finished) -> Void in
                //print("animate Button finished:\(finished)")
        }
    }
    
    // MARK: -
    // MARK: - Button Tapped
    private func didTapMenuButton(sender:AnyObject)
    {
        // Set SelectedItem
        for item in _items! as! [PLMScrollMenuBarItem] {
            if sender as! PLMScrollMenuBarButton == item.button() && item != _selectedItem {
                _infinitePagingIsTappedItem = true
                self.selectedItem = item
                break
            }
        }
    }
    
    // MARK: -
    // MARK: - UIScrollView Delegate Method For InfinitePaging
    @objc public func scrollViewDidEndDecelerating( scrollView: UIScrollView )
    {
        if(_infinitePagingLastContentOffsetX == scrollView.contentOffset.x) {
            return
        }
        
        if _infinitePagingIsTappedItem == nil || _infinitePagingIsTappedItem! == false
        {
            
            // Reset items Order
            self.reorderItemsForInfinitePaging()
            
            // Reset ContentOffset
            _scrollView.contentOffset = CGPointMake(_infinitePagingLastContentOffsetX!, 0)
            
            var index : NSInteger = 0;
            var selectedItem: PLMScrollMenuBarItem? = nil
            
            for val in _infinitePagingOrder!
            {
                let item = val.nonretainedObjectValue as! PLMScrollMenuBarItem
                
                if( NSInteger(item.button().frame.origin.x) == NSInteger(_infinitePagingOffsetX! + itemInsets.left) ) {
                    selectedItem = item
                }
                
                index++
            }
            
            if let selectedItem = selectedItem  where selectedItem != _selectedItem {
                //print("scrollViewDidEndDecelerating -> _selectedItem")
                self.setSelectedItem(selectedItem, animated: true)
            }
        }
        
        _infinitePagingLastContentOffsetX = scrollView.contentOffset.x;
        
    }
    
    
}
