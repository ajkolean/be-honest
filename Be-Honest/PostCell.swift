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
    
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var faceImg: UIImageView!
    
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
        let approval = (post.likes * 100)/post.ratings
        
        progressBar.progress = Float(approval) / 100
        progressBar.progressTintColor = setProgressViewColor(approval)

        if post.imagePath != nil {
            print("IMAGE PATH: \(post.imagePath!)")
            if img != nil {
                self.postImg.image = img
            } else {
                request = DataService.ds.REF_STORAGE.reference().child(post.imagePath!)
                request!.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print(error)
                    } else {
                        let img = UIImage(data: data!)
                        self.postImg.image = img
                        SecondViewController.imageCache.setObject(img!, forKey: post.imagePath!)
                    }
                }
            }
            
        }
        
    }

  

}
