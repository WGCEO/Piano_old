//
//  AppDelegate.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 17..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        guard let window = window, let splitViewController = window.rootViewController as? UISplitViewController else {
            return true
        }
        
        PianoData.deleteMemosIfPassOneMonth()
        
        let navigationController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = navigationController.topViewController as! DetailViewController
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        splitViewController.preferredDisplayMode = .allVisible
        

        splitViewController.minimumPrimaryColumnWidth = 375
        splitViewController.maximumPrimaryColumnWidth = 375
        splitViewController.delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        PianoData.coreDataStack.saveDisplayMemo()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
//        return false
//    }
//
//    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
//        //TODO: 앱 업데이트 체크하고 업데이트 되었으면 우선 리스토어 하지 말아야 함(상태값 체크 후에 true반환해야함)
//        return false
//    }
//    
//    func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
//        //여기서 버전 정보를 적거나 앱의 설정값을 세팅할 수 있다.
//    }
//    
//    func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
//        
//        isRestoreState = true
//        //willEncode에서 저장한 데이터(설정값들)를 여기서 읽을 수 있다.
//    }

//    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
//        //restoration class 없는 뷰 컨트롤러를 UIKit이 맞닥뜨렸을 때 이 메서드를 호출한다.
//    }
}

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

