//
//  DownloadViewController.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController {
    var episodesArray :[[String:AnyObject]]?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
}

//TableView
extension DownloadViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let episodesCounter = episodesArray?.count else {
            return 0
        }
        return episodesCounter

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
        
        return cell
    }
}
