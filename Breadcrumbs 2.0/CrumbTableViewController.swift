//
//  CrumbTableViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/28/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class CrumbTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    var annotation:CustomAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.estimatedRowHeight = 80
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        print(annotation)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if annotation.hasPicture == true {
            let w = Double(annotation.picture!.size.width)
            let h = Double(annotation.picture!.size.height)
            if indexPath.row == 0 && w < h {
                return 400.0
            } else {
                return 100.0
            }
        } else {
            if indexPath.row == 0 {
                return 300.0
            } else {
                return 100.0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if annotation.hasPicture == true && indexPath.row == 0 {
            let cell = table.dequeueReusableCell(withIdentifier: "PhotoCrumbCell") as! PhotoCrumbTableViewCell
            cell.photo.image = annotation.picture
            return cell
        } else if annotation.hasPicture == false && indexPath.row == 0{
            let cell = table.dequeueReusableCell(withIdentifier: "CrumbCell") as! CrumbTableViewCell
            cell.postLabel.text = annotation.message
            return cell
        } else {
            // comments
            let cell = table.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
            return cell
        }
       
    }

    

}
