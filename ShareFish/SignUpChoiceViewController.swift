//
//  SignUpChoiceViewController.swift
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

class SignUpChoiceViewController : UIViewController {
    
    func facebookSignUp(){
        let permissions = [ "public_profile", "email", "user_relationships", "user_birthday"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions){
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                retreiveUserFacebookData
                if user.isNew {
                    self.performSegueWithIdentifier("LogintoChoose", sender: self)
                } else {
                    self.performSegueWithIdentifier("LogintoList", sender: self)
                }
            } else {
            }
        }
    }
    
    func retreiveUserFacebookData()
    {
        let user = PFUser.currentUser()!
        
        // Create request for user's Facebook data
        let request = FBSDKGraphRequest(graphPath:"me", parameters:["fields": "id, name, first_name, last_name, email, gender, birthday, relationship_status"])
        
        
        // Send request to Facebook
        request.startWithCompletionHandler {
            
            (connection, result, error) in
            
            if error != nil {
            }
            else if let userData = result as? [String:AnyObject] {
                
                // Access user data
                let firstName = userData["first_name"] as! String
                let lastName = userData["last_name"] as! String
                let email = userData["email"] as! String
                let genderString = userData["gender"] as! String
                let relationship = userData["relationship_status"] as! String
                let birthday = userData["birthday"] as! String
                
                var gender = Int()
                var relationshipStatus = Int()
                
                if birthday.characters.count == 10 {
                    let dateFormatter = NSDateFormatter()
                    let now = NSDate()
                    dateFormatter.dateFormat = "MM/DD/YYYY"
                    let bdayDate = dateFormatter.dateFromString(birthday)
                    let calendar : NSCalendar = NSCalendar.currentCalendar()
                    let ageComponents = calendar.components(.Year,
                        fromDate: bdayDate!,
                        toDate: now,
                        options: [])
                    
                    let age = ageComponents.year
                    user["age"] = age
                }
                
                if (genderString.containsString("female"))
                {
                    gender = 0
                }
                else
                {
                    gender = 1
                }
                
                if (relationship.containsString("Single")){
                    relationshipStatus = 0
                }
                else{
                    relationshipStatus = 1
                }
                
                user["firstName"] = firstName
                user["lastName"] = lastName
                user["Gender"] = gender
                user["email"] = email
                user["Relationship"] = relationshipStatus
                user.saveInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if error != nil {
                        let alertController = UIAlertController(title: "Oops!", message: "Something went wrong. Please try logging in to Facebook again, or sign up manually.", preferredStyle: .Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        return
                    }
                }
            }
        }
    }
    
    @IBAction func facebookButton(sender: UIButton!) {
        facebookSignUp()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    //Animated Gradient
    var gradient : CAGradientLayer!
    var blueGreen : AnyObject!
    var greenTurq : AnyObject!
    var turqBlue : AnyObject!
    var fromColors : AnyObject!
    var toColors : AnyObject!
    var gradientNum = 0
    
    var kbHeight: CGFloat!
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let blue = UIColor(red: 0, green: 1, blue: 141/255, alpha: 1)
        let green = UIColor(red: 0, green: 197/255, blue: 246/255, alpha: 1)
        let turquiose = UIColor(red: 4/255, green: 244/255, blue: 1, alpha: 1)
        
        self.blueGreen = [blue.CGColor, green.CGColor]
        self.greenTurq = [green.CGColor, turquiose.CGColor]
        self.turqBlue = [turquiose.CGColor, blue.CGColor]
        
        self.gradient = CAGradientLayer()
        self.gradient?.frame = self.view.bounds
        self.gradient?.colors = [blue.CGColor, green.CGColor]
        self.view.layer.insertSublayer(self.gradient, atIndex: 0)
        
        self.toColors = greenTurq
        animateLayer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.gradient?.removeAllAnimations()
        
    }
    
    func animateLayer(){
        
        self.fromColors = self.gradient?.colors
        self.gradient!.colors = self.toColors! as? [AnyObject]
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.delegate = self
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 4.00
        animation.removedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        self.gradient?.addAnimation(animation, forKey:"animateGradient")
        
        gradientNum += 1
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool)
    {
        if gradientNum == 1
        {
            self.toColors = greenTurq
        }
        else if gradientNum == 2
        {
            self.toColors = turqBlue
        }
        else if gradientNum == 3
        {
            self.toColors = blueGreen
            gradientNum = 0
        }
        
        self.fromColors = self.gradient?.colors
        
        animateLayer()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
}
