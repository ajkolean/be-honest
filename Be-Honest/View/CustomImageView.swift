//
//  CustomImageView.swift
//  Be-Honest
//
//  Created by admin on 9/6/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit


class CustomImageView: UIImageView {
    
    let progressIndicatorView = CircularLoaderView(frame: CGRect.zero)
    
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(self.progressIndicatorView)
        progressIndicatorView.frame = bounds
        progressIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    }
    
  
 
  
    
}
