import Foundation

class DownloadService {
    
    var downloadsSession: URLSession!
    var activeDownloads: [URL: Download] = [:]
    
    func startDownload(_ resumo: Resumo, resumoUrl: URL, tableIndex: Int) {
        let download = Download(resumo: resumo)
        download.task = downloadsSession.downloadTask(with: resumoUrl)
        download.task!.resume()
        download.tableViewIndex = tableIndex
        if tableIndex < 0 {
            print("Download não foi iniciado de uma tableview")
        }
        download.downloadState = DownlodState.baixando
        activeDownloads[resumoUrl] = download
    }
    
    
    
    func cancelDownload(_ resumo: Resumo, resumoUrl: URL) {
        if let download = activeDownloads[resumoUrl] {
            download.task?.cancel()
            activeDownloads[resumoUrl] = nil
        }
    }
}
