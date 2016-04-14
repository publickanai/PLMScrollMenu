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
    
    // Tag
    public var tag         : Int = 0
    
    // Title
    public var title       : String = ""
    
    // Title Font
    public var selectedFont: UIFont?
    public var normalFont  : UIFont?
    
    // Button
    private var _itemButton : PLMScrollMenuBarButton!
    
    // Button Width
    private var _width: CGFloat!
    public var width : CGFloat!{
        
        set{_width = newValue
            if let btn = _itemButton {
                btn.frame = CGRectMake(0, 0, _width, 36)
                btn.sizeToFit()
            }
        }
        
        get{ return button().frame.size.width }
    }
    
    // Button Enabled
    private var _enabled : Bool = true
    public var enabled     : Bool {
        set { _enabled = newValue
            if let btn = _itemButton {
                btn.enabled = _enabled
            }
        }
        get { return _enabled }
    }
    
    // Button Selected
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
    
    
    
    /** Button Title Color
     */
    private var _buttonColorNormal:UIColor      = PLMScrollMenuBar.kMenuBarButtonColorNormal
    private var _buttonColorDisabled:UIColor    = PLMScrollMenuBar.kMenuBarButtonColorDisabled
    private var _buttonColorSelected:UIColor    = PLMScrollMenuBar.kMenuBarButtonColorSelected
    
    public var buttonColorNormal:UIColor {
        set{_buttonColorNormal = newValue
            
            if let itemButton = _itemButton{
               itemButton.setTitleColor(_buttonColorNormal, forState: .Normal)
            }
        }
        get{return _buttonColorNormal}
    }
    
    public var buttonColorDisabled:UIColor {
        set{_buttonColorDisabled = newValue
            
            if let itemButton = _itemButton{
               itemButton.setTitleColor(_buttonColorDisabled, forState: .Disabled)
            }
        }
        
        get{
            return _buttonColorDisabled
        }
    }
    
    public var buttonColorSelected:UIColor {
        set{_buttonColorSelected = newValue
            
            if let itemButton = _itemButton{
                itemButton.setTitleColor(_buttonColorSelected, forState: .Selected)
            }
        }
        get{return _buttonColorSelected }
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
    public func button() -> PLMScrollMenuBarButton {
        
        if let itemButton = _itemButton {
            
            return itemButton
            
        } else {
            
            _itemButton = PLMScrollMenuBarButton.init(type: .Custom)
            
            if let itemButton = _itemButton
            {
                itemButton.tag = self.tag
                itemButton.frame = CGRectMake(0, 0, _width, 24)
                
                itemButton.titleLabel!.font = UIFont.systemFontOfSize(16.0)
                itemButton.setTitle(self.title, forState: .Normal)
                
                itemButton.setTitleColor(buttonColorNormal, forState: .Normal)
                itemButton.setTitleColor(buttonColorDisabled, forState: .Disabled)
                itemButton.setTitleColor(buttonColorSelected, forState: .Selected)
                
                itemButton.enabled = enabled
                itemButton.exclusiveTouch = false
                itemButton.sizeToFit()
            }
            
            return _itemButton
        }
        
    }
    
}
