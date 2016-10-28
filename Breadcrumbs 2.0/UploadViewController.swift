import Foundation
import UIKit

class UploadViewController: UIViewController,CLUploaderDelegate
{
    @IBOutlet weak var capturedImage: UIImageView!
    var Cloudinary:CLCloudinary!
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capturedImage.image = image
//        image = UIImage(named: "Friends")
//        capturedImage.image = UIImage(named: "Friends")
        Cloudinary = CLCloudinary(url: "cloudinary://645121525236522:HQ90xZWm0Dt0w2UzIcSLtjhG5CA@dufz2rmju")
//        Cloudinary.config().setValue("dufz2rmju", forKey: "cloud_name")
//        Cloudinary.config().setValue("645121525236522", forKey: "api_key")
//        Cloudinary.config().setValue("HQ90xZWm0Dt0w2UzIcSLtjhG5CA", forKey: "api_secret")

    }
    
    @IBAction func uploadItem(sender: AnyObject) {
        let fileId = "Friends"
        uploadToCloudinary(fileId: fileId)
    }
    
    func uploadDetailsToServer(fileId:String){
        print("implement add picture id \(fileId) to Firebase")
    }
    
    func uploadToCloudinary(fileId:String){
//        let forUpload = UIImagePNGRepresentation(self.image!)! as Data
        let forUpload = UIImageJPEGRepresentation(self.image!, 0.3)! as Data
        let uploader = CLUploader(Cloudinary, delegate: self)
        
//        uploader?.upload(forUpload, options: ["public_id":fileId])

        uploader?.upload(forUpload, options: ["public_id":fileId], withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
        
    }
    
    func onCloudinaryCompletion(successResult:[AnyHashable : Any]?, errorResult:String?, code:Int, idContext:Any?) {
        print(successResult?.values)
        print(code)
        print(errorResult)
        let fileId = successResult?["public_id"] as! String
        
        uploadDetailsToServer(fileId: fileId)
    }
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:Any?) {
        //do any progress update you may need
        print("bytes written: \(bytesWritten)")
        print("total bytes written \(totalBytesWritten)")
        print("total bytes expected to write \(totalBytesExpectedToWrite)")
    }
    
    func setImage(img:UIImage!){
        image = img
    }
    
}
