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
        let nib = UINib(nibName: "CellWithProgress", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")

        updateResumoList()
    }
    
    func updateResumoList() {
        // buscar resumos favoritos
        let resumos = realm.objects(ResumoEntity.self).filter("favoritado = 1 OR downloaded = 1 OR downloading  = 1")
        
        resumoArray.removeAll()
        for resumoEntity in resumos {
            let resumo = Resumo(resumoEntity: resumoEntity)
            resumoArray.append(resumo)
        }
        tableView.reloadData()
        
        if resumoArray.count == 0 {
            lblNenhum.isHidden = false
        } else {
            lblNenhum.isHidden = true
        }
    }
}



//TableView
extension FavoritosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resumoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellWithProgress
        let resumo = self.resumoArray[indexPath.row]
        let cod_resumo = resumo.cod_resumo
        cell.delegate = self
        
        let dicit = AppService.downloadService.activeDownloads
        var url: URL?
        let userIsPremium = false
        if userIsPremium {
            url = URL(string: resumo.url_podcast_40_p)!
        }
        else {
            url = URL(string: resumo.url_podcast_40_f)!
        }
        if let down = AppService.downloadService.activeDownloads[url!] {
            cell.download = down
            cell.download?.tableViewIndex = indexPath.row
        }
        else {
            cell.download = Download(resumo: resumo)
        }
        
        //Cell UI
        cell.titleLabel.text = resumo.titulo
        cell.authorLabel.text = Util.joinAuthorsNames(authorsList: resumo.autores)
        
        let resumoEntity = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo).first
        
        //FavoritoBtn
        if resumoEntity!.favoritado == 1 {
            cell.setFavoritoBtn(favoritado: true)
        }
        else {
            cell.setFavoritoBtn(favoritado: false)
        }
        //DownaloadBtn
        var isDownaloded = false
        var isDownloading = false
        if resumoEntity?.downloaded == 1 {
            isDownaloded = true
        }
        if resumoEntity?.downloading == 1 {
            isDownloading = true
        }
        cell.changeDownloadButtonLook(isDownloading: isDownloading, isDownloaded: isDownaloded)

        
        //COVER_IMG
        let coverUrl = resumo.url_imagem
        cell.coverImg.image = UIImage(named: "cover_placeholder")!
        if AppService.util.isNotNull(coverUrl as AnyObject?) {
            AppService.util.load_image_resumo(coverUrl, cod_resumo: cod_resumo, imageview: cell.coverImg)
        }
        
        //When return from detailsVC
        cell.goBackToOriginalColors()
        
        //Progress of the audio (LISTENED)
        let progressRatio = AppService.util.getProgressRatio(cod_resumo: cod_resumo)
        cell.progressView.progress = Float(progressRatio)
        
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
    func confirmDownloadDeletion(cell: CellWithProgress, urlString: String) {
        let theResumo = cell.download?.resumo
        let alert = UIAlertController(
            title: "Remover Resumo",
            message: "Deseja remover o download do resumo ?",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Remover", style: UIAlertAction.Style.destructive, handler:{(ACTION :UIAlertAction) in
            let wasDeleted = AppService.util.deleteResumoAudioFile(urlString: urlString, cod_resumo: theResumo!.cod_resumo)
            
            if wasDeleted {
                self.updateResumoList()

//                self.tableView.reloadData()
//                cell.changeDownloadButtonLook(isDownloading: false, isDownloaded: false)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler:{(ACTION :UIAlertAction) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func clickDownload() {
        updateResumoList()
    }
    
    func clickFavorito(cell: CellWithProgress, theResumo: Resumo) {
        let favoritadoBool = AppService.util.changeMarkResumoFavoritoField(cod_resumo: theResumo.cod_resumo)
        cell.setFavoritoBtn(favoritado: favoritadoBool)
        updateResumoList()
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
                
                //Mark downloading as 0 on Realm
                let boelano = AppService.util.changeMarkResumoDownloading(cod_resumo: cod_resumo!)
//                print("\(boelano)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url,
            let download = AppService.downloadService.activeDownloads[url]  else { return }
//        download.resumo
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        DispatchQueue.main.async {
            if let index = download.tableViewIndex {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CellWithProgress {
                    cell.updateDisplay(progress: download.progress, totalSize: totalSize)
                }
            }
            else {
                print("Nenhum index encontrado")
            }

        }
    }
    
}
