//
//  LoginViewController.swift
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
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    // Outlets
    @IBOutlet weak var EmailTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    @IBOutlet weak var WarningLabel: UILabel!
    @IBOutlet weak var ScrollView: UIScrollView!
    
    //Animated Gradient
    var gradient : CAGradientLayer!
    var blueGreen : [AnyObject]!
    var greenTurq : [AnyObject]!
    var turqBlue : [AnyObject]!
    var fromColors : [AnyObject]!
    var toColors : [AnyObject]!
    var gradientNum = 0
    var animation : CABasicAnimation!
    var activeField : UITextField?
    
    var kbHeight: CGFloat!
    var succesfulFBLogin = false
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let blue = UIColor(red: 0, green: 1, blue: 141/255, alpha: 1)
        let green = UIColor(red: 0, green: 197/255, blue: 246/255, alpha: 1)
        let turquiose = UIColor(red: 4/255, green: 244/255, blue: 1, alpha: 1)
        
        self.blueGreen = [blue.cgColor, green.cgColor]
        self.greenTurq = [green.cgColor, turquiose.cgColor]
        self.turqBlue = [turquiose.cgColor, blue.cgColor]
        
        self.gradient = CAGradientLayer()
        self.gradient?.frame = self.view.bounds
        self.gradient?.colors = [blue.cgColor, green.cgColor]
        self.view.layer.insertSublayer(self.gradient, at: 0)
        
        self.toColors = greenTurq
        animateLayer()
    }
    
    func animateLayer(){
        
        self.fromColors = self.gradient?.colors! as! [AnyObject]
        self.gradient!.colors = self.toColors!
        self.animation = CABasicAnimation(keyPath: "colors")
        self.animation.delegate = self as? CAAnimationDelegate
        self.animation.fromValue = fromColors
        self.animation.toValue = toColors
        self.animation.duration = 2.00
        self.animation.isRemovedOnCompletion = true
        self.animation.fillMode = kCAFillModeForwards
        self.animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.animation.delegate = self as! CAAnimationDelegate
        
        self.gradient?.add(animation, forKey:"animateGradient")
        
        gradientNum += 1
    }
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool)
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
        
        self.fromColors = self.gradient?.colors as! [AnyObject]
        
        animateLayer()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PasswordTF.delegate = self
        EmailTF.delegate = self
        registerForKeyboardNotificatioins()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterFromKeyboardNotifications()
        self.gradient?.removeAllAnimations()
        
    }
    
    
    func facebookLogin(){
        let permissions = [ "public_profile", "email", "user_relationships", "user_birthday"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions){
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                self.succesfulFBLogin = true
                retreiveUserFacebookData()
                if user.isNew {
                    self.performSegueWithIdentifier("LogintoChoose", sender: self)
                } else {
                    self.performSegueWithIdentifier("LogintoList", sender: self)
                }
            } else {
            }
        }
    }
    
    func retreiveUserFacebookData(){
    
        let user = PFUser.current()!
        
        // Create request for user's Facebook data
        let request = FBSDKGraphRequest(graphPath:"me", parameters:["fields": "id, name, first_name, last_name, email, gender, birthday, relationship_status"])
        
        
        // Send request to Facebook
        request?.start {
            
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
                    let dateFormatter = DateFormatter()
                    let now = NSDate()
                    dateFormatter.dateFormat = "MM/DD/YYYY"
                    let bdayDate = dateFormatter.date(from: birthday)
                    let calendar : NSCalendar = NSCalendar.current as NSCalendar
                    let ageComponents = calendar.components(.year,
                                                            from: bdayDate!,
                                                            to: now as Date,
                        options: [])
                    
                    let age = ageComponents.year
                    user["age"] = age
                }
                
                if (genderString.contains("female"))
                {
                    gender = 0
                }
                else
                {
                    gender = 1
                }
                
                if (relationship.contains("Single")){
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
    
    func logIn(){
        
        if let userName = EmailTF.text,
            let password = PasswordTF.text {
                
                if !userName.isEmpty && !password.isEmpty
                {
                
                    let user = PFUser()
                    user.username = userName
                    user.password = password
                
                    PFUser.logInWithUsernameInBackground(userName, password: password, block: {
                        (User : PFUser?, error : NSError?) -> Void in
                        if let error = error {
                            let errorString = error.userInfo["error"] as! String
                            
                            let alertController = UIAlertController(title: "Can't Login!", message: errorString, preferredStyle: .Alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alertController.addAction(defaultAction)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                        } else {
                            self.performSegueWithIdentifier("LogintoList", sender: self)
                        }
                    
                    })
                } else {
                    WarningLabel.isHidden = false;
                }
   
        } else {
            WarningLabel.isHidden = false;
        }
    }
    
    @IBAction func FacebookLoginButton(sender: AnyObject) {
        facebookLogin()
    }
    
    @IBAction func LoginButton(sender: AnyObject) {
        logIn()
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if "LogintoList" == segue.identifier {
        }
        if "LogintoChoose" == segue.identifier {
        }
    }
    
    //
    //  Remaining code ensures screen moves up when keyboard is opened and keyboard can be properly closed
    //
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func registerForKeyboardNotificatioins()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        self.ScrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.ScrollView.contentInset = contentInsets
        self.ScrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        if let activeFieldPresent = activeField
        {
            if(!aRect.contains(activeFieldPresent.frame.origin))
            {
                self.ScrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification : NSNotification)
    {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        
        self.ScrollView.contentInset = contentInsets
        self.ScrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.ScrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
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
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
