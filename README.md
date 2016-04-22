# PLMScrollMenu

[![CI Status](http://img.shields.io/travis/tatsuhiro kanai/PLMScrollMenu.svg?style=flat)](https://travis-ci.org/tatsuhiro kanai/PLMScrollMenu)
[![Version](https://img.shields.io/cocoapods/v/PLMScrollMenu.svg?style=flat)](http://cocoapods.org/pods/PLMScrollMenu)
[![License](https://img.shields.io/cocoapods/l/PLMScrollMenu.svg?style=flat)](http://cocoapods.org/pods/PLMScrollMenu)
[![Platform](https://img.shields.io/cocoapods/p/PLMScrollMenu.svg?style=flat)](http://cocoapods.org/pods/PLMScrollMenu)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![](https://github.com/publickanai/PLMScrollMenu/blob/master/ReadmeImages/capture.gif)

Import PLMScrollMenu module.

```
import PLMScrollMenu
```


Define your view controller class with PLMScrollMenuViewController.

```
class YourViewController: PLMScrollMenuViewController {
```

Set ViewControllers.

```
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // setup
    
    let vc1 = UIViewController()
    vc1.view.backgroundColor = UIColor(red: 0.4, green: 0.8, blue: 1, alpha: 1)
    vc1.title = "First"

    let vc2 = UIViewController()
    vc2.view.backgroundColor = UIColor(red: 1, green: 0.4, blue: 0.8, alpha: 1)
    vc2.title = "Second"

    let vc3 = UIViewController()
    vc3.view.backgroundColor = UIColor(red: 1, green: 0.8, blue: 0.4, alpha: 1)
    vc3.title = "Third"
    
    // set ViewControllers
    self.setViewControllers([vc1, vc2 , vc3], animated: false)
}
```

## Requirements

## Installation

PLMScrollMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PLMScrollMenu"
```

## Author

tatsuhiro kanai, kanai.tatsuhiro@adways.net

## License

PLMScrollMenu is available under the MIT license. See the LICENSE file for more info.
