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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        openCameraBtn.isHidden = true
        openPhotoLibBtn.isHidden = true
        imagePicker.dismiss(animated: true, completion: nil)
        postImg.image = image
        orginialImage = image
        blurFace()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
           
            
            let openGLContext = EAGLContext(api: .openGLES2)
            let context = CIContext(eaglContext: openGLContext!)
            let filter = CIFilter(name: "CIPixellate")!
            filter.setValue(15, forKey: "inputScale")
            let inputImage = CIImage(cgImage: orgImage.cgImage!)
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            let fullPixellatedImage = filter.outputImage
            
            print(orgImage.imageOrientation)
            
            //Detect Face
            let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: options)
            let faces = faceDetector?.features(in: inputImage)
            var maskImage: CIImage!
            let scale = (postImg.bounds.size.width / inputImage.extent.size.width +
                            postImg.bounds.size.height / inputImage.extent.size.height) / 2
            for faceFeature in faces! {
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
                let radialGradientOutputImage = radialGradient.outputImage!.cropping(to: inputImage.extent)
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
            let blendCGImage = context.createCGImage(blendOutputImage, from: blendOutputImage.extent)
            
            blurImage = UIImage(cgImage: blendCGImage!)
        }
        
        

    }
    
    
    func scaleAndRotateImage(_ image: UIImage) -> UIImage {
        let kMaxResolution: CGFloat = 640
        
        let imgRef = image.cgImage
        
        let width = CGFloat((imgRef?.width)!)
        let height = CGFloat((imgRef?.height)!)
        
        
        var transform = CGAffineTransform.identity
        var bounds = CGRect(x: 0, y: 0, width: width, height: height);
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
        let imageSize = CGSize(width: CGFloat((imgRef?.width)!), height: CGFloat((imgRef?.height)!))
        let boundHeight: CGFloat?
        let orient: UIImageOrientation = image.imageOrientation;
        switch(orient) {
            
        case UIImageOrientation.up: //EXIF = 1
            transform = CGAffineTransform.identity;
            break;
            
        case UIImageOrientation.upMirrored: //EXIF = 2
            transform = CGAffineTransform(translationX: imageSize.width, y: 0.0);
            transform = transform.scaledBy(x: -1.0, y: 1.0);
            break;
            
        case UIImageOrientation.down: //EXIF = 3
            transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height);
            transform = transform.rotated(by: CGFloat(M_PI));
            break;
            
        case UIImageOrientation.downMirrored: //EXIF = 4
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.height);
            transform = transform.scaledBy(x: 1.0, y: -1.0);
            break;
            
        case UIImageOrientation.leftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight!;
            transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width);
            transform = transform.scaledBy(x: -1.0, y: 1.0);
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI / 2.0))
            break;
            
        case UIImageOrientation.left: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight!;
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.width);
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0);
            break;
            
        case UIImageOrientation.rightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight!;
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0);
            break;
            
        case UIImageOrientation.right: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight!;
            transform = CGAffineTransform(translationX: imageSize.height, y: 0.0);
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0);
            break;
            
        }
            UIGraphicsBeginImageContext(bounds.size);
            
            let context: CGContext = UIGraphicsGetCurrentContext()!;
            
            if (orient == UIImageOrientation.right || orient == UIImageOrientation.left) {
                context.scaleBy(x: -scaleRatio, y: scaleRatio);
                context.translateBy(x: -height, y: 0);
            } else {
                context.scaleBy(x: scaleRatio, y: -scaleRatio);
                context.translateBy(x: 0, y: -height);
            }
            
            context.concatenate(transform);
            
            UIGraphicsGetCurrentContext()?.draw(imgRef!, in: CGRect(x: 0, y: 0, width: width, height: height));
            let imageCopy: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            
            return imageCopy;
        }
    
    

 
    @IBAction func makePostBtnPressed(_ sender: AnyObject) {
        
        if let txt = questionField.text, txt != "" {
            if let img = postImg.image {
                let imgData = UIImageJPEGRepresentation(img, 0.1)!
                let uuid = UUID().uuidString
                let imgPath = "images/\(uuid)/image.jpg"
                let request = DataService.ds.REF_STORAGE.reference().child(imgPath)
                request.put(imgData, metadata: nil) { metadata, error in
                    if (error != nil) {
                        showErrorAlert("Image Upload Failed", message: "Image failed to save. Please try to submit post again!", controller: self)
                    } else {
                        let post = ["userId": LoginVC.userId,
                                    "imagePath": imgPath,
                                    "question": txt,
                                    "ratings": true,
                                    "numRatings": 0
                                    
                                    ] as [String : Any]
                        
                        DataService.ds.REF_POSTS.childByAutoId().setValue(post)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                showErrorAlert("No Image", message: "Please provide an image to submit your post!", controller: self)
            }
        } else {
            showErrorAlert("Question Blank", message: "Please enter a question to submit your post!", controller: self)
        }
    }

    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openCameraBtnPressed(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func openPhotoLibraryBtnPressed(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func blurSwitchedPressed(_ sender: UISwitch) {
        if sender.isOn {
            postImg.image = blurImage
        } else {
            postImg.image = orginialImage
        }
        
    }
}
