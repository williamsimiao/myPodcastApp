//
//  FavoritosViewController.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import RealmSwift

class FavoritosViewController: UIViewController {
    var episodesArray :[[String:AnyObject]]?

    let realm = try! Realm()
    lazy var resumos: Results<Resumo> = { self.realm.objects(Resumo.self) }()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    func setupUI() {
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
}

//TableView
extension FavoritosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let episodesCounter = episodesArray?.count else {
            return 0
        }
        return episodesCounter

//        return resumos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        let resumoDict = self.episodesArray![indexPath.row] as Dictionary
        cell.titleLabel.text = (resumoDict["titulo"] as! String)
        let authorsList = resumoDict["autores"] as! [[String : AnyObject]]
        cell.authorLabel.text = Util.joinStringWithSeparator(authorsList: authorsList, separator: " & ")
        let coverUrl = (resumoDict["url_imagem"] as! String)
        
        //When return from detailsVC
        cell.goBackToOriginalColors()
        
        Network.setCoverImgWithPlaceHolder(imageUrl: coverUrl, theImage: cell.coverImg)
        
        
        
//        let resumo = resumos[indexPath.row]
//
//        cell.titleLabel.text = resumo.titulo
//        cell.authorLabel.text = resumo.
        return cell
    }
}
