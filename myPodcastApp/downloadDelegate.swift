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
        print("Finished downloading to \(location).")
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = AppService.downloadService.activeDownloads[sourceURL]
        AppService.downloadService.activeDownloads[sourceURL] = nil
        // 2
        let destinationURL = AppService.util.localFilePath(for: sourceURL)
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        let cod_resumo = download?.resumo.cod_resumo
        //Mark downloading as 0 and downloaded as 1
        AppService.util.markResumoDownloadField(cod_resumo: cod_resumo!, downloaded: true)
        AppService.util.changeMarkResumoDownloading(cod_resumo: cod_resumo!)    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
            let download = AppService.downloadService.activeDownloads[url]  else { return }
        
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        
        // marcar progress no BD
        let resumoUpdate = AppService.realm().objects(ResumoEntity.self).filter("cod_resumo = %@", download.resumo.cod_resumo).first
        
        try! AppService.realm().write {
            
            resumoUpdate?.progressDownload = download.progress
            
            AppService.realm().add((resumoUpdate)!, update: true)
            
            NSLog("progress resumo %@", resumoUpdate!.cod_resumo as String)
        }
    }
}
