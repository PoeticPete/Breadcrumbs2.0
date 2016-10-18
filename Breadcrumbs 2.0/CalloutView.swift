//
//  CalloutView.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/17/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class CalloutView: UIView {

    
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var upOutlet: UIButton!
    @IBOutlet weak var downOutlet: UIButton!
    
    @IBAction func upTapped(_ sender: AnyObject) {
        print("tapped up")
        upOutlet.tintColor = UIColor.blue
        
    }
    
    @IBAction func downTapped(_ sender: AnyObject) {
        print("tapped down")
        downOutlet.tintColor = UIColor.blue
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
