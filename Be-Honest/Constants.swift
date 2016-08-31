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

let CARD_FRAME_RECT = CGRectMake(20.0, 60.0, 335.0, 467.0)


func setProgressViewColor(amt: Int) -> UIColor {
    if amt <= 30 {
        return UIColor.redColor()
    } else if amt <= 60 {
        return UIColor.yellowColor()
    } else {
        return UIColor.greenColor()
    }
    
}

func showErrorAlert(title: String, message: String, controller: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
    alert.addAction(ok)
    controller.presentViewController(alert, animated: true, completion: nil)
}