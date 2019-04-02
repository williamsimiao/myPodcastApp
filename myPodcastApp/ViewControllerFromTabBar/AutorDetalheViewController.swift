//
//  AutorDetalheViewController.swift
//  myPodcastApp
//
//  Created by William on 02/04/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class AutorDetalheViewController: UIViewController {

    @IBOutlet weak var autorImage: UIImageView!
    @IBOutlet weak var autorTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    var selectedAutor: Autor?
    var resumosFromAutor: [Resumo]?
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func setUpUI() {
        let nibTableCell = UINib(nibName: "InicioCell", bundle: nil)
        tableView.register(nibTableCell, forCellReuseIdentifier: "cell")
        
        AppService.util.load_image_autor((selectedAutor?.url_imagem)!, cod_autor: (selectedAutor?.cod_autor)!, imageview: self.autorImage)
        autorTitle.text = selectedAutor?.nome
        textView.text = selectedAutor?.descricao

    }
}

// REQUEST detalhes do autor
extension AutorDetalheViewController {
    
}

extension AutorDetalheViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InicioCell
        return cell
    }
    
    
}
