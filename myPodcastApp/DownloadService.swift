import Foundation

class DownloadService {
    
    var downloadsSession: URLSession!
    var activeDownloads: [URL: Download] = [:]
    
    func startDownload(_ resumo: Resumo, resumoUrl: URL) {
        let download = Download(resumo: resumo)
        download.task = downloadsSession.downloadTask(with: resumoUrl)
        download.task!.resume()
        download.downloadState = DownlodState.baixando
        activeDownloads[resumoUrl] = download
    }
    
    func cancelDownload(_ resumo: Resumo, resumoUrl: URL) {
        if let download = activeDownloads[resumoUrl] {
            download.task?.cancel()
            activeDownloads[resumoUrl] = nil
        }
    }
    
    func downloadIsActive(resumoUrl: URL) -> Bool {
        if activeDownloads[resumoUrl] != nil {
            return true
        }
        else {
            return false
        }
    }
}
