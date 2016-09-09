//
//  AddPostVC.swift
//  Be-Honest
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import CoreImage

class AddPostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var blurSwitch: UISwitch!
    
    @IBOutlet weak var questionField: UITextField!
    
    @IBOutlet weak var openCameraBtn: UIButton!
    @IBOutlet weak var openPhotoLibBtn: UIButton!
    var imagePicker: UIImagePickerController!
    var orginialImage: UIImage?
    var blurImage: UIImage?
    
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
        orginialImage = image
        blurFace()
    }
    
  
    

    
    func blurFace()  {
        if let orgImage = postImg.image {
            
            let filter = CIFilter(name: "CIPixellate")!
            let inputImage = CIImage(image: orgImage)
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            let fullPixellatedImage = filter.outputImage
            let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
            let faces = faceDetector.featuresInImage(inputImage!)
            var maskImage: CIImage!
            let scale = min(postImg.bounds.size.width / inputImage!.extent.size.width,
                            postImg.bounds.size.height / inputImage!.extent.size.height)
            if let faceFeature = faces.first as? CIFaceFeature {
                let centerX = faceFeature.bounds.origin.x + faceFeature.bounds.size.width / 2
                let centerY = faceFeature.bounds.origin.y + faceFeature.bounds.size.height / 2
                let radius = min(faceFeature.bounds.size.width, faceFeature.bounds.size.height) * scale
                let radialGradient = CIFilter(name: "CIRadialGradient",
                                          withInputParameters: [
                                            "inputRadius0" : radius,
                                            "inputRadius1" : radius + 1,
                                            "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                                            "inputColor1" : CIColor(red: 0, green: 0, blue: 0, alpha: 0),
                                            kCIInputCenterKey : CIVector(x: centerX, y: centerY)
                ])!
            
                print(radialGradient.attributes)
                let radialGradientOutputImage = radialGradient.outputImage!.imageByCroppingToRect(inputImage!.extent)
                if maskImage == nil {
                    maskImage = radialGradientOutputImage
                } else {
                    print(radialGradientOutputImage)
                    maskImage = CIFilter(name: "CISourceOverCompositing",
                                     withInputParameters: [
                                        kCIInputImageKey : radialGradientOutputImage,
                                        kCIInputBackgroundImageKey : maskImage
                    ])!.outputImage
                }
                    print(maskImage.extent)
            }
            let blendFilter = CIFilter(name: "CIBlendWithMask")!
            blendFilter.setValue(fullPixellatedImage, forKey: kCIInputImageKey)
            blendFilter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
            blendFilter.setValue(maskImage, forKey: kCIInputMaskImageKey)

            let blendOutputImage = blendFilter.outputImage!
            let context = CIContext(options: nil)
            let blendCGImage = context.createCGImage(blendOutputImage, fromRect: blendOutputImage.extent)
            blurImage = UIImage(CGImage: blendCGImage)
        }

    }

 
    @IBAction func makePostBtnPressed(sender: AnyObject) {
        
        if let txt = questionField.text where txt != "" {
            if let img = postImg.image {
                let imgData = UIImageJPEGRepresentation(img, 0.1)!
                let uuid = NSUUID().UUIDString
                let imgPath = "images/\(uuid)/image.jpg"
                let request = DataService.ds.REF_STORAGE.reference().child(imgPath)
                request.putData(imgData, metadata: nil) { metadata, error in
                    if (error != nil) {
                        showErrorAlert("Image Upload Failed", message: "Image failed to save. Please try to submit post again!", controller: self)
                    } else {
                        let post = ["userId": LoginVC.userId,
                                    "imagePath": imgPath,
                                    "question": txt,
                                    "ratings": [],
                                    
                                    ]
                        
                        DataService.ds.REF_POSTS.childByAutoId().setValue(post)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            } else {
                showErrorAlert("No Image", message: "Please provide an image to submit your post!", controller: self)
            }
        } else {
            showErrorAlert("Question Blank", message: "Please enter a question to submit your post!", controller: self)
        }
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
    @IBAction func blurSwitchedPressed(sender: UISwitch) {
        if sender.on {
            postImg.image = blurImage
        } else {
            postImg.image = orginialImage
        }
        
    }
}
