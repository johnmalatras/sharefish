//
//  NearMeListViewController.swift
//  ShareFish
//
//  Created by John Malatras on 1/29/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation

class NearMeListViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var NearMeTableView: UITableView!
    var userGeoPoint: PFGeoPoint = PFGeoPoint()
    
    let locationManager = CLLocationManager()
    var locations = [[PFObject]]()
    var selectedBar : PFObject!
    var currentLocation : CLLocationCoordinate2D!
    var datesPre : Int!
    
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
        
        let currentDate = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let specialsDate = dateFormatter.stringFromDate(currentDate)
        
        
        if(getDayOfWeek(specialsDate) == 1) {
            datesPre = 0
        }
        else if(getDayOfWeek(specialsDate) == 2) {
            datesPre = 1
        }
        else if(getDayOfWeek(specialsDate) == 3) {
            datesPre = 2
        }
        else if(getDayOfWeek(specialsDate) == 4) {
            datesPre = 3
        }
        else if(getDayOfWeek(specialsDate) == 5) {
            datesPre = 4
        }
        else if(getDayOfWeek(specialsDate) == 6) {
            datesPre = 5
        }
        else {
            datesPre = 6
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        currentLocation = CLLocationCoordinate2D(latitude: userGeoPoint.latitude, longitude: userGeoPoint.longitude)
        if currentLocation.latitude != 0 && currentLocation.longitude != 0{
            queryandAnno(currentLocation)
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "ShareFish Supported Venues"
        } else {
            return "Unaffiliated Venues"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locations.count == 2 {
            if section == 0{
                return self.locations[0].count
            } else {
                return self.locations[1].count
            }
        } else {
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var location : PFObject
        
        location = locations[indexPath.section][indexPath.row]
        
        let locationName = location["Name"] as! String
        let distanceBtwn = self.userGeoPoint.distanceInMilesTo(location["Location"] as? PFGeoPoint)
        let img = location["Image"] as! PFFile
        
        let today = (location["Daily"] as! [[String]])[datesPre][0]
        let open = isOpen(today)
        
        if indexPath.section == 0 {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as! NearMeCell
            
            let males = location["Males"] as! Double
            let females = location["Females"] as! Double
            let totalPpl = males + females
            var guyToGirlRtio : Double
            
            if (males == 0 && females == 0) || totalPpl < 3 {
                guyToGirlRtio = 50
            }
            else if(males == 0){
                guyToGirlRtio = 15
            }
            else if(females == 0){
                guyToGirlRtio = 85
            }
            else{
                guyToGirlRtio = (males/totalPpl) * 100
            }
            
            var ratioImg : UIImage!
            
            switch guyToGirlRtio{
            case 0...18.75:
                ratioImg = UIImage(named: "ratio_12_5.png")
            case 18.75...31.25:
                ratioImg = UIImage(named: "ratio_25.png")
            case 31.25...43.75:
                ratioImg = UIImage(named: "ratio_37_5.png")
            case 43.75...56.25:
                ratioImg = UIImage(named: "ratio_50.png")
            case 56.25...68.75:
                ratioImg = UIImage(named: "ratio_67_5.png")
            case 68.75...81.25:
                ratioImg = UIImage(named: "ratio_75.png")
            case 81.25...100:
                ratioImg = UIImage(named: "ratio_87_5.png")
            default:
                ratioImg = UIImage(named: "ratio_50.png")
            }

            
            let averageAge = location["Avg_Age"] as! Double
            var ageImg : UIImage!
            var ageString : String
            
            switch averageAge
            {
            case 0...23:
                ageString = "21-23"
                ageImg = UIImage(named: "nAge 7.png")
            case 23...26:
                ageString = "23-26"
                ageImg = UIImage(named: "nAge 6.png")
            case 26...30:
                ageString = "26-30"
                ageImg = UIImage(named: "nAge 5.png")
            case 30...34:
                ageString = "30-34"
                ageImg = UIImage(named: "nAge 4.png")
            case 34...39:
                ageString = "34-39"
                ageImg = UIImage(named: "nAge 3.png")
            case 40...45:
                ageString = "40-45"
                ageImg = UIImage(named: "nAge 2.png")
            case _ where averageAge > 45:
                ageString = "45+"
                ageImg = UIImage(named: "nAge 1.png")
            default:
                ageString = "21-23"
                ageImg = UIImage(named: "nAge 7.png")
            }
            
            cell.setImgView(img, open: open)
            cell.setNameLbl(locationName)
            cell.setDistanceLbl(distanceBtwn)
            cell.setAgeLbl(ageString)
            cell.setAgeImgView(ageImg)
            cell.setGenderImgView(ratioImg)
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NearMeFreeCell", forIndexPath: indexPath) as! NearMeFreeCell
            
            cell.setImgView(img, open: open)
            cell.setNameLbl(locationName)
            cell.setDistanceLbl(distanceBtwn)
            
            // Assign the tap action which will be executed when the user taps the UIButton
            cell.tapAction = { (cell) in
                self.showAlertForRow(location)
            }
            
            return cell
        }
    }
    
    func showAlertForRow(location: PFObject)->Void{
        let alertController = UIAlertController(title: "Request Sent", message: "We'll let \(location["Name"] as! String) know that you want to see them with full ShareFish features!", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Cool", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        location["Requests"] = (location["Requests"] as! Int) + 1
        
        do{
            try location.save()
        } catch _ {}
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let clickedMerchant = locations[indexPath.section][indexPath.row]
        do{
            try clickedMerchant.fetchIfNeeded()
            self.selectedBar = clickedMerchant
        } catch _ {}
        performSegueWithIdentifier("NearMetoMerchant", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if "NearMetoMerchant" == segue.identifier {
            let svc = segue.destinationViewController as! MerchantMainViewController
            svc.theBar = selectedBar
            svc.distanceAway = self.userGeoPoint.distanceInMilesTo(selectedBar["Location"] as? PFGeoPoint)
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        queryandAnno(locValue)
        self.locationManager.stopUpdatingLocation()
    }
    
    func queryandAnno(locValue:CLLocationCoordinate2D){
        let predicate = NSPredicate(format: "is_approved = 'yes'")
        let query = PFQuery(className: "Locations", predicate: predicate)
        userGeoPoint = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        query.whereKey("Location", nearGeoPoint:userGeoPoint, withinMiles: 8)
        query.selectKeys(["Name", "Location", "Males", "Females", "Avg_Age", "Image", "Premium", "Requests", "Daily"])
        var tempLocations = [PFObject]()
        do {
            tempLocations = try query.findObjects()
        } catch _ {
        }
        
        locations = [[PFObject]]()
        
        locations.append([PFObject]())
        locations.append([PFObject]())
        
        for location in tempLocations {
            if location["Premium"] as! Bool == true {
                locations[0].append(location)
            } else {
                locations[1].append(location)
            }
        }
        
        if locations[0].isEmpty && locations[1].isEmpty
        {
            let alertController = UIAlertController(title: "No Venues Found", message: "Looks like there are no ShareFish Partners in your area yet. Visit our site to be the first to bring ShareFish here!", preferredStyle: .Alert)
            
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            let websiteAction = UIAlertAction(title: "Open sharefishapp.com", style: UIAlertActionStyle.Default){(ACTION) in
                    UIApplication.sharedApplication().openURL(NSURL(string: "https://sharefishapp.com/")!)
                }
            alertController.addAction(websiteAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        self.NearMeTableView.reloadData()
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
    
    func isOpen(hours: String)->Bool{
        let index = hours.characters.indexOf("-")
        
        let openingHoursStringTemp = hours.substringToIndex(index!)
        let closingHoursStringTemp = hours.substringFromIndex(index!.advancedBy(1))
        let openingHoursString = openingHoursStringTemp.substringToIndex(openingHoursStringTemp.endIndex.advancedBy(-2))
        let closingHoursString = closingHoursStringTemp.substringToIndex(closingHoursStringTemp.endIndex.advancedBy(-2))
        var openingHour = Int(openingHoursString)!
        var closingHour = Int(closingHoursString)!

        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        let openingComponents = calendar.components([ .Year, .Month, .Day, .Hour], fromDate: currentDate)
        let closingComponents = calendar.components([ .Year, .Month, .Day, .Hour], fromDate: currentDate)
        
        if openingHoursStringTemp.containsString("pm") {
            openingHour += 12
        }
        
        if closingHoursStringTemp.containsString("pm") && closingHour != 12 {
            closingHour += 12
        } else if closingHoursStringTemp.containsString("am"){
            closingComponents.day += 1
        }
        
        openingComponents.hour = openingHour
        openingComponents.minute = 0
        openingComponents.second = 0
        let openingDate = calendar.dateFromComponents(openingComponents)!
        
        closingComponents.hour = closingHour
        closingComponents.minute = 0
        closingComponents.second = 0
        let closingDate = calendar.dateFromComponents(closingComponents)!
        
        if currentDate.timeIntervalSince1970 >= openingDate.timeIntervalSince1970 && currentDate.timeIntervalSince1970 <= closingDate.timeIntervalSince1970 {
            return true
        }
        
        return false
    }

}

func indexOf(source: String, substring: String) -> Int? {
    let maxIndex = source.characters.count - substring.characters.count
    for index in 0...maxIndex {
        let rangeSubstring = source.startIndex.advancedBy(index)..<source.startIndex.advancedBy(index + substring.characters.count)
        if source.substringWithRange(rangeSubstring) == substring {
            return index
        }
    }
    return nil
}

extension String {
    func indexOf(string: String) -> String.Index? {
        return rangeOfString(string, options: .LiteralSearch, range: nil, locale: nil)?.startIndex
    }
}
