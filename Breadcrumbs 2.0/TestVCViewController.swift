//
//  TestVCViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/21/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit


class TestVCViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var img:UIImage?
    
    
    @IBAction func chooseFromGallery(sender: AnyObject) {
        var imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: { imageP in
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func capture(sender : UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            print("Button capture")
            
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.camera;
            imag.mediaTypes = [kUTTypeImage as String]
            imag.allowsEditing = false
            
            self.present(imag, animated: true, completion: nil)
        }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        img = info["UIImagePickerControllerOriginalImage"] as! UIImage
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
//        self.performSegue(withIdentifier: "imageCaptured", sender:self)
        OperationQueue.main.addOperation {
            [weak self] in
            self?.performSegue(withIdentifier: "imageCaptured", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageCaptured" {
            let svc = segue.destination as! UploadViewController
            svc.setImage(img: self.img)
        }
    }
    
    
    
}
