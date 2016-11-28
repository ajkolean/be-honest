//
//  PostList.swift
//  Be-Honest
//
//  Created by admin on 8/14/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PostListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    static var imageCache = NSCache<AnyObject, AnyObject>()


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let userId = UserDefaults.standard.value(forKey: KEY_UID) as? String
        DataService.ds.REF_POSTS.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observe(.value, with: { snapshot in
            
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var img: UIImage?
        let post = posts[indexPath.row]
        if let imagePath = post.imagePath {
            img = PostListVC.imageCache.object(forKey: imagePath as AnyObject) as? UIImage
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            if let dlTask = cell.downloadTask {
                dlTask.cancel()
            }
            cell.confgureCell(post, img: img)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        performSegue(withIdentifier: "PostDetailVC", sender: post)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostDetailVC" {
            if let detailsVC = segue.destination as? PostDetailVC {
                if let post = sender as? Post {
                    detailsVC.post = post
                }
            }
        }
        
    }
    

    
    
    
    



}

