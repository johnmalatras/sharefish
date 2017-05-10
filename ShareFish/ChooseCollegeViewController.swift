//
//  ChooseCollegeViewController.swift
//  ShareFish
//
//  Created by John Malatras on 2/11/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ChooseCollegeViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var CollegePicker: UIPickerView!
    @IBOutlet weak var ReferencePicker: UIPickerView!
    @IBOutlet weak var CampusRepTF: UITextField!
    
    
    var colleges : [PFObject]!
    let referenceChoices = ["Facebook", "Twitter", "Campus Rep", "Media Publications", "Instagram", "Other"]
    
    var selectedCollege = 0
    
    //Animated Gradient
    var gradient : CAGradientLayer!
    var blueGreen : AnyObject!
    var greenTurq : AnyObject!
    var turqBlue : AnyObject!
    var fromColors : AnyObject!
    var toColors : AnyObject!
    var gradientNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CampusRepTF.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChooseCollegeViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        CollegePicker.tag = 0
        ReferencePicker.tag = 1
        
        // Connect data:
        self.CollegePicker.delegate = self
        self.CollegePicker.dataSource = self
        self.ReferencePicker.delegate = self
        self.ReferencePicker.dataSource = self
        
        let query = PFQuery(className: "Colleges")
        query.orderByAscending("Name")
        do {
            self.colleges = try query.findObjects()
        } catch _ {
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        animation.duration = 2.00
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            return colleges.count
        }
        if pickerView.tag == 1{
            return referenceChoices.count
        }
        
        return 1
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
            return colleges[row]["Name"] as? String
        }
        if pickerView.tag == 1{
            return referenceChoices[row]
        }
        return "Error"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0{
            selectedCollege = pickerView.selectedRowInComponent(0)
        }
    }
    
    
    @IBAction func NextClicked(sender: AnyObject) {
        let collegeChoice = colleges[CollegePicker.selectedRowInComponent(0)]["Name"] as? String
        let referenceChoice = referenceChoices[ReferencePicker.selectedRowInComponent(0)]
        var referenceString = referenceChoice
        
        
        let currentUser = PFUser.currentUser()!
        if let repName = CampusRepTF.text{
            referenceString += " - " + repName
        }
        
        currentUser["School"] = collegeChoice
        currentUser["Reference"] = referenceString
        currentUser.saveInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
            }
        }
        performSegueWithIdentifier("ChooseToStart", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChooseToStart"{
        }
    }
    
}