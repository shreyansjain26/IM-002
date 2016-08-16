//
//  ViewController.swift
//  ImgDownloader
//
//  Created by Shreyans Jain on 08/08/16.
//  Copyright © 2016 sj. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLSessionDownloadDelegate {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urlBox: UITextField!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressPercentage: UILabel!
    
    var task : NSURLSessionTask!
    var src : String!
    var percentageWritten: Float = 0.0
    var taskTotalBytesWritten = 0
    var taskTotalBytesExpectedToWrite = 0
    
    lazy var session : NSURLSession = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.allowsCellularAccess = false
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        return session
    }()
    
    override func viewDidLoad() {
        progressBar.setProgress(0.0, animated: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func downloadButtonTapped(sender: AnyObject) {
        progressPercentage.text = "0%"
        progressBar.progress = 0.0
        if self.task != nil {
            return
        }
        
        src = urlBox.text
        let url = NSURL(string:src!)!
        let req = NSMutableURLRequest(URL:url)
        let task = self.session.downloadTaskWithRequest(req)
        self.task = task
        task.resume()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten writ: Int64, totalBytesExpectedToWrite exp: Int64) {
        print("downloaded \(100*writ/exp)")
        taskTotalBytesWritten = Int(writ)
        taskTotalBytesExpectedToWrite = Int(exp)
        percentageWritten = Float(taskTotalBytesWritten)/Float(taskTotalBytesExpectedToWrite)
        progressBar.progress = percentageWritten
        progressPercentage.text = String(format: "%.01f", percentageWritten*100) + "%"
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("completed: error: \(error)")
    }
   
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        
        let filename = (self.src as NSString).lastPathComponent
        let file_extension = (self.src as NSString).pathExtension
        print(file_extension)
        print(filename)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        let fileManager = NSFileManager.defaultManager()
        let documents = try! fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent(filename)
        print(fileURL)
        do {
            try fileManager.moveItemAtURL(location, toURL: fileURL)
        } catch {
            print(error)
        }
        
        let imageExtensions:[String] = ["jpg","jpeg","png","gif","xmf"]
        if imageExtensions.indexOf(file_extension) != nil{
            print("Image Found")
            let data = NSData(contentsOfURL: fileURL)
            imageView.image = UIImage(data: data!)
        }
        
    }


}