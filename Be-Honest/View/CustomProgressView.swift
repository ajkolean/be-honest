//
//  CustomProgressView.swift
//  Be-Honest
//
//  Created by admin on 8/15/16.
//  Copyright © 2016 ajkolean. All rights reserved.
//

import UIKit

class CustomProgressView: UIProgressView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }

}
