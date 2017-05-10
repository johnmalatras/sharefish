//
//  SignUpPg2ViewController.swift
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

class SignUpPg2ViewController: UIViewController, UITextFieldDelegate {
    var firstName : String!
    var lastName : String!
    var email : String!
    var userName : String!
    var password : String!
    var gender  : Int! // 0 = female, 1 = male
    var age : String!
    
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
    
    @IBOutlet weak var AgeTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    @IBOutlet weak var ConfrimPassTF: UITextField!
    @IBOutlet weak var FemaleButton: UIButton!
    @IBOutlet weak var MaleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpPg2ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.AgeTF.delegate = self
        self.PasswordTF.delegate = self
        self.ConfrimPassTF.delegate = self
        
        if let testAge = age{
            if let intAge = Int(testAge){
                AgeTF.text = String(intAge)
            }
        }
        PasswordTF.text = password
        ConfrimPassTF.text = password
        
        if gender == 0{
            FemaleButton.setImage(UIImage(named: "Faded Female.png"), forState: UIControlState.Normal)
        }
        if gender == 1{
            MaleButton.setImage(UIImage(named: "faded male.png"), forState: UIControlState.Normal)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.gradient?.removeAllAnimations()
        
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
    
    @IBAction func NextButton(sender: AnyObject) {
        if let passwordTest = PasswordTF.text, let confirmTest = ConfrimPassTF.text
        {
            if passwordTest != confirmTest {
                let alertController = UIAlertController(title: "Passwords don't match", message: "Please enter a matching password in the 'Confirm Password' field", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
            else{
                password = confirmTest
            }
        }
        
        if let ageTest = AgeTF.text{
            if ageTest.characters.count > 0{
                if let ageFormatTest = Int(ageTest){
                    age = ageTest
                    if ageFormatTest < 18{
                        let alertController = UIAlertController(title: "Age Entered Under 18", message: "Sorry! You must be 18 to use ShareFish", preferredStyle: .Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        return
                        
                    }
                }
                else{
                    let alertController = UIAlertController(title: "Wrong Age Format", message: "Please enter a proper numerical age.", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    return
                }
            }
           
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            [unowned self] in
            self.performSegueWithIdentifier("SignUp2to3", sender: self)
        }
        
    }
    
    
    @IBAction func BackButton(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            [unowned self] in
            self.performSegueWithIdentifier("SignUp2to1", sender: self)
        }
    }
    
    
    @IBAction func MaleCheckButton(sender: AnyObject) {
        gender = 1
        MaleButton.setImage(UIImage(named: "faded male.png"), forState: UIControlState.Normal)
        FemaleButton.setImage(UIImage(named: "female.png"), forState: UIControlState.Normal)
    }
    
    @IBAction func FemaleCheckButton(sender: AnyObject) {
        gender = 0
        MaleButton.setImage(UIImage(named: "male.png"), forState: UIControlState.Normal)
        FemaleButton.setImage(UIImage(named: "Faded Female.png"), forState: UIControlState.Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "SignUp2to3") {
            let svc = segue.destinationViewController as! SignUpViewController;
            
            svc.firstName = firstName
            svc.lastName = lastName
            svc.email = email
            svc.userName = userName
            svc.password = password
            svc.age = age
            svc.gender = gender
        }
        if(segue.identifier == "SignUp2to1") {
            let svc = segue.destinationViewController as! SignUpPg1ViewController;
            
            svc.firstName = firstName
            svc.lastName = lastName
            svc.email = email
            svc.userName = userName
            svc.password = password
            svc.age = age
            svc.gender = gender
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
  
}
