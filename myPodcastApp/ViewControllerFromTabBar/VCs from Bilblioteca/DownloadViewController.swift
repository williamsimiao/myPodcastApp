//
//  DownloadViewController.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class DownloadViewController: InheritanceViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNenhum: UILabel!
    
    var resumoArray = [Resumo]()
    var selectedResumo:Resumo!
    var selectedResumoImage: UIImage?
    
    let realm = AppService.realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("downloads")
        
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
        let resumos = realm.objects(ResumoEntity.self).filter("downloaded = 1")
        
        //.sorted(byKeyPath: "dt_lib", ascending: false);
        
        
        print("qtd " + String(resumos.count))
        
        
        resumoArray.removeAll()
        for resumoEntity in resumos {
            let resumo = Resumo(resumoEntity: resumoEntity)
            resumoArray.append(resumo)
        }
        tableView.reloadData()

    }
    
}

//TableView
extension DownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resumoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellWithProgress
        
        let resumo = self.resumoArray[indexPath.item]
        let cod_resumo = resumo.cod_resumo
        
//        cell.delegate = self

        let download = Download(resumo: resumo)
        download.tableViewIndex = indexPath.row
        cell.download = download

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
        
        //DowanloadBtn
        if resumoEntity!.downloaded == 0 {
            cell.downloadBtn.setImage(UIImage(named: "downloadWhite")!, for: .normal)
            cell.favoritoBtn.tintColor = UIColor.white
        }
        else {
            cell.downloadBtn.setImage(UIImage(named: "downloadOrange")!, for: .normal)
            cell.favoritoBtn.tintColor = UIColor.init(hex: 0xFF8633)
        }
        
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
