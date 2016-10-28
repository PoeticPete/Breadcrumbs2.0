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
    var annotation:CustomAnnotation!
    
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var upOutlet: UIButton!
    @IBOutlet weak var downOutlet: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    
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
            myVotes[annotation.key] = nil
            myVotesRef.child(deviceID).child(annotation.key).removeValue()
        } else {
            upOutlet.tintColor = getColor(Int(upvotesLabel.text!)!)
            currLikes += 1
            vote(1)
            annotation.upVotes = annotation.upVotes + 1
            myVotes[annotation.key] = 1
            myVotesRef.child(deviceID).child(annotation.key).setValue(1)
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
            myVotes[annotation.key] = nil
            myVotesRef.child(deviceID).child(annotation.key).removeValue()
        } else {
            downOutlet.tintColor = getColor(Int(upvotesLabel.text!)!)
            currLikes -= 1
            vote(-1)
            annotation.upVotes = annotation.upVotes - 1
            myVotes[annotation.key] = -1
            myVotesRef.child(deviceID).child(annotation.key).setValue(-1)
        }
        upvotesLabel.text = "\(currLikes)"
        downSelected = !downSelected

    }
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var commentsButton: UIButton!

    
    
    func vote(_ i: Int) {
        allPostsRef.child(annotation.key).child("upVotes").runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
            var value = currentData.value as? Int
            if value == nil {
                value = 0
            }
            currentData.value = value! + i
            return FIRTransactionResult.success(withValue: currentData)
        }
        
    }


}
