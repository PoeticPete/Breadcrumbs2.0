//
//  CalloutView.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/17/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class CalloutView: UIView {

    @IBOutlet weak var upOutlet: DOFavoriteButton!
    @IBOutlet weak var downOutlet: DOFavoriteButton!
    
    @IBAction func upTapped(_ sender: AnyObject) {
        if !upOutlet.isSelected {
            upOutlet.select()
        } else {
            upOutlet.deselect()
        }
    }
    
    @IBAction func downTapped(_ sender: AnyObject) {
        if !downOutlet.isSelected {
            downOutlet.select()
        } else {
            downOutlet.deselect()
        }
    }
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("Passing all touches to the next view (if any), in the view stack.")
        return true
    }
    
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
