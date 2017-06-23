//
//  ViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/7.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Customize Tab Bar Styles
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor(hex: Color.Tab.normalText)
        } else {
            // Fallback on earlier versions
        }
        self.tabBar.tintColor = UIColor(hex: Color.Tab.highlightedText)
        self.tabBar.barTintColor = UIColor(hex: Color.Tab.background)
        self.tabBar.backgroundImage = UIImage.colorForNavBar(color: UIColor(hex: Color.Tab.background))
        self.tabBar.shadowImage = UIImage.colorForNavBar(color: UIColor(hex: Color.Tab.border))
        self.tabBar.isTranslucent = false
        
        // MARK: Replace unselected tab icons with original icon
        if let items = self.tabBar.items {
            let tabBarImages = getTabBarImages()
            for i in 0..<items.count {
                let tabBarItem = items[i]
                let tabBarImage = tabBarImages[i]
                tabBarItem.image = tabBarImage?.withRenderingMode(.alwaysOriginal)
            }
        }

    }
    
    
    func getTabBarImages() -> [UIImage?] {
        let imageNames = ["NewsDim", "EnglishDim", "AcademyDim", "VideoDim", "MyFTDim"]
        let images = imageNames.map { (value: String) -> UIImage? in
            return UIImage(named: value)
        }
        return images
    }
    
    
    // MARK: On mobile phone, lock the screen to portrait only
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.all
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override var shouldAutorotate : Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else {
            return false
        }
    }
    
    
}
