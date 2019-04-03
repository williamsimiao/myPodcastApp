//
//  downloadDelegate.swift
//  myPodcastApp
//
//  Created by William on 03/04/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class downloadDelegate: NSObject, URLSessionDownloadDelegate {
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    func setSession() {
        AppService.downloadService.downloadsSession = downloadsSession
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Concluido isso")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        print("progredindo")
    }
}
