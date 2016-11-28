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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: KEY_UID) != nil  {
                LoginVC.userId = UserDefaults.standard.value(forKey: KEY_UID) as? String
                if let gender = UserDefaults.standard.value(forKey: "gender") as? String {
                    LoginVC.gender = gender
                } else {
                    LoginVC.gender = ""
                }
                
                self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
            }
           
    }

    
      
    func fbBtnPressed() {
        let facebookLogin = FBSDKLoginManager()
        var userGender = ""
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (facebookResult, facebookError) in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                if let accessToken = FBSDKAccessToken.current().tokenString {
                    let params = ["fields": "gender"]
                    print("Successfully logged in with facebook. \(accessToken)")
                  
//TODO: Get gender from facebook user profile
//                    let pictureRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
//                    pictureRequest?.start(completionHandler: {
//                        (connection, result, error: NSError!) -> Void in
//                        if error == nil {
//                            if let gender = result["gender"] as? String {
//                                userGender = gender
//                            }
//                        } else {
//                            print("\(error)")
//                        }
//                    })
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken)
                    FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                        print("This is provider data \(user?.providerData[0])")
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged In!\(user)")
                            if let user = user {
                                let newUser = ["provider" : "facebook", "gender": userGender]
                                DataService.ds.createFirebaseUser(user.uid, user: newUser)
                                LoginVC.userId = user.uid
                                UserDefaults.standard.setValue(user.uid, forKey: KEY_UID)
                                UserDefaults.standard.setValue(userGender, forKey: "gender")
                                LoginVC.gender = userGender

                                self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                            }
                            

                        }
                        
                        
                    })
                    
                }
            
                
            }
        }
        
    }
    @IBAction func resetPassword(_ sender: AnyObject!) {
        guard let email = emailField.text, email != "" else {
            showErrorAlert("No Email Provided", message: "Please fill in email address and select \"forgot password?\" again", controller: self)
            return;
        }
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { error in
            if error != nil {
                showErrorAlert("Could Not Send Email", message: "Please check your email address", controller: self)

            } else {
                showErrorAlert("Success", message: "Further instructions to reset your password were sent to \(email)", controller: self)
            }
        })
    }
   
    
    @IBAction func attemptLogin(_ sender: AnyObject!) {
        var userGender = ""

        if let email = emailField.text, email != "", let pwd = passwordField.text, pwd != "" {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if let err = error {
                  
                    if err._code == STATUS_ACCOUNT_NONEXIST {
                        FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                            if error != nil {
                                showErrorAlert("Could not create account", message: "Problem creating account. Try something else", controller: self)
                            } else {
                                UserDefaults.standard.setValue(user?.uid, forKey: KEY_UID)
                                UserDefaults.standard.setValue(userGender, forKey: "gender")
                                LoginVC.userId = user?.uid
                                LoginVC.gender = userGender

                                FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: nil)
                                self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                    } else if err._code == STATUS_INVALID_PASSWORD {
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
                    UserDefaults.standard.setValue(user?.uid, forKey: KEY_UID)
                    UserDefaults.standard.setValue(userGender, forKey: "gender")
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", message: "You must enter an email and a password", controller: self)
        }
        
    }
  
    
}
