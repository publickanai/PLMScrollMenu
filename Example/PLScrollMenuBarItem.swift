//
//  PLMScrollMenuBarItem.swift
//  PLMScrollMenu
//
//  Created by Tatsuhiro Kanai on 2016/03/29.
//  Copyright © 2016年 Adways Inc. All rights reserved.
//

import UIKit

public class PLMScrollMenuBarButton : UIButton
{
    static func button()->PLMScrollMenuBarButton
    {
        return PLMScrollMenuBarButton.init(type: .Custom)
    }
}

public class PLMScrollMenuBarItem: NSObject
{
    // constant
    static let kPLMScrollMenuBarItemDefaultWidth:CGFloat =  90
    
    // Title
    public var title       : String = ""
    
    // Tag
    public var tag         : Int = 0
    
    // Font
    public var selectedFont: UIFont?
    public var normalFont  : UIFont?
    
    // Button
    private var _itemButton : PLMScrollMenuBarButton!
    
    // width
    private var _width: CGFloat!
    public var width : CGFloat!
        {
        set {
            _width = newValue
            if let btn = _itemButton {
                btn.frame = CGRectMake(0, 0, _width, 36)
                btn.sizeToFit()
            }
        }
        get{
            
//            if let button = _itemButton {
//                return button.frame.size.width
//            } else {
//                return 0
//            }
            return button().frame.size.width
            
        }
    }
    
    // Enabled
    private var _enabled : Bool = true
    public var enabled     : Bool {
        set { _enabled = newValue
            if let btn = _itemButton {
                btn.enabled = _enabled
            }
        }
        get { return _enabled }
    }
    
    // Selected
    private var _selected : Bool = false
    public var selected : Bool {
        
        set{ _selected = newValue
            
            if _selected {
                // keep normal font
                normalFont = _itemButton!.titleLabel!.font
                
                if let selectedFont = selectedFont {
                    _itemButton?.titleLabel!.font = selectedFont
                }
                
            } else {
                
                _itemButton!.titleLabel!.font = normalFont
            }
            
            _itemButton!.selected = selected
        }
        
        get{ return _selected}
    }
    
    /** description
     */
    override public var description : String {
        return "<PLMScrollMenuItem: \(self.title) \(NSStringFromCGRect(self.button().frame))>"
    }
    
    /** init
     */
    override init() {
        super.init()
        _width = PLMScrollMenuBarItem.kPLMScrollMenuBarItemDefaultWidth
        _enabled = true
    }
    
    // Item
    public  static func item() -> PLMScrollMenuBarItem {
        return PLMScrollMenuBarItem.init()
    }
    
    /** button
     */
    public func button() -> PLMScrollMenuBarButton
    {
        if let itemButton = _itemButton {
            
            return itemButton
            
        } else {
            
            _itemButton = PLMScrollMenuBarButton.init(type: .Custom)
            
            if let itemButton = _itemButton {
                
                itemButton.tag = self.tag
                itemButton.frame = CGRectMake(0, 0, _width, 24)
                
                itemButton.titleLabel!.font = UIFont.systemFontOfSize(16.0)
                itemButton.setTitle(self.title, forState: .Normal)
                
                itemButton.setTitleColor(UIColor(red: 0.647, green: 0.631, blue: 0.604, alpha: 1.000), forState: .Normal)
                itemButton.setTitleColor(UIColor(white: 0.886 , alpha: 1.000), forState: .Disabled)
                itemButton.setTitleColor(UIColor(red: 0.988, green: 0.224, blue: 0.129, alpha: 1.000), forState: .Selected)
                
                itemButton.enabled = enabled
                itemButton.exclusiveTouch = false
                itemButton.sizeToFit()
            }
            
            return _itemButton
        }
        
    }
    
}
