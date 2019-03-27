//
//  InicioVC+URLSessionDelegates.swift
//  myPodcastApp
//
//  Created by William on 27/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import UIKit

extension InicioViewController: URLSessionDownloadDelegate {
    // Stores downloaded file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = AppService.downloadService.activeDownloads[sourceURL]
        AppService.downloadService.activeDownloads[sourceURL] = nil
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectoryURL.appendingPathComponent(sourceURL.lastPathComponent)
        
        print(destinationURL)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            let resumoeEntities = AppService.realm().objects(ResumoEntity.self).filter("cod_resumo = %@", download!.resumo.cod_resumo)
            guard let resumoEntity = resumoeEntities.first else {
                print("Resumo not found")
                return
            }
            try! self.realm.write {
                resumoEntity.downloaded = 1
            }
        } catch AppError.writeError {
            
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        //        // 4
        //        if let index = download?.resumo.co {
        //            DispatchQueue.main.async {
        //                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        //            }
        //        }
    }
    
    // Updates progress info
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        
        //        // 1
        //        guard let url = downloadTask.originalRequest?.url,
        //            let download = AppService.downloadService.activeDownloads[url]  else { return }
        //        // 2
        //        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        //        // 3
        //        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
        //                                                  countStyle: .file)
        //        // 4
        //        DispatchQueue.main.async {
        //            if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.track.index,
        //                                                                       section: 0)) as? TrackCell {
        //                trackCell.update(progress: download.progress)
        //            }
        //        }
    }
}

extension InicioViewController: URLSessionDelegate {
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

