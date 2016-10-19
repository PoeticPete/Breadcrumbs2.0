//
//  ProfileViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Mike Keegan on 10/18/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var crumbsTableView: UITableView!
    @IBOutlet weak var profileDescriptionView: UIView!

    @IBOutlet weak var statsLabel: UILabel!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    //@IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    let maxHeaderHeight: CGFloat = 88;
    let minHeaderHeight: CGFloat = 44;
    var previousScrollOffset: CGFloat = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statsLabel.adjustsFontSizeToFitWidth = true
        // somehow the profileDescriptView's height was 1000, changed below
        profileDescriptionView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 100.0)
        crumbsTableView.tableHeaderView = profileDescriptionView
        //crumbsTableView.contentInset = UIEdgeInsetsMake(-500, 0, 0, 0);
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.headerHeight.constant = self.maxHeaderHeight
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        // Calculate new header height
        var newHeight = self.headerHeight.constant
        if isScrollingDown {
            newHeight = max(self.minHeaderHeight, self.headerHeight.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(self.maxHeaderHeight, self.headerHeight.constant + abs(scrollDiff))
        }
        
        // Header needs to animate
        if newHeight != self.headerHeight.constant {
            self.headerHeight.constant = newHeight
            self.updateHeader()
            self.setScrollPosition(position: self.previousScrollOffset)
        }
        
        self.previousScrollOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeight.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeight.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeight.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func setScrollPosition(position: CGFloat) {
        self.crumbsTableView.contentOffset = CGPoint(x: self.crumbsTableView.contentOffset.x, y: position)
    }
    
    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeight.constant - self.minHeaderHeight
        let percentage = openAmount / range
        
        //self.titleTopConstraint.constant = -openAmount + 10
        self.profilePic.alpha = percentage
    }

    
    //Table view methods:
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.crumbsTableView.dequeueReusableCell(withIdentifier: "ProfCell") as! ProfileTableViewCell
        cell.changeTitle(newTitle: "Cell \(indexPath.row)")
        cell.changeDescription(newDesc: "test description yo! this is a really long line that will need a line break, so let's make sure that works! long descriptions should not be allowed in the final project. possibly character limit.")
        cell.changeLocation(newLocation: "Some GPS Coordinates or location name that the person put in")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
//        return CGFloat.leastNormalMagnitude
    }
    
    //end table view methods

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
