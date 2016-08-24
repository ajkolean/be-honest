//
//  ViewController.swift
//  Be-Honest
//
//  Created by admin on 8/14/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginVC: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var facebookLogin: UIView!
    @IBOutlet weak var googleLogin: UIView!
    let tapFBLogin = UITapGestureRecognizer()
    let tapGoogleLogin = UITapGestureRecognizer()



    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        tapFBLogin.addTarget(self, action: #selector(self.fbBtnPressed))
        facebookLogin.addGestureRecognizer(tapFBLogin)
        
        tapGoogleLogin.addTarget(self, action: #selector(self.googleBtnPressed))
        googleLogin.addGestureRecognizer(tapGoogleLogin)


    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil || GIDSignIn.sharedInstance().hasAuthInKeychain() {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }

    
    func googleBtnPressed() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func fbBtnPressed() {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString {
                    print("Successfully logged in with facebook. \(accessToken)")
                    
                    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                    FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                        
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged In!\(user)")
                            if let user = user {
                                let newUser = ["provider" : "facebook"]
                                DataService.ds.createFirebaseUser(user.uid, user: newUser)
                                
                            }
                            NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)

                        }
                        
                        
                    })
                    
                }
            
                
            }
        }

    }
  
    
}
