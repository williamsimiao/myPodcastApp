//
//  FavoritosViewController.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class FavoritosViewController: InheritanceViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNenhum: UILabel!
    
    var resumoArray = [Resumo]()
    var selectedResumo:Resumo!
    var selectedResumoImage: UIImage?


    let realm = AppService.realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("favoritos")
        
        setupUI()
    }
    
    func setupUI() {
        
        // buscar resumos favoritos
        let resumos = realm.objects(ResumoEntity.self).filter("favoritado = 1")

        //.sorted(byKeyPath: "dt_lib", ascending: false);
        
        
        print("qtd " + String(resumos.count))
        
        
        resumoArray.removeAll()
        for resumoEntity in resumos {
            let resumo = Resumo(resumoEntity: resumoEntity)
            resumoArray.append(resumo)
        }
        
        if resumoArray.count == 0 {
            lblNenhum.isHidden = false
        } else {
            lblNenhum.isHidden = true
        }
        
        
        let nib = UINib(nibName: "CellWithProgress", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
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
        cell.resumo = resumo
        
        cell.titleLabel.text = resumo.titulo
        cell.authorLabel.text = Util.joinAuthorsNames(authorsList: resumo.autores)
        
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
    func presentAlertOptions(theResumo: Resumo) {
        let optionMenu = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        
        let actionDeletar = UIAlertAction(title: "Desfavoritar", style: .destructive) { _ in
            AppService.util.markResumoFavoritoField(cod_resumo: theResumo.cod_resumo)
        }
        
        optionMenu.addAction(actionDeletar)
        
        self.present(optionMenu, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            optionMenu.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
}
