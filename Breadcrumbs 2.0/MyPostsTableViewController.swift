//
//  MyPostsTableViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/30/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import Firebase

class MyPostsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    
    var myPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getMyPostsAndRefresh()
    }
    
    func getMyPostsAndRefresh() {
        print("Getting posts and refreshing")
        myPosts.removeAll()
        myPostsRef.observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
            for child in snapshot.children {
                let childSnap = child as! FIRDataSnapshot
                allPostsRef.child(childSnap.key).observeSingleEvent(of: FIRDataEventType.value, with: { postSnap in
                    var message:String!
                    var timestamp:NSDate!
                    var upVotes:Int!
                    var hasPicture:Bool!
                    if let m = postSnap.childSnapshot(forPath: "message").value as? String {
                        message = m
                    }
                    if let t = postSnap.childSnapshot(forPath: "timestamp").value as? TimeInterval {
                        timestamp = NSDate(timeIntervalSince1970: t/1000)
                    }
                    if let uv = postSnap.childSnapshot(forPath: "upVotes").value as? Int {
                        upVotes = uv
                    }
                    if postSnap.childSnapshot(forPath: "hasPicture").exists() {
                        if let hp = postSnap.childSnapshot(forPath: "hasPicture").value as? Bool {
                            hasPicture = hp
                        }
                    } else {
                        hasPicture = false
                    }
//                    print("\(message) \(timestamp) \(upVotes) \(hasPicture)")
                    
                    if message != nil && timestamp != nil && upVotes != nil && hasPicture != nil {
                        var newPost = Post(key: childSnap.key, message: message, upVotes: upVotes, timestamp: timestamp, hasPicture: hasPicture)
                        self.myPosts.append(newPost)
                        self.table.reloadData()
                    }
                })
                
            }
        })
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "MyTextPostCell") as! MyTextPostTableViewCell
        cell.textPostLabel.text = myPosts[indexPath.row].message
        return cell
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
