//
//  MapViewController.swift
//  ShareFish
//
//  Created by John Malatras on 1/16/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate
{
    
    @IBOutlet weak var mapView: MKMapView!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    let locationManager = CLLocationManager()
    var pins : [ShareFishPin] = [ShareFishPin]()
    var bowls = [String]()
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var locations : [PFObject] = [PFObject]()
    var userGeoPoint: PFGeoPoint!
    var clickedBar: PFObject!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        
        
        mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        queryandAnno(locValue: manager.location!.coordinate)
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.057, longitudeDelta: 0.057))
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        let reuseID = "BluePin"
        var v = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        v!.canShowCallout = true
        
        let btn = UIButton(type: .DetailDisclosure)
        v!.rightCalloutAccessoryView = btn
        
        v!.image = pins[0].image
        
        return v
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let clickedPin = view.annotation as! ShareFishPin
        let clickedMerchant = clickedPin.merchant! as PFObject
        do{
            try clickedMerchant.fetchIfNeeded()
            self.clickedBar = clickedMerchant
        } catch _ {}
        

        performSegueWithIdentifier("DetailView", sender: view)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let svc = segue.destinationViewController as! MerchantMainViewController
        svc.theBar = clickedBar
        svc.distanceAway = self.userGeoPoint.distanceInMilesTo(clickedBar["Location"] as? PFGeoPoint)
    }
    
    func queryandAnno(locValue:CLLocationCoordinate2D){
        let predicate = NSPredicate(format: "is_approved = 'yes'")
        let query = PFQuery(className: "Locations", predicate: predicate)
        userGeoPoint = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        query.whereKey("Location", nearGeoPoint:userGeoPoint, withinMiles: 8)
        query.selectKeys(["Name", "Location", "Males", "Females"])
        do {
            self.locations = try query.findObjects()
        } catch _ {
        }
        
        for location in locations{
            let currentPin = ShareFishPin(coordinate: CLLocationCoordinate2D(latitude: location["Location"].latitude, longitude: location["Location"].longitude), title: location["Name"] as! String, merchant: location)
            var dist = 0.0
            let pinLocation = CLLocation(latitude: currentPin.coordinate.latitude, longitude: currentPin.coordinate.longitude)
            let distance = locationManager.location!.distanceFromLocation(pinLocation)
            dist += distance  * 0.000621371
            
            let males = location["Males"] as! Double
            let females = location["Females"] as! Double
            let totalPpl = males + females
            var guyToGirlRtio : Int
            
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
                let guyToGirlRtioDbl = (males/totalPpl) * 100
                guyToGirlRtio = Int(guyToGirlRtioDbl)
            }
            
            if guyToGirlRtio > 85 {
                guyToGirlRtio = 85
            }
            else if guyToGirlRtio < 15 {
                guyToGirlRtio = 15
            }
            
            currentPin.assignSubtitle("\(round(dist * 10)/10) miles • 🚹 \(guyToGirlRtio)%  🚺 \(100-guyToGirlRtio)%")
            
            pins.append(currentPin)
            self.mapView.addAnnotation(currentPin)
        }
    }
}
