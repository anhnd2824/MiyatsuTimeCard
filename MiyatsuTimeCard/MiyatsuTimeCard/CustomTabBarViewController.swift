//
//  CustomTabBarViewController.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/24/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        for item in (tabBar.items)!{
//            item.image = item.image?.withRenderingMode(.alwaysOriginal)
//        }
        //Makes the selected tabBarItem gray
//        tabBar.tintColor = nil
        //Renders the Unselected title purple as of the icon
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 121/255, green: 43/255, blue: 157/255, alpha: 1)], for:.normal)
//        Renders the selected title same as tint Color
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gray], for:.selected)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
