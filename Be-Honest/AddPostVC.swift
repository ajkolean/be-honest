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

class AddPostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var blurSwitch: UISwitch!
    
    @IBOutlet weak var questionField: UITextField!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var openCameraBtn: UIButton!
    @IBOutlet weak var openPhotoLibBtn: UIButton!
    var imagePicker: UIImagePickerController!
    var orginialImage: UIImage?
    var blurImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        questionField.delegate = self;
        
        postImg.layer.cornerRadius = BORDER_RADIUS
        postImg.clipsToBounds = true
        
        postBtn.layer.cornerRadius = BORDER_RADIUS
        postBtn.clipsToBounds = true
        
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
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 100
    }


    
    func blurFace()  {
        if var orgImage = postImg.image {
            orgImage = scaleAndRotateImage(orgImage)
           
            
            let openGLContext = EAGLContext(API: .OpenGLES2)
            let context = CIContext(EAGLContext: openGLContext)
            let filter = CIFilter(name: "CIPixellate")!
            filter.setValue(15, forKey: "inputScale")
            let inputImage = CIImage(CGImage: orgImage.CGImage!)
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            let fullPixellatedImage = filter.outputImage
            
            print(orgImage.imageOrientation)
            
            //Detect Face
            let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: options)
            let faces = faceDetector.featuresInImage(inputImage)
            var maskImage: CIImage!
            let scale = (postImg.bounds.size.width / inputImage.extent.size.width +
                            postImg.bounds.size.height / inputImage.extent.size.height) / 2
            for faceFeature in faces {
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
                let radialGradientOutputImage = radialGradient.outputImage!.imageByCroppingToRect(inputImage.extent)
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
            let blendCGImage = context.createCGImage(blendOutputImage, fromRect: blendOutputImage.extent)
            
            blurImage = UIImage(CGImage: blendCGImage)
        }
        
        

    }
    
    
    func scaleAndRotateImage(image: UIImage) -> UIImage {
        let kMaxResolution: CGFloat = 640
        
        let imgRef = image.CGImage
        
        let width = CGFloat(CGImageGetWidth(imgRef))
        let height = CGFloat(CGImageGetHeight(imgRef))
        
        
        var transform = CGAffineTransformIdentity
        var bounds = CGRectMake(0, 0, width, height);
        if width > kMaxResolution || height > kMaxResolution {
            let  ratio = width/height;
            if (ratio > 1) {
                bounds.size.width = kMaxResolution;
                bounds.size.height = round(bounds.size.width / ratio)
            } else {
                bounds.size.height = kMaxResolution;
                bounds.size.width = round(bounds.size.height * ratio)
            }
        }
        
        let scaleRatio = bounds.size.width / width;
        let imageSize = CGSizeMake(CGFloat(CGImageGetWidth(imgRef)), CGFloat(CGImageGetHeight(imgRef)))
        let boundHeight: CGFloat?
        let orient: UIImageOrientation = image.imageOrientation;
        switch(orient) {
            
        case UIImageOrientation.Up: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientation.UpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientation.Down: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI));
            break;
            
        case UIImageOrientation.DownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientation.LeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight!;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI / 2.0))
            break;
            
        case UIImageOrientation.Left: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight!;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0);
            break;
            
        case UIImageOrientation.RightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight!;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0);
            break;
            
        case UIImageOrientation.Right: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight!;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0);
            break;
            
        }
            UIGraphicsBeginImageContext(bounds.size);
            
            let context: CGContextRef = UIGraphicsGetCurrentContext()!;
            
            if (orient == UIImageOrientation.Right || orient == UIImageOrientation.Left) {
                CGContextScaleCTM(context, -scaleRatio, scaleRatio);
                CGContextTranslateCTM(context, -height, 0);
            } else {
                CGContextScaleCTM(context, scaleRatio, -scaleRatio);
                CGContextTranslateCTM(context, 0, -height);
            }
            
            CGContextConcatCTM(context, transform);
            
            CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
            let imageCopy: UIImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return imageCopy;
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
                                    "ratings": true,
                                    "numRatings": 0
                                    
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
