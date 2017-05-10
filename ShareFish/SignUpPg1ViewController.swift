//
//  SignUpPg1ViewController.swift
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

class SignUpPg1ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var FirstNameTF: UITextField!
    @IBOutlet weak var LastNameTF: UITextField!
    @IBOutlet weak var EmailTF: UITextField!
    @IBOutlet weak var UserNameTF: UITextField!
    @IBOutlet weak var IsBlankLabel: UILabel!
    @IBOutlet weak var EmailErrorLabel: UILabel!
    @IBOutlet weak var ScrollView: UIScrollView!
    
    
    var activeField : UITextField?
    var firstName : String!
    var lastName : String!
    var email : String!
    var userName : String!
    var password : String!
    var age : String!
    var gender = 2
    
    override func viewDidLoad(){
        FirstNameTF.text = firstName
        LastNameTF.text = lastName
        EmailTF.text = email
        UserNameTF.text = userName
        
        FirstNameTF.delegate = self
        LastNameTF.delegate = self
        EmailTF.delegate = self
        UserNameTF.delegate = self
        
        registerForKeyboardNotificatioins()
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpPg1ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
  
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterFromKeyboardNotifications()
        
        self.gradient?.removeAllAnimations()
        
    }
    
    @IBAction func NextButton(sender: AnyObject) {
        if let firstNameTest = FirstNameTF.text{
            if firstNameTest.isEmpty{
                IsBlankLabel.hidden = false
                return
            }
            else{
                firstName = firstNameTest
            }
        }
        
        if let lastNameTest = LastNameTF.text{
            if lastNameTest.isEmpty{
                IsBlankLabel.hidden = false
                return
            }
            else{
                lastName = lastNameTest
            }
        }
        
        if let emailTest = EmailTF.text{
            if emailTest.isEmpty{
                IsBlankLabel.hidden = false
                return
            }
            else{
                let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
                
                let emailTestFormat = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                if emailTestFormat.evaluateWithObject(emailTest){
                    email = emailTest
                }
                else{
                    EmailErrorLabel.hidden = false
                    return
                }
            }
        }
        
        if let unameTest = UserNameTF.text{
            if unameTest.isEmpty{
                IsBlankLabel.hidden = false
                return
            }
            else{
                userName = unameTest
            }
        }
        
        //check if username is taken
        let query : PFQuery = PFUser.query()!
        query.whereKey("username", equalTo: userName.lowercaseString)
        var users : [PFObject] = [PFObject]()
        do {
            users = try query.findObjects()
        } catch _ {
        }
        if users.count > 0{
            let alertController = UIAlertController(title: "Username Taken", message: "Please choose a different username", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        //check if email is taken
        let querye: PFQuery = PFUser.query()!
        querye.whereKey("email", equalTo: email.lowercaseString)
        var userse : [PFObject] = [PFObject]()
        do {
            userse = try querye.findObjects()
        } catch _ {
        }
        if userse.count > 0{
            let alertController = UIAlertController(title: "Can't Sign Up", message: "This email is already associated with a ShareFish account", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }

        
        self.performSegueWithIdentifier("SignUp1to2", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "SignUp1to2") {
            let svc = segue.destinationViewController as! SignUpPg2ViewController;
            
            svc.firstName = firstName
            svc.lastName = lastName
            svc.email = email
            svc.userName = userName
            svc.password = password
            svc.gender = gender
            svc.age = age
        }
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
    
    var bHeight: CGFloat!
    
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
    
    //
    //  Remaining code ensures screen moves up when keyboard is opened and keyboard can be properly closed
    //
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func registerForKeyboardNotificatioins()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpPg1ViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpPg1ViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        self.ScrollView.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.ScrollView.contentInset = contentInsets
        self.ScrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        if let activeFieldPresent = activeField
        {
            if(!CGRectContainsPoint(aRect, activeFieldPresent.frame.origin))
            {
                self.ScrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification : NSNotification)
    {
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        
        self.ScrollView.contentInset = contentInsets
        self.ScrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.ScrollView.scrollEnabled = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        activeField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func dismissKeyboard(){
    
    view.endEditing(true)
    }
    
    
}

