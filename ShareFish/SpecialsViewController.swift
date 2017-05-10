//
//  SpecialsViewController.swift
//  ShareFish
//
//  Created by John Malatras on 2/5/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import CoreLocation
import EventKit

class SpecialsViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var SpecialsTableView: UITableView!
    
    var specials = [PFObject]()
    var tempSpecials = [PFObject]()
    var sortedSpecials = [PFObject]()
    var barTitle : String!
    var valueToPass:String!
    var userGeoPoint: PFGeoPoint = PFGeoPoint()
    var selectedSpecialTitle : String!
    let locationManager = CLLocationManager()
    var currentLocation : CLLocationCoordinate2D!
    var selectedBar : PFObject!
    var tracker = GAI.sharedInstance().defaultTracker
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            if CLLocationManager.authorizationStatus() == .NotDetermined || CLLocationManager.authorizationStatus() == .Restricted || CLLocationManager.authorizationStatus() == .Denied {
                let alertController = UIAlertController(title: "Location Not Enabled", message: "Please enable location services to view specials in your area!", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        } else {
            let alertController = UIAlertController(title: "Location Not Enabled", message: "Please enable location services to view specials in your area!", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        currentLocation = CLLocationCoordinate2D(latitude: userGeoPoint.latitude, longitude: userGeoPoint.longitude)
        if currentLocation.latitude != 0 && currentLocation.longitude != 0{
            queryandAnno(currentLocation)
            switch segmentedControl.selectedSegmentIndex
            {
            case 0:
                sortedSpecials = specials
            case 1:
                sortedSpecials = filterByEmoji(0)
            case 2:
                sortedSpecials = filterByEmoji(1)
            case 3:
                sortedSpecials = filterByEmoji(2)
            default:
                sortedSpecials = specials
            }
            self.SpecialsTableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedSpecials.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedSpecialTitle = self.sortedSpecials[indexPath.row]["Title"] as! String
        
        let barPointer = self.sortedSpecials[indexPath.row]["Merchant"] as! PFObject
        do{
            try barPointer.fetchIfNeeded()
            selectedBar = barPointer
        } catch _ {
            
        }
        
        let eventTracker: NSObject = GAIDictionaryBuilder.createEventWithCategory(
            "SpecialClicked",
            action: selectedBar["Name"] as! String,
            label: selectedSpecialTitle,
            value: nil).build()
        tracker.send(eventTracker as! [NSObject : AnyObject])
        
        performSegueWithIdentifier("toMerchant", sender: self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as! SpecialsCell
        
        let special = sortedSpecials[indexPath.row]
        let barName = special.objectForKey("BarName") as! String
        let specialName = special.objectForKey("Title") as! String
        var priceString = ""
        
        cell.setBarName(barName)
        cell.setSpecialName(specialName)
        
        if let priceType = special["CurType"] as? String {
            switch priceType {
                
            case "$":
                let price = special.objectForKey("Price") as! Double
                priceString = String(format: "$%.2f", price)
            case "%":
                priceString = "\(Int(special["Price"] as! Double))% off"
            default:
                let price = special.objectForKey("Price") as! Double
                priceString = String(format: "$%.2f", price)
            }
        }
        else {
            let price = special.objectForKey("Price") as! Double
            priceString = String(format: "$%.2f", price)
        }
        
        cell.setPriceCost(priceString)
        let emojiInt = special.objectForKey("EmojiVar") as! Int
        
        cell.setEmojiText(emojiInt)
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let dimensions = [
            "Bar Name" : self.selectedBar["Name"] as! String,
            "Special" : self.selectedSpecialTitle!
        ]
        
        PFAnalytics.trackEvent("specialClicked", dimensions: dimensions)
        
        if "toMerchant" == segue.identifier {
            let svc = segue.destinationViewController as! MerchantMainViewController
            svc.theBar = self.selectedBar
            svc.distanceAway = self.userGeoPoint.distanceInMilesTo(selectedBar["Location"] as? PFGeoPoint)
        }
        
    }
    
    func getDayOfWeek(today:String)->Int {
        
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.dateFromString(today)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        queryandAnno(locValue)
        self.locationManager.stopUpdatingLocation()
    }
    
    func queryandAnno(locValue:CLLocationCoordinate2D){
        
        var datesPre : String!
        
        let currentDate = NSDate()
        let calculatedDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: -4, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let specialsDate = dateFormatter.stringFromDate(calculatedDate!)
        
        
        if(getDayOfWeek(specialsDate) == 1) {
            datesPre = "Sun"
        }
        else if(getDayOfWeek(specialsDate) == 2) {
            datesPre = "Mon"
        }
        else if(getDayOfWeek(specialsDate) == 3) {
            datesPre = "Tue"
        }
        else if(getDayOfWeek(specialsDate) == 4) {
            datesPre = "Wed"
        }
        else if(getDayOfWeek(specialsDate) == 5) {
            datesPre = "Thu"
        }
        else if(getDayOfWeek(specialsDate) == 6) {
            datesPre = "Fri"
        }
        else if(getDayOfWeek(specialsDate) == 7) {
            datesPre = "Sat"
        }
        else {
            datesPre = "Error"
        }
        
        let predicate = NSPredicate(format: "Dates = '\(datesPre)'")
        
        let query = PFQuery(className: "Specials", predicate: predicate)
        userGeoPoint = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        query.whereKey("Location", nearGeoPoint:userGeoPoint, withinMiles: 8)
        query.orderByAscending("Price")
        do {
            self.tempSpecials = try query.findObjects()
        } catch _ {
        }
        
        specials = [PFObject]()
        specials = tempSpecials
        
        
        if specials.isEmpty
        {
            let alertController = UIAlertController(title: "No Specials Found", message: "We didn't find any specials in your area today", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        sortedSpecials = specials
        self.SpecialsTableView.reloadData()
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            self.sortedSpecials = specials
        case 1:
            self.sortedSpecials = filterByEmoji(0)
        case 2:
            self.sortedSpecials = filterByEmoji(1)
        case 3:
            self.sortedSpecials = filterByEmoji(2)
        default:
            break; 
        }
        self.SpecialsTableView.reloadData()
    }
    
    
    func filterByEmoji(emojiCode: Int) -> [PFObject]{
        var results = [PFObject]()
        for special in self.specials{
            let specialEmoji = special["EmojiVar"] as! Int
            if specialEmoji == emojiCode{
                results.append(special)
            }
        }
        return results
    }
    
    
}