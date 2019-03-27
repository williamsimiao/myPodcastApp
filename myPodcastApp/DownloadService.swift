import Foundation

class DownloadService {
    
    var downloadsSession: URLSession!
    var activeDownloads: [URL: Download] = [:]
    
    func startDownload(_ resumo: Resumo, resumoUrl: URL) {
        let download = Download(resumo: resumo)
        download.task = downloadsSession.downloadTask(with: resumoUrl)
        download.task!.resume()
        download.isDownloading = true
        activeDownloads[resumoUrl] = download
    }
    
    func pauseDownload(_ resumo: Resumo, resumoUrl: URL) {
        guard let download = activeDownloads[resumoUrl] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { data in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
    
    func cancelDownload(_ resumo: Resumo, resumoUrl: URL) {
        if let download = activeDownloads[resumoUrl] {
            download.task?.cancel()
            activeDownloads[resumoUrl] = nil
        }
    }
    
    func resumeDownload(_ resumo: Resumo, resumoUrl: URL) {
        guard let download = activeDownloads[resumoUrl] else { return }
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: resumoUrl)
        }
        download.task!.resume()
        download.isDownloading = true
    }
}
