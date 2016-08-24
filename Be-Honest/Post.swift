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
        var _question: String!
        var _ratings: Int?
        var _likes: Int?
        var _maleLikes: Int?
        var _femaleLikes: Int?
        
        var postId: String {
            return _postId
        }
        
        var imagePath: String? {
            return _imagePath
        }
        

    
        var question: String {
            return _question
        }
        
        var ratings: Int {
            return _ratings!
        }
        
        
        var likes: Int {
            return _likes!
        }
        
        var maleLikes: Int {
            return _maleLikes!
        }
        
        var femaleLikes: Int {
            return _femaleLikes!
        }
        
        
        
        init(postId: String, dictionary: Dictionary<String, AnyObject>) {
            super.init()
            _postId = postId
            
            _question = dictionary["question"] as? String
            
            if let imgPath = dictionary["imagePath"] as? String {
                _imagePath = imgPath
            }
            
          
            if let ratings = dictionary["ratings"] as? Int {
                _ratings = ratings
            } else {
                _ratings = 0
            }
            if let likes = dictionary["likes"] as? Int{
                _likes = likes
            } else {
                _likes = 0
            }
            if let maleLikes = dictionary["maleLikes"] as? Int {
                _maleLikes = maleLikes
            } else {
                _maleLikes = 0
            }
            if let femaleLikes = dictionary["femaleLikes"] as? Int {
                _femaleLikes = femaleLikes
            } else {
                _femaleLikes = 0
            }
        }
    }
