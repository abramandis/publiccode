//
//  ZeroPaddingTextView.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 5/12/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

import UIKit

@IBDesignable class ZeroPaddingTextView: UITextView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
}

@IBDesignable class PaddedTextView: UITextView {
    
    var runOnce = true
    override func layoutSubviews(){
        super.layoutSubviews()
        textContainerInset = UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16)
        if runOnce {
            setContentOffset(.zero, animated: false)
            runOnce = false
        }
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 256.0).isActive = true
    }
    
}

