//
//  DataService.swift
//  Be-Honest
//
//  Created by admin on 8/23/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class DataService {
    static let ds = DataService()
    private var _REF_BASE = FIRDatabase.database().reference()
    private var _REF_POSTS = FIRDatabase.database().reference().child("posts")
    private var _REF_USERS = FIRDatabase.database().reference().child("users")
    private var _REF_STORAGE = FIRStorage.storage()

    
    
    var REF_BASE : FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    

    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_STORAGE: FIRStorage {
        return _REF_STORAGE
    }
    
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.child(uid).setValue(user)
        
    }
    
    
}