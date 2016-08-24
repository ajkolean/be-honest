//
//  SecondViewController.swift
//  Be-Honest
//
//  Created by admin on 8/14/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    static var imageCache = NSCache()


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String
        DataService.ds.REF_POSTS.queryOrderedByChild("userId").queryEqualToValue(userId).observeEventType(.Value, withBlock: { snapshot in
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        print(postDict)
                        let key = snap.key
                        let post = Post(postId: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                    
                }
            }
            
            self.tableView.reloadData()
            
        })
        

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var img: UIImage?
        let post = posts[indexPath.row]
        if let imagePath = post.imagePath {
            img = SecondViewController.imageCache.objectForKey(imagePath) as? UIImage
        }
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.confgureCell(post, img: img)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 117.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.row]
        performSegueWithIdentifier("PostDetailVC", sender: post)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PostDetailVC" {
            if let detailsVC = segue.destinationViewController as? PostDetailVC {
                if let post = sender as? Post {
                    detailsVC.post = post
                }
            }
        }
        
    }
    

    
    
    
    



}

