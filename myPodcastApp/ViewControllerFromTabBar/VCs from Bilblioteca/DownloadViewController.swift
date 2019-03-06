//
//  DownloadViewController.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNenhum: UILabel!
    
    var resumoArray = [Resumo]()
    var selectedResumo:Resumo!
    
    let realm = AppService.realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("downloads")
        
        setupUI()
    }
    
    func setupUI() {
        
        // buscar resumos favoritos
        let resumos = realm.objects(Resumo.self)
            .filter("downloaded = 1");
        //.sorted(byKeyPath: "dt_lib", ascending: false);
        
        
        print("qtd " + String(resumos.count))
        
        resumoArray.removeAll()
        for resumo in resumos {
            resumoArray.append(resumo)
        }
        
        if resumoArray.count == 0 {
            lblNenhum.isHidden = false
        } else {
            lblNenhum.isHidden = true
        }
        
        
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        tableView.reloadData()
    }
    
}



//TableView
extension DownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resumoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        let resumoDict = self.resumoArray[indexPath.item]
        
        let cod_resumo = resumoDict.cod_resumo
        
        cell.titleLabel.text = resumoDict.titulo
        cell.authorLabel.text = Util.joinAuthorsNames(authorsList: resumoDict.autores)
        
        let coverUrl = resumoDict.url_imagem
        
        //When return from detailsVC
        cell.goBackToOriginalColors()
        
        //Network.setCoverImgWithPlaceHolder(imageUrl: coverUrl, theImage: cell.coverImg)
        
        cell.coverImg.image = UIImage(named: "cover_placeholder")!
        if AppService.util.isNotNull(coverUrl as AnyObject?) {
            AppService.util.load_image_resumo(coverUrl, cod_resumo: cod_resumo, imageview: cell.coverImg)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CustomCell
        
        self.selectedResumo = self.resumoArray[indexPath.row]
        let episodeURL = URL(string: selectedResumo![linkType.fortyFree.rawValue] as! String)
        guard episodeURL != nil else {
            return
        }
        playerManager.shared.episodeSelected(episode: self.selectedResumo, episodeLink: episodeURL!)
    }

}
