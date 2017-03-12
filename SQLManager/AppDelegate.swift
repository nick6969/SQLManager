//
//  AppDelegate.swift
//  SQLManager
//
//  Created by nickLin on 03/12/2017.
//  Copyright © 2017年 nickLin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // you can create New DB or open DB in here
        DBM.createDB()
        
        return true
    }


    
    func applicationWillTerminate(_ application: UIApplication) {

        // remeber closeDB in here
        DBM.closeDB()
        
    }


}

