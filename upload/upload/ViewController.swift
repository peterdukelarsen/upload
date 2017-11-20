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
    let transferManager = AWSS3TransferManager.s3TransferManager(forKey: "us-east")
    override func viewDidLoad() {
        super.viewDidLoad()
        stuff()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func stuff() -> Void {
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("myImage.jpg")
        
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
            let downloadOutput = task.result
            return nil
        })
    }
}
