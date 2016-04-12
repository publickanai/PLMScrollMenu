//
//  ViewController.swift
//  PLMScrollMenu
//
//  Created by tatsuhiro kanai on 03/31/2016.
//  Copyright (c) 2016 tatsuhiro kanai. All rights reserved.
//

import UIKit
import PLMScrollMenu

class ViewController: PLMScrollMenuViewController ,PLMScrollMenuViewControllerDelegate
{
    var vcArr : NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    func setup() {
        
        var label : UILabel
        
        // vc data
        let vc1 = UIViewController()
        vc1.view.backgroundColor = UIColor(red: 0.4, green: 0.8, blue: 1, alpha: 1)
        vc1.title = "１１１１１"
        
        label = UILabel.init()
        label.textColor = UIColor.whiteColor()
        label.text = "１１１"
        label.sizeToFit()
        label.center = vc1.view.center
        vc1.view.addSubview(label)
        
        let vc2 = UIViewController()
        vc2.view.backgroundColor = UIColor(red: 1, green: 0.4, blue: 0.8, alpha: 1)
        vc2.title = "２２２２２"
        
        label = UILabel.init()
        label.textColor = UIColor.whiteColor()
        label.text = "２２２"
        label.sizeToFit()
        label.center = vc2.view.center
        vc2.view.addSubview(label)
        
        let vc3 = UIViewController()
        vc3.view.backgroundColor = UIColor(red: 1, green: 0.8, blue: 0.4, alpha: 1)
        vc3.title = "３３３３３"
        
        label = UILabel.init()
        label.textColor = UIColor.whiteColor()
        label.text = "３３３"
        label.sizeToFit()
        label.center = vc3.view.center
        vc3.view.addSubview(label)
        
        let vc4 = UIViewController()
        vc4.view.backgroundColor = UIColor.orangeColor()
        vc4.title = "４４４４４"
        
        label = UILabel.init()
        label.textColor = UIColor.whiteColor()
        label.text = "４４４"
        label.sizeToFit()
        label.center = vc4.view.center
        vc4.view.addSubview(label)
        
        let vc5 = UIViewController()
        vc5.view.backgroundColor = UIColor.yellowColor()
        vc5.title = "５５５５５"
        
        label = UILabel.init()
        label.textColor = UIColor.whiteColor()
        label.text = "５５５"
        label.sizeToFit()
        label.center = vc5.view.center
        vc5.view.addSubview(label)
        
        let vc6 = UIViewController()
        vc6.view.backgroundColor = UIColor.purpleColor()
        vc6.title = "６６６６６"
        
        label = UILabel.init()
        label.textColor = UIColor.whiteColor()
        label.text = "６６６"
        label.sizeToFit()
        label.center = vc6.view.center
        vc6.view.addSubview(label)
        
        // vc datas
        self.vcArr = [vc1, vc2 , vc3, vc4 , vc5 , vc6]
        
        self.menuBarY = 20
        
        // set Style
        self.menuBar.style = PLMScrollMenuBarStyle.InfinitePaging
        
        // set MenuBarInset
        self.menuItemInsets = UIEdgeInsetsMake(0, 30, 0, 30)
        
        //
        self.menuBar.setIndicatorColor(UIColor.magentaColor())
        
        // set delegate
        //self.delegate = self
        
        // set ViewControllers
        self.viewControllers = vcArr
        
        
    }
    
    //
    // MARK: - PLMScrollMenuViewControllerDelegate
    
    func menuBarController( menuBarController: PLMScrollMenuViewController, willSelectViewController: UIViewController?)
    {
        //print("Main ViewController willSelectViewController")
    }
    
    func menuBarController( menuBarController: PLMScrollMenuViewController, didSelectViewController: UIViewController?)
    {
        //print("Main ViewController didSelectViewController")
    }
    
    func menuBarController( menuBarController: PLMScrollMenuViewController, didCancelViewController: UIViewController?)
    {
        //print("Main ViewController didCancelViewController")
    }
    
    
    func menuBarController( menuBarController: PLMScrollMenuViewController, menuBarItemAtIndex: NSInteger) -> (PLMScrollMenuBarItem)
    {
        // Create MenuBarItem 
        let vc:UIViewController = vcArr[menuBarItemAtIndex] as! UIViewController
        let item = PLMScrollMenuBarItem.item()
        item.title = vc.title!
        item.buttonColorSelected = vc.view.backgroundColor!
        item.tag = menuBarItemAtIndex
        
        return item
    }
    
}

