//
//  Post.swift
//  Be-Honest
//
//  Created by admin on 8/15/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import Foundation

//class Post: NSObject {
//    
//    let _image: UIImage!
//    let _question: String!
//    
//    var image: UIImage {
//        return _image
//    }
//    
//    var question: String {
//        return _question
//    }
//    
//    init(image: UIImage?, question: String) {
//        _image = image
//        _question = question
//    }

    
    class Post: NSObject {
        
        var _postId: String!
        var _imagePath: String?
        var _image: UIImage!
        var _question: String!
        var _ratings: Int!
        var _likes: Int!
        var _maleLikes: Int!
        var _femaleLikes: Int!
        
        var postId: String {
            return _postId
        }
        
        var imagePath: String? {
            return _imagePath
        }
        
        var image: UIImage {
            return _image
        }
        
        
        var question: String {
            return _question
        }
        
        var ratings: Int {
            return _ratings!
        }
        
        
   
        
        var approvalPercentage: Float {
            if _ratings == 0 {
                return 0
            } else {

                return Float(_likes) / Float(_ratings)
            }
        }
        
        var maleApprovalPercentage: Float {
            if _maleLikes == 0 {
                return 0
            } else if _femaleLikes == 0 {
                return 1.0
            } else {
                return Float(_maleLikes) / Float(_femaleLikes + _maleLikes)
            }
        }
        
        var femaleApprovalPercentage: Float {
            if _femaleLikes == 0 {
                return 0
            } else if _maleLikes == 0 {
                return 1.0
            } else {
                return Float(_femaleLikes) / Float(_femaleLikes + _maleLikes)
            }
        }
        
        init(postId: String, dictionary: Dictionary<String, AnyObject>) {
            super.init()
            _postId = postId
            _image = UIImage(named: "defaultavatar")
            _question = dictionary["question"] as? String
            
            if let imgPath = dictionary["imagePath"] as? String {
                _imagePath = imgPath
            }
            print(dictionary["ratings"] as? Dictionary< String, Dictionary<String, AnyObject>>)
            
            
            
            
            if let ratings = dictionary["ratings"] as? Dictionary< String, Dictionary<String, AnyObject>> {
                print(ratings)
                _likes = 0
                _maleLikes = 0
                _femaleLikes = 0
                for (_, r) in ratings {
                    if let liked = r["likedit"] as? Bool {

                        if (liked) {
                            _likes! += 1

                        }
                    }
                    if let gender = r["gender"] as? String {
                        if gender == "male" {
                            _maleLikes! += 1
                        } else {
                            _femaleLikes! += 1
                        }
                    }
                }
                print(ratings.count)
                _ratings = ratings.count
            }
            
        
        }
        
    
    }
