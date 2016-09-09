//
//  PostCell.swift
//  Be-Honest
//
//  Created by admin on 8/15/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit
import FirebaseStorage

class PostCell: UITableViewCell {

    @IBOutlet weak var postImg: CustomImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBar: CustomProgressView!
    
    var post: Post!
    var request: FIRStorageReference?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func drawRect(rect: CGRect) {
        postImg.layer.cornerRadius = 15.0
        postImg.clipsToBounds = true
    }
    
    func confgureCell(post: Post, img: UIImage?) {
        self.post = post
        titleLabel.text = post.question
        
        progressBar.progress = post.approvalPercentage
        progressBar.progressTintColor = setProgressViewColor(post.approvalPercentage)

        if post.imagePath != nil {
            print("IMAGE PATH: \(post.imagePath!)")
            if img != nil {
                self.postImg.image = img
            } else {
                request = DataService.ds.REF_STORAGE.reference().child(post.imagePath!)
                let status = request!.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print(error)
                    } else {
                        let img = UIImage(data: data!)
                        self.postImg.image = img
                        self.postImg.progressIndicatorView.reveal()
                        SecondViewController.imageCache.setObject(img!, forKey: post.imagePath!)
                    }
                }
                
                
                
                status.observeStatus(.Progress) { snapshot in
                    // Upload reported progress
                    if let progress = snapshot.progress {
                        print("this is progress \(CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount))")
                        self.postImg.progressIndicatorView.progress = CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount)
                    }
                }
            }
            
        }
        
    }

  

}
