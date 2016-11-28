//
//  Constants.swift
//  Be-Honest
//
//  Created by admin on 8/14/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import Foundation
import UIKit

let SHADOW_COLOR: CGFloat = 157.0 / 255.0

//Keys
let KEY_UID = "uid"

//Segues
let SEGUE_LOGGED_IN = "loggedIn"


//Status Code
let STATUS_ACCOUNT_NONEXIST = 17011
let STATUS_INVALID_PASSWORD = 17009

//Card Frame

let CARD_FRAME_RECT = CGRect(x: 20.0, y: 60.0, width: 335.0, height: 467.0)

// BORDER RADIUS
let BORDER_RADIUS: CGFloat = 15.0


func setProgressViewColor(_ amt: Float) -> UIColor {
    if amt <= 0.3 {
        return UIColor.red
    } else if amt <= 0.6 {
        return UIColor.yellow
    } else {
        return UIColor.green
    }
    
}

func showErrorAlert(_ title: String, message: String, controller: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
    alert.addAction(ok)
    controller.present(alert, animated: true, completion: nil)
}


