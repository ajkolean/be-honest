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
        var _image: UIImage = UIImage(named: "defaultavatar")!
        var _question: String!
        var _ratings: Int = 0
        var _likes: Int = 0
        var _maleLikes: Int = 0
        var _femaleLikes: Int = 0
        var _femaleRatings: Int = 0
        var _maleRatings: Int = 0
        
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
            return _ratings
        }
        
        
   
        
        var approvalPercentage: Float {
            if _ratings == 0 {
                return 0
            } else {

                return Float(_likes) / Float(_ratings)
            }
        }
        
        var maleApprovalPercentage: Float {
            if _maleRatings == 0 {
                return 0
            } else {
                return Float(_maleLikes) / Float(_maleRatings)
            }
        }
        
        var femaleApprovalPercentage: Float {
            if _femaleRatings == 0 {
                return 0
            } else {
                return Float(_femaleLikes) / Float(_femaleRatings)
            }
        }
        
        init(postId: String, question: String, imageName: String) {
            super.init()
            _postId = postId
            _question = question
            _image = UIImage(named: "gender-signs")!
        }
        
        
        init(postId: String, dictionary: Dictionary<String, AnyObject>) {
            super.init()
            _postId = postId
            _question = dictionary["question"] as? String
            
            if let imgPath = dictionary["imagePath"] as? String {
                _imagePath = imgPath
            }
            print(dictionary["ratings"] as? Dictionary< String, Dictionary<String, AnyObject>>)
            
            
            
            
            if let ratings = dictionary["ratings"] as? Dictionary< String, Dictionary<String, AnyObject>> {
                print("start of ratings")
                print(ratings)
                
                
              
                for (_, r) in ratings {
                    if let liked = r["likedit"] as? Bool {

                        if (liked) {
                            _likes += 1
                            if let gender = r["gender"] as? String {
                                if gender == "male" {
                                    _maleLikes += 1
                                } else {
                                    _femaleLikes += 1
                                }
                            }

                        }
                        if let gender = r["gender"] as? String {
                            if gender == "male" {
                                _maleRatings += 1
                            } else {
                                _femaleRatings += 1
                            }
                        }
                    }
                   
                }
                print(ratings.count)
                if ratings.count >= 0 {
                    _ratings = ratings.count
                }
            }
            
        
        }
        
    
    }
