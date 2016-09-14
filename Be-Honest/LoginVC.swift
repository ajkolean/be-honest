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

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: MaterialTextField!
    
    @IBOutlet weak var passwordField: MaterialTextField!
    
    @IBOutlet weak var facebookLogin: UIView!
    @IBOutlet weak var googleLogin: UIView!
    let tapFBLogin = UITapGestureRecognizer()
    let tapGoogleLogin = UITapGestureRecognizer()
    static var userId: String!
    static var gender: String!


    override func viewDidLoad() {
        super.viewDidLoad()
   
        tapFBLogin.addTarget(self, action: #selector(self.fbBtnPressed))
        facebookLogin.addGestureRecognizer(tapFBLogin)
        
        


    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil  {
                LoginVC.userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String
                if let gender = NSUserDefaults.standardUserDefaults().valueForKey("gender") as? String {
                    LoginVC.gender = gender
                } else {
                    LoginVC.gender = ""
                }
                
                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
            }
           
    }

    
      
    func fbBtnPressed() {
        let facebookLogin = FBSDKLoginManager()
        var userGender = ""
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString {
                    let params = ["fields": "gender"]
                    print("Successfully logged in with facebook. \(accessToken)")
                    let pictureRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
                    pictureRequest.startWithCompletionHandler({
                        (connection, result, error: NSError!) -> Void in
                        if error == nil {
                            if let gender = result["gender"] as? String {
                                userGender = gender
                            }
                        } else {
                            print("\(error)")
                        }
                    })
                    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                    FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                        print("This is provider data \(user?.providerData[0])")
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged In!\(user)")
                            if let user = user {
                                let newUser = ["provider" : "facebook", "gender": userGender]
                                DataService.ds.createFirebaseUser(user.uid, user: newUser)
                                LoginVC.userId = user.uid
                                NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: KEY_UID)
                                NSUserDefaults.standardUserDefaults().setValue(userGender, forKey: "gender")
                                LoginVC.gender = userGender

                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            

                        }
                        
                        
                    })
                    
                }
            
                
            }
        }
        
    }
    @IBAction func resetPassword(sender: AnyObject!) {
        guard let email = emailField.text where email != "" else {
            showErrorAlert("No Email Provided", message: "Please fill in email address and select \"forgot password?\" again", controller: self)
            return;
        }
        FIRAuth.auth()?.sendPasswordResetWithEmail(email, completion: { error in
            if error != nil {
                showErrorAlert("Could Not Send Email", message: "Please check your email address", controller: self)

            } else {
                showErrorAlert("Success", message: "Further instructions to reset your password were sent to \(email)", controller: self)
            }
        })
    }
   
    
    @IBAction func attemptLogin(sender: AnyObject!) {
        var userGender = ""

        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                if let err = error {
                    print(err.debugDescription)
                    
                    if err.code == STATUS_ACCOUNT_NONEXIST {
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                            if error != nil {
                                showErrorAlert("Could not create account", message: "Problem creating account. Try something else", controller: self)
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                                NSUserDefaults.standardUserDefaults().setValue(userGender, forKey: "gender")
                                LoginVC.userId = user?.uid
                                LoginVC.gender = userGender

                                FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: nil)
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                    } else if err.code == STATUS_INVALID_PASSWORD {
                        showErrorAlert("Email or Password Incorrect", message: "The email and password you enter do not match.", controller: self)
                        
                    } else {
                        showErrorAlert("Could Not Login", message: "Please check your username or password", controller: self)
                        
                    }
                } else {
                    if let user = user {
                        let newUser = ["provider" : "password", "gender": "userGender"]
                        DataService.ds.createFirebaseUser(user.uid, user: newUser)
                        LoginVC.userId = user.uid
                        LoginVC.gender = userGender

                        
                    }
                    NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                    NSUserDefaults.standardUserDefaults().setValue(userGender, forKey: "gender")
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", message: "You must enter an email and a password", controller: self)
        }
        
    }
  
    
}
