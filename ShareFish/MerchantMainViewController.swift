//
//  MerchantMainViewController.swift
//  ShareFish
//
//  Created by John Malatras on 3/26/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation
import MapKit
import ParseUI

class MerchantMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var MerchantTopTableView: UITableView!
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var MerchantImageView: PFImageView!
    @IBOutlet weak var DescLabel: UILabel!
    @IBOutlet weak var AddressButton: UIButton!
    @IBOutlet weak var PhoneButton: UIButton!
    @IBOutlet weak var WebButton: UIButton!
    @IBOutlet weak var RatingImageView: UIImageView!
    
    
    var section : [String] = [String]()
    var items : [[(String, Double, Int)]] = [[(String, Double, Int)]]()
    var barName : String!
    var theBar : PFObject!
    var distanceString : String!
    var distanceAway : Double!
    var ageString : String!
    var singleInt : Int!
    var ratioImg : UIImage!
    var ratingImg : UIImage!
    var ageImg : UIImage!
    var hours: String!
    var notes: String!
    var specials : [PFObject] = [PFObject]()
    var itemsDict: [String:[(String, Double, Int)]] = [String:[(String, Double, Int)]]()
    var dayItem : [[String]]!
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var premium : Bool = true
    
    @IBAction func AddressClicked(sender: UIButton) {
        let latitute:CLLocationDegrees =  (theBar["Location"] as! PFGeoPoint).latitude
        let longitute:CLLocationDegrees =  (theBar["Location"]as! PFGeoPoint).longitude
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.barName)"
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    @IBAction func PhoneClicked(sender: UIButton) {
        var phoneNumberString = NSString(string: (sender.titleLabel?.text)!)
        phoneNumberString = phoneNumberString.substringWithRange(NSRange(location: 0, length: 3)) + phoneNumberString.substringWithRange(NSRange(location: 4, length: 3)) + phoneNumberString.substringWithRange(NSRange(location: 8, length: 4))
        
        if let CallURL:NSURL = NSURL(string:"tel://\(phoneNumberString)"){
            let application : UIApplication = UIApplication.sharedApplication()
            if(application.canOpenURL(CallURL)){
                application.openURL(CallURL)
            }
            else{
                let alertController = UIAlertController(title: "Something's Up", message: "Sorry! couldn't call \(barName) for some reason", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    @IBAction func WebClicked(sender: UIButton) {
        var webAddress = (sender.titleLabel?.text!)!
        if !(webAddress.containsString("http")){
            webAddress = "http://" + webAddress
        }
        if let checkURL = NSURL(string: webAddress) {
            UIApplication.sharedApplication().openURL(checkURL)
            
        } else {
            let alertController = UIAlertController(title: "Something's Up", message: "Sorry! couldn't find \(barName)'s website", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func UberClicked(sender: AnyObject) {
        
        let lat = Float((theBar["Location"] as! PFGeoPoint).latitude)
        let long = Float((theBar["Location"] as! PFGeoPoint).longitude)
        let latString = String(lat)
        let longString = String(long)
        
        let urlAddress = (theBar["Address"] as! String).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        
        //Need Latitude, longitude and address
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "uber://")!) {
            UIApplication.sharedApplication().openURL(NSURL(string:"uber://?client_id=X8eAh4dSP62-TDxsW9w7Q4G9Wixh6bdA&action=setPickup&pickup=my_location&dropoff[latitude]=" + latString + "&dropoff[longitude]=" + longString + "&dropoff[formatted_address]=" + urlAddress)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/uber/id368677368?mt=8")!)
        }
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
        MerchantTopTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.barName = self.theBar["Name"] as! String
        distanceString = "\(round(distanceAway * 10)/10) mi away"
        
        let image = theBar["Image"] as! PFFile
        self.MerchantImageView.layer.borderWidth = 2
        self.MerchantImageView.layer.borderColor = UIColor.blackColor().CGColor
        self.MerchantImageView.layer.cornerRadius = self.MerchantImageView.frame.height/2.033
        self.MerchantImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.MerchantImageView.clipsToBounds = true
        self.MerchantImageView.file = image
        self.MerchantImageView.loadInBackground()
        self.MerchantImageView.sizeToFit()
        
        NameLabel.text = self.barName
        DistanceLabel.text = distanceString
        DescLabel.text = theBar["Description"] as? String
        AddressButton.setTitle(theBar["Address"] as? String, forState: .Normal)
        PhoneButton.setTitle(theBar["Phone"] as? String, forState: .Normal)
        WebButton.setTitle(theBar["Website_Address"] as? String, forState: .Normal)
        
        if theBar["Premium"] as! Bool == false {
            premium = false
        }
        
        if premium {
            let averageAge = theBar["Avg_Age"] as! Double
            
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
            
            let singles = theBar["Singles"] as! Double
            let males = theBar["Males"] as! Double
            let females = theBar["Females"] as! Double
            let totalPpl = males + females
            
            if singles > 0{
                let singlePercent = singles/totalPpl * 100
                singleInt = Int(singlePercent)
            }
            else{
                singleInt = 50
            }
            
            if((males == 0 && females == 0) || totalPpl < 4){
                ratioImg = UIImage(named: "ratio_50.png")
            }
            else if(males == 0){
                ratioImg = UIImage(named: "ratio_12_5.png")
            }
            else if(females == 0){
                ratioImg = UIImage(named: "ratio_87_5.png")
            }
            else{
                let guyToGirlRtio = (males/totalPpl) * 100
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
            }

        }
        
        if let barRating = theBar["YelpRating"] as? Double {
            switch barRating {
            case 0:
                ratingImg = UIImage(named: "0 Star.png")
            case 1:
                ratingImg = UIImage(named: "1 Star.png")
            case 1.5:
                ratingImg = UIImage(named: "1.5 Star.png")
            case 2:
                ratingImg = UIImage(named: "2 Star.png")
            case 2.5:
                ratingImg = UIImage(named: "2.5 Star.png")
            case 3:
                ratingImg = UIImage(named: "3 Star.png")
            case 3.5:
                ratingImg = UIImage(named: "3.5 Star.png")
            case 4:
                ratingImg = UIImage(named: "4 Star.png")
            case 4.5:
                ratingImg = UIImage(named: "4.5 Star.png")
            case 5:
                ratingImg = UIImage(named: "5 Star.png")
            default:
                ratingImg = UIImage(named: "0 Star.png")
            }
        } else {
            ratingImg = UIImage(named: "0 Star.png")
        }
        
        self.RatingImageView.image = ratingImg
        
        let currentDate = NSDate()
        let calculatedDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: -4, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let specialsDate = dateFormatter.stringFromDate(calculatedDate!)
        let dayOfWeek = getDayOfWeek(specialsDate)
        
        dayItem = theBar["Daily"] as! [[String]]
        self.hours = dayItem[dayOfWeek-1][0]
        self.notes = dayItem[dayOfWeek-1][1]
        
        let query = PFQuery(className: "Specials")
        
        query.whereKey("Merchant", equalTo: theBar)
        do {
            self.specials = try query.findObjects()
        } catch _ {
        }
        
        for special in specials{
            var currType = 0
            if let testType = special["CurType"] as? String {
                if testType.containsString("%") {
                    currType = 1
                }
            }
            
            if special["Dates"].containsString("Sun"){
                if var dayArray = itemsDict["Sunday"] {
                    dayArray.append((special["Title"] as! String, special["Price"] as! Double, currType))
                    itemsDict["Sunday"] = dayArray
                }
                else{
                    itemsDict["Sunday"] = [(String, Double, Int)]()
                    itemsDict["Sunday"]?.append((special["Title"] as! String, special["Price"] as! Double, currType))
                }
            }
            if special["Dates"].containsString("Mon"){
                if var dayArray = itemsDict["Monday"] {
                    dayArray.append((special["Title"] as! String, special["Price"] as! Double, currType))
                    itemsDict["Monday"] = dayArray
                }
                else{
                    itemsDict["Monday"] = [(String, Double, Int)]()
                    itemsDict["Monday"]?.append((special["Title"] as! String, special["Price"] as! Double, currType))
                }
            }
            if special["Dates"].containsString("Tue"){
                if var dayArray = itemsDict["Tuesday"] {
                    dayArray.append((special["Title"] as! String, special["Price"] as! Double, currType))
                    itemsDict["Tuesday"] = dayArray
                }
                else{
                    itemsDict["Tuesday"] = [(String, Double, Int)]()
                    itemsDict["Tuesday"]?.append((special["Title"] as! String, special["Price"] as! Double, currType))
                }
            }
            if special["Dates"].containsString("Wed"){
                if var dayArray = itemsDict["Wednesday"] {
                    dayArray.append((special["Title"] as! String, special["Price"] as! Double, currType))
                    itemsDict["Wednesday"] = dayArray
                }
                else{
                    itemsDict["Wednesday"] = [(String, Double, Int)]()
                    itemsDict["Wednesday"]?.append((special["Title"] as! String, special["Price"] as! Double, currType))
                }
            }
            if special["Dates"].containsString("Thu"){
                if var dayArray = itemsDict["Thursday"] {
                    dayArray.append((special["Title"] as! String, special["Price"] as! Double, currType))
                    itemsDict["Thursday"] = dayArray
                }
                else{
                    itemsDict["Thursday"] = [(String, Double, Int)]()
                    itemsDict["Thursday"]?.append((special["Title"] as! String, special["Price"] as! Double, currType))
                }
            }
            if special["Dates"].containsString("Fri"){
                if var dayArray = itemsDict["Friday"] {
                    dayArray.append((special["Title"] as! String, special["Price"] as! Double, currType))
                    itemsDict["Friday"] = dayArray
                }
                else{
                    itemsDict["Friday"] = [(String, Double, Int)]()
                    itemsDict["Friday"]?.append((special["Title"] as! String, special["Price"] as! Double, currType))
                }
            }
            if special["Dates"].containsString("Sat"){
                if var dayArray = itemsDict["Saturday"] {
                    dayArray.append((special["Title"] as! String, special["Price"] as! Double, currType))
                    itemsDict["Saturday"] = dayArray
                }
                else{
                    itemsDict["Saturday"] = [(String, Double, Int)]()
                    itemsDict["Saturday"]?.append((special["Title"] as! String, special["Price"] as! Double, currType))
                }
            }
        }
        
        if let dayArray = itemsDict["Sunday"]{
            items.append(dayArray)
            section.append("Sunday")
        }
        if let dayArray = itemsDict["Monday"]{
            items.append(dayArray)
            section.append("Monday")
        }
        if let dayArray = itemsDict["Tuesday"]{
            items.append(dayArray)
            section.append("Tuesday")
        }
        if let dayArray = itemsDict["Wednesday"]{
            items.append(dayArray)
            section.append("Wednesday")
        }
        if let dayArray = itemsDict["Thursday"]{
            items.append(dayArray)
            section.append("Thursday")
        }
        if let dayArray = itemsDict["Friday"]{
            items.append(dayArray)
            section.append("Friday")
        }
        if let dayArray = itemsDict["Saturday"]{
            items.append(dayArray)
            section.append("Saturday")
        }
        
        MerchantTopTableView.tableFooterView = UIView()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if SegmentedControl.selectedSegmentIndex == 2{
            MerchantTopTableView.scrollEnabled = true
            return self.section.count
        }
        else if SegmentedControl.selectedSegmentIndex == 1{
            MerchantTopTableView.scrollEnabled = true
            return 7
        }
        else{
            MerchantTopTableView.scrollEnabled = true
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SegmentedControl.selectedSegmentIndex == 0{
            if premium {
                return 2
            }
            return 1
        }
        else if SegmentedControl.selectedSegmentIndex == 1{
            return 1
        }
        else{
            return items[section].count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if SegmentedControl.selectedSegmentIndex == 2{
            return self.section[section]
        }
        else if SegmentedControl.selectedSegmentIndex == 1{
            return self.daysOfWeek[section]
        }
        else{
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if SegmentedControl.selectedSegmentIndex == 0{
            if premium {
                if indexPath.row == 0{
                    let cell = tableView.dequeueReusableCellWithIdentifier("MerchantFourthCell", forIndexPath: indexPath) as UITableViewCell as! MerchantFourthCell
                    cell.setGenderView(ratioImg)
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("MerchantFifthCell", forIndexPath: indexPath) as UITableViewCell as! MerchantFifthCell
                    cell.setAgeLbl(ageString)
                    cell.setSingleLbl(singleInt)
                    cell.setAgeImage(ageImg)
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("RequestDemCell", forIndexPath: indexPath) as UITableViewCell as! RequestDemCell
                
                // Assign the tap action which will be executed when the user taps the UIButton
                cell.tapAction = { (cell) in
                    self.showAlertForReqest()
                }
                
                return cell
            }
            
        }
        else if SegmentedControl.selectedSegmentIndex == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("MerchantThirdCell", forIndexPath: indexPath) as UITableViewCell as! MerchantThirdCell
            
            cell.setHoursLbl(self.dayItem[indexPath.section][0])
            cell.setNotesLbl(self.dayItem[indexPath.section][1])
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("MerchantSpecialCell", forIndexPath: indexPath) as! MerchantSpecialCell
            
            cell.setSpecialName(items[indexPath.section][indexPath.row].0)
            let price = items[indexPath.section][indexPath.row].1
            var priceString = ""
            
            switch items[indexPath.section][indexPath.row].2 {
            case 0:
                priceString = String(format: "$%.2f", price)
            case 1:
                priceString = "\(price)% off"
            default:
                priceString = String(format: "$%.2f", price)
            }
            
            cell.setPriceCost(priceString)
            return cell
        }
        
    }
    
    func showAlertForReqest()->Void {
        let alertController = UIAlertController(title: "Request Sent", message: "We'll let \(self.barName) know that you want to see them with full ShareFish features!", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Cool", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        self.theBar["Requests"] = (self.theBar["Requests"] as! Int) + 1
        
        do{
            try self.theBar.save()
        } catch _ {}
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
    
    
    
}

