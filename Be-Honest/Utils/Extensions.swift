//
//  Extensions.swift
//  Be-Honest
//
//  Created by admin on 9/10/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import Foundation

// Extension to create Pixellated image
extension UIImage {
    func pixellated(_ scale: Int = 8) -> UIImage? {
        guard let
            ciImage = UIKit.CIImage(image: self),
            let filter = CIFilter(name: "CIPixellate") else { return nil }
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(scale, forKey: "inputScale")
        guard let output = filter.outputImage else { return nil }
        return UIImage(ciImage: output)
    }
}

// VC extension to close keyboard when any part of view is clicked
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
