//
//  FavoritosViewController.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

enum DownlodState : Int {
    case none = 0
    case baixando = 1
    case baixado = 2
}


class FavoritosViewController: InheritanceViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNenhum: UILabel!
    

    var download: Download?
    var resumoArray = [Resumo]()
    var selectedResumo:Resumo!
    var selectedResumoImage: UIImage?
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    let realm = AppService.realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppService.downloadService.downloadsSession = downloadsSession
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    func setupUI() {
        let nib = UINib(nibName: "CellWithProgress", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        fetchResumosFromRealm()
        
        if resumoArray.count == 0 {
            lblNenhum.isHidden = false
        } else {
            lblNenhum.isHidden = true
        }
        
    }
    
    func fetchResumosFromRealm() {
        // buscar resumos favoritos
        let resumos = realm.objects(ResumoEntity.self).filter("favoritado = 1 OR downloaded = 1")
        
        resumoArray.removeAll()
        for resumoEntity in resumos {
            let resumo = Resumo(resumoEntity: resumoEntity)
            resumoArray.append(resumo)
        }
        tableView.reloadData()

    }
    
}



//TableView
extension FavoritosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resumoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellWithProgress
        
        let resumo = self.resumoArray[indexPath.item]
        
        let cod_resumo = resumo.cod_resumo
        
        cell.delegate = self
        
        //TODO check what is the type of resumo
        let dicit = AppService.downloadService.activeDownloads
        let url = URL(string: resumo.url_podcast_40_f)!
        if let down = AppService.downloadService.activeDownloads[url] {
            cell.download = down
        }
        else {
            let download = Download(resumo: resumo)
            download.tableViewIndex = indexPath.row
            cell.download = download

        }
        
        
        cell.titleLabel.text = resumo.titulo
        cell.authorLabel.text = Util.joinAuthorsNames(authorsList: resumo.autores)
        
        let resumoEntity = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo).first
        //FavoritoBtn
        if resumoEntity!.favoritado == 0 {
            cell.favoritoBtn.setImage(UIImage(named: "favoritoWhite")!, for: .normal)
            cell.favoritoBtn.tintColor = UIColor.white
        }
        else {
            cell.favoritoBtn.setImage(UIImage(named: "favoritoOrange")!, for: .normal)
            cell.favoritoBtn.tintColor = UIColor.init(hex: 0xFF8633)
        }
        
        
        if cod_resumo == "159" {
            if cell.download?.downloadState == DownlodState.none {
                if resumoEntity!.downloaded == 0 {
                    cell.changeDownloadButtonLook(isDownloading: false, isDownloaded: false)
                    cell.downloadBtn.tintColor = UIColor.white
                }
                else {
                    cell.changeDownloadButtonLook(isDownloading: false, isDownloaded: true)
                    cell.downloadBtn.tintColor = UIColor.init(hex: 0xFF8633)
                }
            }
            else if cell.download?.downloadState == .baixando {
                cell.changeDownloadButtonLook(isDownloading: true, isDownloaded: false)
            }
        }
        
        if cell.download?.downloadState == DownlodState.none {
            if resumoEntity!.downloaded == 0 {
                cell.changeDownloadButtonLook(isDownloading: false, isDownloaded: false)
                cell.downloadBtn.tintColor = UIColor.white
            }
            else {
                cell.changeDownloadButtonLook(isDownloading: false, isDownloaded: true)
                cell.downloadBtn.tintColor = UIColor.init(hex: 0xFF8633)
            }
        }
        else if cell.download?.downloadState == .baixando {
            cell.changeDownloadButtonLook(isDownloading: true, isDownloaded: false)
        }
        //DowanloadBtn

        
        let coverUrl = resumo.url_imagem
        
        //When return from detailsVC
        cell.goBackToOriginalColors()
        
        let progressRatio = AppService.util.getProgressRatio(cod_resumo: cod_resumo)

        cell.progressView.progress = Float(progressRatio)
        
        cell.coverImg.image = UIImage(named: "cover_placeholder")!
        if AppService.util.isNotNull(coverUrl as AnyObject?) {
            AppService.util.load_image_resumo(coverUrl, cod_resumo: cod_resumo, imageview: cell.coverImg)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CellWithProgress
        
        self.selectedResumo = self.resumoArray[indexPath.row]
        self.selectedResumoImage = cell.coverImg.image
        
        performSegue(withIdentifier: "to_detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detalheVC = segue.destination as? DetalheViewController {
            detalheVC.selectedResumo = self.selectedResumo
        }
    }
}

extension FavoritosViewController: CellWithProgressDelegate {
    func clickDownload(aDownload: Download) {
        let episodeUrlString: String
        let userIsPremium = false
        let theResumo = aDownload.resumo

        if userIsPremium {
            episodeUrlString = theResumo.url_podcast_40_p
        }
        else {
            episodeUrlString = theResumo.url_podcast_40_f
        }
        let resumoEntity = AppService.realm().objects(ResumoEntity.self).filter("cod_resumo = %@", theResumo.cod_resumo).first

        if resumoEntity!.downloaded == 1 {
            var wasDeleted = AppService.util.deleteResumoAudioFile(urlString: episodeUrlString, cod_resumo: theResumo.cod_resumo)
            if theResumo.url_podcast_10 != nil {
                wasDeleted = AppService.util.deleteResumoAudioFile(urlString: theResumo.url_podcast_10, cod_resumo: theResumo.cod_resumo)
            }
            if wasDeleted {
                self.tableView.reloadData()
            }
        }
        else {
            let cell = self.tableView.cellForRow(at: IndexPath(row: aDownload.tableViewIndex!, section: 0)) as! CellWithProgress

            var resumoURL = URL(string: episodeUrlString)!
            
            if aDownload.downloadState == DownlodState.baixando {
                AppService.downloadService.cancelDownload(theResumo, resumoUrl: resumoURL)
                cell.changeDownloadButtonLook(isDownloading: false, isDownloaded: false)
                aDownload.downloadState = .none
            }
            else {
                if aDownload.downloadState == DownlodState.none {
                    if AppService.util.isConnectedToNetwork() == false {
                        AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
                        return
                    }
                    aDownload.downloadState = DownlodState.baixando
                    //            AppService.util.downloadAudio(urlString: episodeUrlString, cod_resumo: theResumo.cod_resumo)
                    
                    AppService.downloadService.startDownload(theResumo, resumoUrl: resumoURL, tableIndex: aDownload.tableViewIndex!)
                    
                    cell.changeDownloadButtonLook(isDownloading: true, isDownloaded: false)
                }

            }

            
            
            //downalod TEN podcast
//            if theResumo.url_podcast_10 != nil {
//                resumoURL = URL(string: theResumo.url_podcast_10)!
//                AppService.downloadService.startDownload(theResumo, resumoUrl: resumoURL)
//            }
        }
    }
    
    func clickFavorito(theResumo: Resumo) {
        AppService.util.markResumoFavoritoField(cod_resumo: theResumo.cod_resumo)
        fetchResumosFromRealm()

    }
}

extension FavoritosViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
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
        // 4
        if let index = download?.tableViewIndex {
            DispatchQueue.main.async {
                print("realoading table")
                let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! CellWithProgress
                cell.download?.downloadState = DownlodState.baixado
                cell.changeDownloadButtonLook(isDownloading: false, isDownloaded: true)

                
                let cod_resumo = download?.resumo.cod_resumo
                AppService.util.markResumoDownloadField(cod_resumo: cod_resumo!, downloaded: true)
                print("Marcado no realm")

            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        // 1
        guard let url = downloadTask.originalRequest?.url,
            let download = AppService.downloadService.activeDownloads[url]  else { return }
        // 2
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        // 3
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        // 4
        DispatchQueue.main.async {
            if download.tableViewIndex! > 0 {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: download.tableViewIndex!,
                    section: 0)) as? CellWithProgress {
                    cell.download?.downloadState = DownlodState.baixando
                    cell.updateDisplay(progress: download.progress, totalSize: totalSize)
                }
            }
            
        }
    }

}
