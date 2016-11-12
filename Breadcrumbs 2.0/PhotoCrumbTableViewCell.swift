//
//  PhotoCrumbTableViewCell.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/28/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class PhotoCrumbTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var votingView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBAction func photoTapped(_ sender: Any) {
        if votingView.isHidden == true {
            votingView.isHidden = false
            timestampLabel.isHidden = false
        } else {
            votingView.isHidden = true
            timestampLabel.isHidden = true
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        votingView.layer.cornerRadius = 10
        votingView.layer.masksToBounds = true
        timestampLabel.layer.cornerRadius = 10
        timestampLabel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
