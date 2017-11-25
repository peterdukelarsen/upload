//
//  ViewController.swift
//  upload
//
//  Created by Peter Larsen on 11/15/17.
//  Copyright © 2017 Peter Larsen. All rights reserved.
//

import UIKit
import AWSS3

let squirrelUrl = "https://s3.amazonaws.com/luminary-public-resources/ucberkley.jpg"
class ViewController: UIViewController {
    var transferManager = AWSS3TransferManager.s3TransferManager(forKey: "us-east")
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadTest()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func downloadTest() -> Void {
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("myImage.jpg")
        // AppDelegate runs after ViewController is initialized, so needed to re-init the transfer manager
        transferManager = AWSS3TransferManager.s3TransferManager(forKey: "us-east")
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest!.bucket = "luminary-common-storage"
        downloadRequest!.key = "thing.png"
        downloadRequest!.downloadingFileURL = downloadingFileURL
        transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        print("cancelled or paused")
                        break
                    default:
                        print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                    }
                } else {
                    print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                }
                return nil
            }
            print("Download complete for: \(downloadRequest?.key ?? "thing")")
            let downloadOutput = task.result as! AWSS3TransferManagerDownloadOutput
            let fileUrl: URL = downloadOutput.body as! URL
            
            
            let image: UIImage? = UIImage(data: NSData(contentsOf: fileUrl)! as Data)
            let imageView = UIImageView(image: image)
            self.view.addSubview(imageView)
            return nil
        })
    }
}
