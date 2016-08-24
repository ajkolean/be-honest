//
//  PostDetailVC.swift
//  Be-Honest
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit

class PostDetailVC: UIViewController {
    
    var post: Post!

    @IBOutlet weak var questionLbl: UILabel!
    
    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var numRatingsLbl: UILabel!
    
    @IBOutlet weak var approvalPercentageLbl: UILabel!
    
    @IBOutlet weak var approvalProgressView: UIProgressView!
    
    @IBOutlet weak var maleApprovalPercentageLbl: UILabel!
    
    @IBOutlet weak var maleProgressView: UIProgressView!
    @IBOutlet weak var femaleApprovalPercentageLbl: UILabel!
    
    @IBOutlet weak var femaleProgressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let approval = (post.likes * 100)/post.ratings
        let maleApproval = (post.maleLikes * 100) / (post.femaleLikes + post.maleLikes)
        let femaleApproval = 100 - maleApproval

        questionLbl.text = post.question
        numRatingsLbl.text = "\(post.ratings)"
        
        approvalPercentageLbl.text = "\(approval)%"
        approvalProgressView.progress = Float(approval) / 100
        approvalProgressView.progressTintColor = setProgressViewColor(approval)
        
        
        maleApprovalPercentageLbl.text = "\(maleApproval)%"
        maleProgressView.progress = Float(maleApproval) / 100
        maleProgressView.progressTintColor = setProgressViewColor(maleApproval)


        femaleApprovalPercentageLbl.text = "\(femaleApproval)%"
        femaleProgressView.progress = Float(femaleApproval) / 100
        femaleProgressView.progressTintColor = setProgressViewColor(femaleApproval)

        
        
        
        var img: UIImage?
        if let imagePath = post.imagePath {
            img = SecondViewController.imageCache.objectForKey(imagePath) as? UIImage
        }
        if img != nil {
            self.postImg.image = img
        } else {
            let request = DataService.ds.REF_STORAGE.reference().child("images/\(post.imagePath!)")
            request.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    let img = UIImage(data: data!)
                    self.postImg.image = img
                    SecondViewController.imageCache.setObject(img!, forKey: self.post.imagePath!)
                }
            }
            
        }


    }
    
  

  
    @IBAction func goBackBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)

    }

 

}
