//
//  ChoosePostVC.swift
//  Be-Honest
//
//  Created by admin on 8/15/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit
import MDCSwipeToChoose
import Firebase
import FirebaseDatabase

class ChoosePostVC: UIViewController, MDCSwipeToChooseDelegate {

    @IBOutlet weak var likeBtn: UIImageView!
    
    var posts:[Post] = []
    let ChoosePostButtonHorizontalPadding:CGFloat = 80.0
    let ChoosePostButtonVerticalPadding:CGFloat = 20.0
    var currentPost:Post!
    var frontCardView:ChoosePostView!
    var backCardView:ChoosePostView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // Here you can init your properties
    }
    
    func getPosts() {
        if (LoginVC.gender == "") {
            let newPost = Post(postId: "gender", question: "Do you identify as a Male?", imageName: "gender-signs")
            self.posts.append(newPost)
        }
        if self.posts.count > 3 {
            return;
        }
        
        DataService.ds.REF_POSTS.queryOrderedByChild("numRatings").queryStartingAtValue(true).queryLimitedToFirst(10).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                outer: for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        print(snap)
                        if postDict["userId"] as? String == LoginVC.userId{
                            continue
                        }
                        if let raterDict = postDict["ratings"] as? Dictionary<String, Dictionary<String, AnyObject>> {
                            for (_, ratingEntry) in raterDict {
                                if let id = ratingEntry["userId"] as? String {
                                    if id == LoginVC.userId {
                                        continue outer
                                    }
                                }
                            }
                         
                        }
                    

                        for post in self.posts {
                            if post.postId == snap.key {
                                continue outer
                            }
                        }
                        if (self.frontCardView != nil && self.currentPost.postId == snap.key) {
                            continue outer
                        }
                        if (self.backCardView != nil && self.backCardView.post.postId == snap.key) {
                            continue outer
                        }
                  
                        let key = snap.key
                        let post = Post(postId: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                    
                }
            }
            
            print(self.posts)
            
            
            // Display the first ChoosePersonView in front. Users can swipe to indicate
            // whether they like or dislike the person displayed.
            if self.posts.count > 0 && self.frontCardView == nil {
                self.setMyFrontCardView(self.popPostViewWithFrame(self.frontCardViewFrame())!)
                self.view.addSubview(self.frontCardView)
            }
            
            
            // Display the second ChoosePersonView in back. This view controller uses
            // the MDCSwipeToChooseDelegate protocol methods to update the front and
            // back views after each user swipe.
            if self.posts.count > 0 && self.frontCardView != nil && self.backCardView == nil{
                self.backCardView = self.popPostViewWithFrame(self.backCardViewFrame())!
                self.view.insertSubview(self.backCardView, belowSubview: self.frontCardView)
            }
      
            
            
        })
    }
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Add buttons to programmatically swipe the view left or right.
        // See the `nopeFrontCardView` and `likeFrontCardView` methods.
     
        
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(ChoosePostVC.getPosts), userInfo: nil, repeats: true)

        getPosts()
        



    }
    func suportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    // This is called when a user didn't fully swipe left or right.
    func viewDidCancelSwipe(view: UIView) -> Void{
        
        print("You couldn't decide on \(self.currentPost.question)", terminator: "");
    }
    
    // This is called then a user swipes the view fully left or right.
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{
        
        // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
        // and "LIKED" on swipes to the right.
        var rating: Dictionary<String, AnyObject>
        if (self.currentPost.postId == "gender") {
            if(wasChosenWithDirection == MDCSwipeDirection.Left){
                NSUserDefaults.standardUserDefaults().setValue("female", forKey: "gender")
                LoginVC.gender = "female"
                
            } else{
                
                NSUserDefaults.standardUserDefaults().setValue("male", forKey: "gender")
                LoginVC.gender = "male"

            }
            
            
        } else {
            if(wasChosenWithDirection == MDCSwipeDirection.Left){
                print("You noped: \(self.currentPost.question)")
                rating = ["userId": LoginVC.userId,
                          "gender": LoginVC.gender,
                          "likedit": false]
                
            } else{
                
                print("You liked: \(self.currentPost.question)")
                rating = ["userId": LoginVC.userId,
                          "gender": LoginVC.gender,
                          "likedit": true]
            }
            
            DataService.ds.REF_POSTS.child(self.currentPost.postId).child("ratings").childByAutoId().setValue(rating)
            DataService.ds.REF_POSTS.child(self.currentPost.postId).child("numRatings").setValue(self.currentPost.ratings + 1)
        }
        
      
        // MDCSwipeToChooseView removes the view from the view hierarchy
        // after it is swiped (this behavior can be customized via the
        // MDCSwipeOptions class). Since the front card view is gone, we
        // move the back card to the front, and create a new back card.
        if(self.backCardView != nil){
            self.setMyFrontCardView(self.backCardView)
        }
        
        backCardView = self.popPostViewWithFrame(self.backCardViewFrame())
        //if(true){
        // Fade the back card into view.
        if(backCardView != nil){
            self.backCardView.alpha = 0.0
            self.view.insertSubview(self.backCardView, belowSubview: self.frontCardView)
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.backCardView.alpha = 1.0
                },completion:nil)
        }
    }
    func setMyFrontCardView(frontCardView:ChoosePostView) -> Void{
        
        // Keep track of the person currently being chosen.
        // Quick and dirty, just for the purposes of this sample app.
        self.frontCardView = frontCardView
        self.currentPost = frontCardView.post
    }
    

    func popPostViewWithFrame(frame:CGRect) -> ChoosePostView?{
        if(self.posts.count == 0){
            return nil;
        }
        
        // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
        // Each take an "options" argument. Here, we specify the view controller as
        // a delegate, and provide a custom callback that moves the back card view
        // based on how far the user has panned the front card view.
        let options:MDCSwipeToChooseViewOptions = MDCSwipeToChooseViewOptions()
        options.delegate = self
        //options.threshold = 160.0
        options.onPan = { state -> Void in
            if(self.backCardView != nil){
                let frame:CGRect = self.frontCardViewFrame()
                self.backCardView.frame = CGRectMake(frame.origin.x, frame.origin.y-(state.thresholdRatio * 10.0), CGRectGetWidth(frame), CGRectGetHeight(frame))
            }
        }
        
        // Create a personView with the top person in the people array, then pop
        // that person off the stack.
        
        let postView:ChoosePostView = ChoosePostView(frame: frame, post: self.posts[0], options: options)
        self.posts.removeAtIndex(0)
        return postView
        
    }
    func frontCardViewFrame() -> CGRect{
        let horizontalPadding:CGFloat = 20.0
        let topPadding:CGFloat = 60.0
        let bottomPadding:CGFloat = 200.0
        return CGRectMake(horizontalPadding,topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding * 2), CGRectGetHeight(self.view.frame) - bottomPadding)
    }
    func backCardViewFrame() ->CGRect{
        let frontFrame:CGRect = frontCardViewFrame()
        return CGRectMake(frontFrame.origin.x, frontFrame.origin.y + 10.0, CGRectGetWidth(frontFrame), CGRectGetHeight(frontFrame))
    }

    func nopeFrontCardView() -> Void{
        self.frontCardView.mdc_swipe(MDCSwipeDirection.Left)
    }
    func likeFrontCardView() -> Void{
        self.frontCardView.mdc_swipe(MDCSwipeDirection.Right)
    }

    @IBAction func likeBtnPressed(sender: AnyObject) {
        if (self.frontCardView != nil) {
            likeFrontCardView()
        }
        
    }
    
    @IBAction func dislikeBtnPressed(sender: AnyObject) {
        if (self.frontCardView != nil) {
            nopeFrontCardView()
        }
        
    }

}
