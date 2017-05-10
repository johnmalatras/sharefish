//
//  CreateFishBowl.swift
//  ShareFish
//
//  Created by Oliver Walsh on 2/6/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation

class ChoosePicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imagePicker: UIImagePickerController!
   
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[NSObject : AnyObject]!, editingInfo: [NSObject : AnyObject]!){
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        //imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        presentViewController(picker, animated: true, completion: nil)
    }
}