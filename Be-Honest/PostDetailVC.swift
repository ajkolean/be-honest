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
    
    @IBOutlet weak var postImg: CustomImageView!
    
    @IBOutlet weak var numRatingsLbl: UILabel!
    
    @IBOutlet weak var approvalPercentageLbl: UILabel!
    
    @IBOutlet weak var approvalProgressView: CustomProgressView!
    
    @IBOutlet weak var maleApprovalPercentageLbl: UILabel!
    
    @IBOutlet weak var maleProgressView: CustomProgressView!
    @IBOutlet weak var femaleApprovalPercentageLbl: UILabel!
    
    @IBOutlet weak var femaleProgressView: CustomProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionLbl.text = post.question
        numRatingsLbl.text = "\(post.ratings)"
        
        approvalPercentageLbl.text = "\(Int(post.approvalPercentage * 100))%"
        approvalProgressView.progress = post.approvalPercentage
        approvalProgressView.progressTintColor = setProgressViewColor(post.approvalPercentage)
        
        
        maleApprovalPercentageLbl.text = "\(Int(post.maleApprovalPercentage * 100))%"
        maleProgressView.progress = post.maleApprovalPercentage
        maleProgressView.progressTintColor = setProgressViewColor(post.maleApprovalPercentage)


        femaleApprovalPercentageLbl.text = "\(Int(post.femaleApprovalPercentage * 100))%"
        femaleProgressView.progress = post.femaleApprovalPercentage
        femaleProgressView.progressTintColor = setProgressViewColor(post.femaleApprovalPercentage)

        
        
        
        var img: UIImage?
        if let imagePath = post.imagePath {
            img = PostListVC.imageCache.objectForKey(imagePath) as? UIImage
            self.postImg.progressIndicatorView.reveal()

        }
        if img != nil {
            self.postImg.image = img
        } else {
            let request = DataService.ds.REF_STORAGE.reference().child(post.imagePath!)
            let downloadTask = request.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    let img = UIImage(data: data!)
                    self.postImg.image = img
                    self.postImg.progressIndicatorView.reveal()
                    PostListVC.imageCache.setObject(img!, forKey: self.post.imagePath!)
                }
            }
            
            downloadTask.observeStatus(.Progress) { snapshot in
                // Upload reported progress
                if let progress = snapshot.progress {
                    print("this is progress \(CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount))")
                    let progression = CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount)
                    if !progression.isNaN {
                        self.postImg.progressIndicatorView.progress = CGFloat(progression)

                    }
                }
            }
            
        }


    }
    
  

  
    @IBAction func goBackBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)

    }

 

}
