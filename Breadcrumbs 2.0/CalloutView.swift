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
    var key:String!
    var annotation:CustomAnnotation!
    
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
            vote(-1)
            annotation.upVotes = annotation.upVotes - 1
            
        } else {
            upOutlet.tintColor = UIColor.blue
            currLikes += 1
            vote(1)
            annotation.upVotes = annotation.upVotes + 1
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
            vote(1)
            annotation.upVotes = annotation.upVotes + 1
            
        } else {
            downOutlet.tintColor = UIColor.blue
            currLikes -= 1
            vote(-1)
            annotation.upVotes = annotation.upVotes - 1
        }
        upvotesLabel.text = "\(currLikes)"
        downSelected = !downSelected

    }
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
//    init() {
//        if myVotes[key] == 1 {
//            upSelected = true
//            upOutlet.tintColor = UIColor.blue
//        } else if myVotes[key] == -1 {
//            downSelected = true
//            upOutlet.tintColor = UIColor.lightGray
//        }
//    }
    
    func vote(_ i: Int) {
        allPostsRef.child(key).child("upVotes").runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
            var value = currentData.value as? Int
            if value == nil {
                value = 0
            }
            currentData.value = value! + i
            return FIRTransactionResult.success(withValue: currentData)
        }
        myVotesRef.child(deviceID).child(key).setValue(i)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    

}
