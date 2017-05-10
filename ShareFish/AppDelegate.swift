//
//  AppDelegate.swift
//  ShareFish
//
//  Created by Stevie Thompson Jr. on 10/9/15.
//  Copyright © 2015 ShareFish LLC. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKCoreKit
import ParseFacebookUtilsV4
import CoreLocation
import UberRides
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(uuidString:"4B0579F9-635D-4557-9223-FB334989EA11")! as UUID, identifier: "Sharefish Beacons")
    var major = NSNumber()
    var minor = NSNumber()
    var oldMajor = 0 as NSNumber
    var oldMinor = 0 as NSNumber

    
    var lastFireTime = NSDate()
    
    var tracker = GAI.sharedInstance().defaultTracker
    //var locationsArray = [PFObject]()
    

    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().tintColor = UIColor(red: CGFloat(51/255.0), green: CGFloat(197/255.0), blue: CGFloat(244/255.0), alpha: CGFloat(1.0))
        UITabBar.appearance().barTintColor = UIColor.white
        //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.lightGrayColor()], forState: UIControlState.Normal)
        
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios/guide#local-datastore
        //Parse.enableLocalDatastore()
        UINavigationBar.appearance().barTintColor = UIColor(red: CGFloat(51/255.0), green: CGFloat(197/255.0), blue: CGFloat(244/255.0), alpha: CGFloat(1.0))
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().tintColor = UIColor.white
        
        // Set Notifications for users
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        // Initialize Parse.
        Parse.setApplicationId("F1GaqG1P1uO2Vwg1FnT0hlGMF2FgDYaUvHhbFuxJ",
            clientKey: "am1uxMlQCEX3VmTZUZDKhtye3VjB4QytmKZJlDa1")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        //Google Analytics
        GAI.sharedInstance().tracker(withTrackingId: "UA-73721514-1")
        
        
        //Beacon Location Manager
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        //locationManager.requestWhenInUseAuthorization()
        beaconRegion.notifyOnEntry = true;
        beaconRegion.notifyOnExit = true;
        beaconRegion.notifyEntryStateOnDisplay=true;
        self.locationManager.startMonitoring(for: beaconRegion)
        
        let currentUser = PFUser.current()
        
        if currentUser != nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            self.window?.rootViewController = tabViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    
    
    func locationManager(_ locationManager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        self.locationManager.requestState(for: region)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion)
    {
        //This calls the didEnterRegion
    }
    
    
    
    func locationManager(_ manager: CLLocationManager,
        didEnterRegion region: CLRegion)
    {
        self.locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    
    
    
    func locationManager(_ locationManager: CLLocationManager, didExitRegion region: CLRegion)
    {
        self.locationManager.stopRangingBeacons(in: beaconRegion)
        
        if PFUser.current() != nil
        {
            let user = PFUser.current()
            let gender = user!["Gender"] as! Int
            if (gender == 0)
            {
                //Parse stuff for girls
                //Figure out which bar they just entered
                //Store their gender to that bar
                let query = PFQuery(className: "Locations")
                query.whereKey("Major", equalTo: major)
                query.whereKey("Minor", equalTo: minor)
                
                do{
                    let locationsArray = try query.findObjects()
                    let location = locationsArray.first! as PFObject
                    var femaleCount = location["Females"] as! Int
                    femaleCount = femaleCount - 1
                    location["Females"] = femaleCount
                    
                    let rStatus = user!["Relationship"] as! Int
                    if rStatus == 0{
                        var singleCount = location["Singles"] as! Int
                        singleCount -= 1
                        location["Singles"] = singleCount
                    }

                    do{
                        try  location.save()
                    }
                    catch
                    {
                    }
                }
                catch
                {}
            
                
                let declineAction = UIMutableUserNotificationAction()
                declineAction.identifier = "DeclineUber"
                declineAction.title = "✖️"
                declineAction.activationMode = UIUserNotificationActivationMode.foreground
                declineAction.isAuthenticationRequired = true
                declineAction.isDestructive = true
                
                let uberAction = UIMutableUserNotificationAction()
                uberAction.identifier = "AcceptUber"
                uberAction.title = "✅"
                uberAction.activationMode = UIUserNotificationActivationMode.foreground
                uberAction.isAuthenticationRequired = true
                uberAction.isDestructive = false
                
                let uberCategory = UIMutableUserNotificationCategory()
                
                let actionArray = NSArray(objects: declineAction, uberAction)
                
                uberCategory.identifier = "uberCategory"
                uberCategory.setActions(actionArray as? [UIUserNotificationAction], for: UIUserNotificationActionContext.default)
                
                let settings = UIUserNotificationSettings(types: [.alert], categories: NSSet(object: uberCategory) as? Set<UIUserNotificationCategory>)
                
                UIApplication.shared.registerUserNotificationSettings(settings)
                
                
                let notification = UILocalNotification()
                notification.alertBody = "Thanks for coming by! Get home safe, swipe here to order an Uber."
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.category = "uberCategory"
                
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
                
            else if (gender == 1)
            {
                //Parse stuff for guys
                //Figure out which bar they just entered
                //Store their gender to that bar
                let query = PFQuery(className: "Locations")
                query.whereKey("Major", equalTo: major)
                query.whereKey("Minor", equalTo: minor)
                
                do{
                    let locationsArray = try query.findObjects()
                    let location = locationsArray.first! as PFObject
                    var maleCount = location["Males"] as! Int
                    maleCount = maleCount - 1
                    location["Males"] = maleCount
                    
                    let rStatus = user!["Relationship"] as! Int
                    if rStatus == 0{
                        var singleCount = location["Singles"] as! Int
                        singleCount -= 1
                        location["Singles"] = singleCount
                    }

                    do{
                        try  location.save()
                    }
                    catch
                    {
                    }
                }
                catch
                {}
                
                let beaconEnterNotification = UILocalNotification()
                beaconEnterNotification.alertBody = "Headed out?"
                beaconEnterNotification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.presentLocalNotificationNow(beaconEnterNotification)
                
                let declineAction = UIMutableUserNotificationAction()
                declineAction.identifier = "DeclineUber"
                declineAction.title = "✖️"
                declineAction.activationMode = UIUserNotificationActivationMode.foreground
                declineAction.isAuthenticationRequired = true
                declineAction.isDestructive = true
                
                let uberAction = UIMutableUserNotificationAction()
                uberAction.identifier = "AcceptUber"
                uberAction.title = "✅"
                uberAction.activationMode = UIUserNotificationActivationMode.foreground
                uberAction.isAuthenticationRequired = true
                uberAction.isDestructive = false
                
                let uberCategory = UIMutableUserNotificationCategory()
                
                let actionArray = NSArray(objects: declineAction, uberAction)
                
                uberCategory.identifier = "uberCategory"
                uberCategory.setActions(actionArray as? [UIUserNotificationAction], for: UIUserNotificationActionContext.default)
                
                let settings = UIUserNotificationSettings(types: [.alert], categories: NSSet(object: uberCategory) as? Set<UIUserNotificationCategory>)
                
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                
                let notification = UILocalNotification()
                notification.alertBody = "Thanks for coming by! Get home safe, swipe here to order an Uber."
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.category = "uberCategory"
                
                UIApplication.shared.presentLocalNotificationNow(notification)
                
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        self.locationManager.stopRangingBeacons(in: beaconRegion)
        
        let elapsedTime = NSDate().timeIntervalSince(lastFireTime as Date)
        let duration = Int(elapsedTime)
        lastFireTime = NSDate()
        
        //Add stuff for male female ratios here
        if (PFUser.current() != nil && duration > 5)
        {
            
            let user = PFUser.current()
            let gender = user!["Gender"] as! Int
            let firstBeacon = beacons[0]
            major = firstBeacon.major
            minor = firstBeacon.minor
            let query = PFQuery(className: "Locations")
            query.whereKey("Major", equalTo: major)
            query.whereKey("Minor", equalTo: minor)
            
            do{
                if gender == 0
                {
                    let locationsArray = try query.findObjects()
                    let location = locationsArray.first
                    var femaleCount = location!["Females"] as! Int
                    femaleCount = femaleCount + 1
                    location!["Females"] = femaleCount
                    
                    let beaconEnterNotification = UILocalNotification()
                    beaconEnterNotification.alertBody = "Welcome to " + (location!["Name"] as! String) + ". Click this banner to see the specials!"
                    beaconEnterNotification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.shared.presentLocalNotificationNow(beaconEnterNotification)
                    
                    let rStatus = user!["Relationship"] as! Int
                    if rStatus == 0{
                        var singleCount = location!["Singles"] as! Int
                        singleCount += 1
                        location!["Singles"] = singleCount
                    }
                    let avgAge = location!["Avg_Age"] as! Double
                    if let userAge = user!["age"] as? Double{
                        let newAge = (avgAge + userAge)/2
                        location!["Avg_Age"] = newAge
                    }
                    
                    do{
                        try  location!.save()
                    }
                    catch
                    {
                    }
                    
                    let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
                        withCategory: "FemaleExited",
                                            action: location!["Name"] as! String,
                                            label: String(describing: lastFireTime),
                                            value: nil).build()
                                        tracker?.send(eventTracker as! [NSObject : AnyObject])
                    
                }
                else if gender == 1
                {
                    let locationsArray = try query.findObjects()
                    let location = locationsArray.first
                    var maleCount = location!["Males"] as! Int
                    maleCount = maleCount + 1
                    location!["Males"] = maleCount
                    
                    let beaconEnterNotification = UILocalNotification()
                    beaconEnterNotification.alertBody = "Welcome to " + (location!["Name"] as! String) + ". Click this banner to see the specials!"
                    beaconEnterNotification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.shared.presentLocalNotificationNow(beaconEnterNotification)
                    
                    let rStatus = user!["Relationship"] as! Int
                    if rStatus == 0{
                        var singleCount = location!["Singles"] as! Int
                        singleCount += 1
                        location!["Singles"] = singleCount
                    }
                    let avgAge = location!["Avg_Age"] as! Double
                    if let userAge = user!["age"] as? Double{
                        let newAge = (avgAge + userAge)/2
                        location!["Avg_Age"] = newAge
                    }

                    do{
                        try  location!.save()
                    }
                    catch
                    {
                    }
                    
                    let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
                        withCategory: "MaleExited",
                        action: location!["Name"] as! String,
                        label: String(describing: lastFireTime),
                        value: nil).build()
                    tracker?.send(eventTracker as! [NSObject : AnyObject])
                }
            }
            catch
            {
            }
        }
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
  

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //Register for remote notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation.setDeviceTokenFrom(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handle(userInfo)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
        if identifier == "AcceptUber" {
            if UIApplication.shared.canOpenURL(NSURL(string: "uber://")! as URL) {
                                UIApplication.shared.openURL(NSURL(string: "uber://?action=setPickup&pickup=my_location")! as URL)
                            } else {
                                UIApplication.shared.openURL(NSURL(string: "https://uber.com/")! as URL)
                            }

        }
        else if identifier == "DeclineUber" {
        }
        
        completionHandler()
    }
}

