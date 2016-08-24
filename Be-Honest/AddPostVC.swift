//
//  AddPostVC.swift
//  Be-Honest
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit

class AddPostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var blurSwitch: UISwitch!
    
    @IBOutlet weak var questionField: UITextField!
    
    @IBOutlet weak var openCameraBtn: UIButton!
    @IBOutlet weak var openPhotoLibBtn: UIButton!
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImg.layer.cornerRadius = 15.0
        postImg.clipsToBounds = true
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        openCameraBtn.hidden = true
        openPhotoLibBtn.hidden = true
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        postImg.image = image
    }
    
   

 
    @IBAction func makePostBtnPressed(sender: AnyObject) {
    }

    @IBAction func cancelBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openCameraBtnPressed(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func openPhotoLibraryBtnPressed(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
}
