
// Copyright (c) 2014 to present, Richard Burdish @rjburdish
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import MDCSwipeToChoose

class ChoosePostView: MDCSwipeToChooseView {
    
    let ChoosePostViewImageLabelWidth:CGFloat = 42.0;
    var post: Post!
    var informationView: UIView!
    var questionLabel: UILabel!
    
  
    init(frame: CGRect, post: Post, options: MDCSwipeToChooseViewOptions) {
        
        super.init(frame: frame, options: options)
        self.post = post
        self.imageView.image = self.post.image
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit;
        self.imageView.backgroundColor = UIColor.white
        
        if self.post.imagePath != nil {
            let imageRef = DataService.ds.REF_STORAGE.reference().child(self.post.imagePath!)
            imageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    self.contentMode = UIViewContentMode.scaleAspectFill;
                    self.imageView.image = UIImage(data: data!)
                    
                }
            }
            
        }


        
        self.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        UIViewAutoresizing.flexibleBottomMargin
        
        self.imageView.autoresizingMask = self.autoresizingMask
        constructInformationView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    func constructInformationView() -> Void{
        let bottomHeight:CGFloat = 75.0
        let bottomFrame:CGRect = CGRect(x: 0,
                                            y: self.bounds.height - bottomHeight,
                                            width: self.bounds.width,
                                            height: bottomHeight);
        self.informationView = UIView(frame:bottomFrame)
        self.informationView.backgroundColor = UIColor.white
        self.informationView.clipsToBounds = true
        self.informationView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleTopMargin]
        self.addSubview(self.informationView)
        constructQuestionLabel()
       
    }
    
    func constructQuestionLabel() -> Void{
        let leftPadding:CGFloat = 10.0
        let topPadding:CGFloat = 5.0
        let frame:CGRect = CGRect(x: leftPadding,
                                      y: topPadding,
                                      width: floor(self.informationView.frame.width - leftPadding - leftPadding),
                                      height: self.informationView.frame.height - topPadding - topPadding)
        self.questionLabel = UILabel(frame:frame)
        self.questionLabel.lineBreakMode = .byWordWrapping 
        self.questionLabel.numberOfLines = 0
        self.questionLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        self.questionLabel.adjustsFontSizeToFitWidth = true
        self.questionLabel.minimumScaleFactor = 0.5
         self.questionLabel.baselineAdjustment = .alignCenters
        self.questionLabel.textAlignment = .center
        self.questionLabel.text = "\(post.question)"
        self.informationView .addSubview(self.questionLabel)
    }
 
    func buildImageLabelViewLeftOf(_ x:CGFloat, image:UIImage, text:String) -> ImagelabelView{
        let frame:CGRect = CGRect(x:x-ChoosePostViewImageLabelWidth, y: 0,
                                  width: ChoosePostViewImageLabelWidth,
                                  height: self.informationView.bounds.height)
        let view:ImagelabelView = ImagelabelView(frame:frame, image:image, text:text)
        view.autoresizingMask = UIViewAutoresizing.flexibleLeftMargin
        return view
    }
}
