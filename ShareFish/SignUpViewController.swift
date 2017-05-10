//
//  SignUpViewController.swift
//  ShareFish
//
//  Created by John Malatras on 1/29/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import CoreLocation

class SignUpViewController: UIViewController {
    
    var firstName : String!
    var lastName : String!
    var email : String!
    var userName : String!
    var password : String!
    var age : String!
    var gender : Int!
    
    @IBOutlet weak var NameTF: UILabel!
    @IBOutlet weak var UserNameTF: UILabel!
    @IBOutlet weak var EmailTF: UILabel!
    @IBOutlet weak var AgeTF: UILabel!
    @IBOutlet weak var genderPic: UIImageView!
    
    override func viewDidLoad() {
        NameTF.text = firstName + " " + lastName
        UserNameTF.text = userName
        EmailTF.text = email
        if let testAge = age{
            if let intAge = Int(testAge){
                AgeTF.text = String(intAge) + " years old"
            }
        }
        
        if gender == 0
        {
            genderPic.image = UIImage(named: "female.png")
            genderPic.hidden = false
        }
        else if gender == 1
        {
            genderPic.image = UIImage(named: "male.png")
            genderPic.hidden = false
        }
        
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.gradient?.removeAllAnimations()
        
    }
    
    
    func signUp(){
        let user = PFUser()
        user.username = userName
        user.password = password
        user.email = email
        user["firstName"] = firstName
        user["lastName"] = lastName
        if let testAge = age{
            if let intAge = Int(testAge){
                user["age"] = intAge
            }
        }
        user["Gender"] = gender
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as! String
                
                let alertController = UIAlertController(title: "Sign Up Error", message: errorString, preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    [unowned self] in
                    self.performSegueWithIdentifier("SUtoChoose", sender: self)
                }
            }
        }
        
        user.saveInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            
            if(success)
            {
                
            }
            else
            {
                
            }
        }
        
    }
    
    @IBAction func BackButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            [unowned self] in
            self.performSegueWithIdentifier("SignUpFto2", sender: self)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "SignUpFto2") {
            let svc = segue.destinationViewController as! SignUpPg2ViewController;
            
            svc.firstName = firstName
            svc.lastName = lastName
            svc.email = email
            svc.userName = userName
            svc.password = password
            svc.age = age
            svc.gender = gender
        }
        if(segue.identifier == "SUtoChoose"){
        }
    }

    
    @IBAction func SignUpButton(sender: AnyObject) {
        signUp()
    }
    
    //Animated Gradient
    var gradient : CAGradientLayer!
    var blueGreen : AnyObject!
    var greenTurq : AnyObject!
    var turqBlue : AnyObject!
    var fromColors : AnyObject!
    var toColors : AnyObject!
    var gradientNum = 0
    var animation : CABasicAnimation!
    
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
    
    func animateLayer(){
        
        self.fromColors = self.gradient?.colors
        self.gradient!.colors = self.toColors! as? [AnyObject]
        self.animation = CABasicAnimation(keyPath: "colors")
        self.animation.delegate = self
        self.animation.fromValue = fromColors
        self.animation.toValue = toColors
        self.animation.duration = 2.00
        self.animation.removedOnCompletion = true
        self.animation.fillMode = kCAFillModeForwards
        self.animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.animation.delegate = self
        
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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}