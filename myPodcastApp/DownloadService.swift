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
    
    func fixDownloadingOnRealm() {
        let realm = AppService.realm()
        let resumos = realm.objects(ResumoEntity.self).filter("downloading = 1")
        for resumoEntity in resumos {
            var url: URL?
            let userIsPremium = false
            if userIsPremium {
                url = URL(string: resumoEntity.url_podcast_40_p)!
            }
            else {
                url = URL(string: resumoEntity.url_podcast_40_f)!
            }
            if AppService.downloadService.downloadIsActive(resumoUrl: url!)  == false {
                try! AppService.realm().write {
                    resumoEntity.downloading = 0
                    realm.add(resumoEntity, update: true)
                }
            }
        }
    }
    
    func downloadIsActive(resumoUrl: URL) -> Bool {
        if activeDownloads[resumoUrl] == nil {
            return false
        }
        else {
            return true
        }
    }
}
