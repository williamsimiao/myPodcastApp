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
    
    let updateInterval = 0.5
    var download: Download?
    var resumoArray = [Resumo]()
    var selectedResumo:Resumo!
    var selectedResumoImage: UIImage?
    var timer: Timer?
    var realm = AppService.realm()
    var needsUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CellWithProgress", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(self.getDataFromRealm), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDataFromRealm()
        showContent()
    }
    
    @objc func getDataFromRealm() {
        // buscar resumos favoritos
        self.realm = AppService.realm()
        let resumos = realm.objects(ResumoEntity.self).filter("favoritado = 1 OR downloaded = 1 OR downloading = 1")
        resumoArray.removeAll()
        for resumoEntity in resumos {
            let resumo = Resumo(resumoEntity: resumoEntity)
            resumoArray.append(resumo)
            if resumo.downloading == 1 {
                self.needsUpdate = true
            }
        }
        if self.needsUpdate {
            showContent()
        }
        self.needsUpdate = false
    }
    
    func showContent() {
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
        self.realm = AppService.realm()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellWithProgress
        
        let resumo = self.resumoArray[indexPath.row]
        let cod_resumo = resumo.cod_resumo
        
        cell.delegate = self
        
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
        
        
        //Labels
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
        if let progress = resumoEntity?.progressDownload {
            cell.updateDisplay(progress: Float(progress))
        }

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

extension FavoritosViewController: downloadFavoritoDelegate {
    func confirmDownloadDeletion(resumo: Resumo?, urlString: String) {
        let alert = UIAlertController(
            title: "Remover Resumo",
            message: "Deseja remover o download do resumo ?",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Remover", style: UIAlertAction.Style.destructive, handler:{(ACTION :UIAlertAction) in
            self.needsUpdate = true
            
            guard let _ = resumo else {
                return
            }
            
            AppService.util.deleteResumoAudioFile(urlString: urlString, cod_resumo: resumo!.cod_resumo)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler:{(ACTION :UIAlertAction) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func clickDownload() {
//        getDataFromRealm()
    }

    func downloadCanceled() {
        needsUpdate = true
    }
    
    func clickFavorito() {
        needsUpdate = true
    }


}
