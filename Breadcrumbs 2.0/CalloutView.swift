//
//  CalloutView.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/17/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import Firebase

class CalloutView: UIView {

    var upSelected = false
    var downSelected = false
    
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var upOutlet: UIButton!
    @IBOutlet weak var downOutlet: UIButton!
    
    @IBAction func upTapped(_ sender: AnyObject) {
        
        if downSelected {
            return
        }
        
        var currLikes = Int(upvotesLabel.text!)!
        
        if upSelected {
            upOutlet.tintColor = UIColor.lightGray
            currLikes -= 1
        } else {
            upOutlet.tintColor = UIColor.blue
            currLikes += 1
        }
        upvotesLabel.text = "\(currLikes)"
        upSelected = !upSelected
        
        
    }
    
    @IBAction func downTapped(_ sender: AnyObject) {
        if upSelected {
            return
        }
        
        var currLikes = Int(upvotesLabel.text!)!
        if downSelected {
            downOutlet.tintColor = UIColor.lightGray
            currLikes += 1
            
        } else {
            downOutlet.tintColor = UIColor.blue
            currLikes -= 1
        }
        upvotesLabel.text = "\(currLikes)"
        downSelected = !downSelected

    }
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    

}
