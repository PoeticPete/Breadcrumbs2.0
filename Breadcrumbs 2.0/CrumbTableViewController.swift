//
//  CrumbTableViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/28/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import Firebase

class CrumbTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var table: UITableView!
    var annotation:CustomAnnotation!
    var comments = [Comment]()
    var keyboardHeight:CGFloat!
    var newCommentField: UITextView!
    var characterLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(CrumbTableViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        getComments()
        print(annotation)
    }

    func getComments() {
        commentsRef.child(annotation.post.key).observeSingleEvent(of: .value, with: { commentsSnap in
            print(commentsSnap)
            for child in commentsSnap.children {
                let childSnap = child as! FIRDataSnapshot
                let message = childSnap.childSnapshot(forPath: "message").value! as! String
                let timestamp = childSnap.childSnapshot(forPath: "timestamp").value as! TimeInterval
                let date = NSDate(timeIntervalSince1970: timestamp/1000)
                var upVotes = 0
                if childSnap.childSnapshot(forPath: "upVotes").exists() {
                    upVotes = childSnap.childSnapshot(forPath: "upVotes").value! as! Int
                }
                self.comments.append(Comment(message: message, upVotes: upVotes, timestamp: date))
            }
            self.table.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if annotation.post.hasPicture == true {
            let w = Double(annotation.post.picture!.size.width)
            let h = Double(annotation.post.picture!.size.height)
            if indexPath.row == 0 && w < h {
                return 400.0
            } else if indexPath.row == comments.count + 1 {
                return 130.0
            }
            else {
                return 100.0
            }
        } else {
            if indexPath.row == 0 {
                return 300.0
            } else if indexPath.row == comments.count + 1 {
                return 130.0
            } else {
                return 100.0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if annotation.post.hasPicture == true && indexPath.row == 0 {
            let cell = table.dequeueReusableCell(withIdentifier: "PhotoCrumbCell") as! PhotoCrumbTableViewCell
            cell.photo.image = annotation.post.picture
            return cell
        } else if annotation.post.hasPicture == false && indexPath.row == 0{
            let cell = table.dequeueReusableCell(withIdentifier: "CrumbCell") as! CrumbTableViewCell
            cell.postLabel.text = annotation.post.message
            return cell
        } else if indexPath.row == comments.count + 1 {
            let cell = table.dequeueReusableCell(withIdentifier: "NewCommentCell") as! NewCommentTableViewCell
            cell.textView.delegate = self
            cell.textView.textColor = UIColor.lightGray
            self.newCommentField = cell.textView
            cell.sendButton.addTarget(self, action: #selector(CrumbTableViewController.sendTapped), for: UIControlEvents.touchUpInside)
            cell.cancelButton.addTarget(self, action: #selector(CrumbTableViewController.cancelTapped), for: UIControlEvents.touchUpInside)
            characterLabel = cell.characterLabel
            // (self, action: #selector(ViewController.toCrumbTableView), for: UIControlEvents.touchUpInside)
            return cell
            
        } else {
            // comments
            let cell = table.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
            cell.messageLabel.text = comments[indexPath.row - 1].message
            return cell
        }
       
    }
    
    func sendTapped() {
        print("Send tapped")
        if newCommentField.text == "New comment" || newCommentField.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            return
        }
        
        
        let comRef = commentsRef.child(annotation.post.key).childByAutoId()
        comRef.child("message").setValue(newCommentField.text)
        comRef.child("timestamp").setValue(firebaseTimeStamp)
        comRef.child("deviceID").setValue(deviceID)
        print("adding comment to \(comRef)")
        print(newCommentField.text)
        
        newCommentField.text = ""
        self.view.endEditing(true)
    }
    
    func cancelTapped() {
        print("cancel tapped")
        newCommentField.text = ""
        self.view.endEditing(true)
    }
    
    func moveTable(height: CGFloat, up: Bool)
    {
        let movementDistance:CGFloat = -180
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("began editing")
        print(textView.textColor == UIColor.lightGray)
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("end editting")
        if textView.text.isEmpty {
            textView.text = "New comment"
            textView.textColor = UIColor.lightGray
        }
        self.moveTable(height: keyboardHeight, up:false)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        var charsLeft = 140 - numberOfChars
        if charsLeft < 0 {
            charsLeft = 0
        }
        characterLabel.text = "\(charsLeft)"
        
        return numberOfChars < 141;
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        print(keyboardHeight)
        self.keyboardHeight = keyboardHeight
        self.moveTable(height: keyboardHeight, up: true)
    }
    

}
