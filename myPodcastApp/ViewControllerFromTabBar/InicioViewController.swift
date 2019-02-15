//
//  InicioViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InicioViewController: InheritanceViewController {
  
    // MARK: - Properties
    var error_msg : String?
    var success : Bool?
    var episodesArray :[[String:AnyObject]]?
    var customTable : tableViewWithHeader?
    var myTableView =   UITableView()
    var titleView = CustomTitleView()
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupSubView()

        
        //getting Data
        makeResquest()
    }
    override func viewWillAppear(_ animated: Bool) {
//        setupTitleView()
//        setupTableView()
    }
    
    @IBAction func resizeActionButton(_ sender: Any) {
        self.bottomConstrain.constant = self.decreaseHightBy
        self.view.layoutIfNeeded()

    }
    
}
extension InicioViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Title View
    func setupTitleView() {
        self.titleView.titleLabel.text = "Bem vindo"
        self.titleView.frame = CGRect(x: 0, y: 0, width: self.resizableView.frame.width, height: 90)
        self.resizableView.addSubview(self.titleView)
        
        //Contrains
        self.titleView.alignWithTop(self.resizableView, topReference: self.resizableView)
    }

    
    // MARK: - TableView
    func setupTableView() {
        // Get main screen bounds
        myTableView.frame = CGRect(x: 0, y: 0, width: self.resizableView.frame.width, height: self.resizableView.frame.height)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        myTableView.rowHeight = 90
//        myTableView.backgroundColor = .black
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        myTableView.register(nib, forCellReuseIdentifier: "myCell")
        self.resizableView.addSubview(myTableView)
        
        //Contrains
        myTableView.fixInViewBetweenTwoOthers(self.resizableView, topReference: self.titleView, bottomReference: self.resizableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let episodesCounter = episodesArray?.count else {
            return 0
        }
        return episodesCounter

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CustomCell
        let resumoDict = self.episodesArray![indexPath.row] as Dictionary
        cell.titleLabel.text = (resumoDict["titulo"] as! String)
        let authorsList = resumoDict["autores"] as! [[String : AnyObject]]
        var authorsNamesList : [String] = []
        
        for author in authorsList {
            authorsNamesList.append(author["nome"] as! String)
        }
        cell.authorLabel.text = authorsNamesList.joined(separator: " & ")
        let coverUrl = (resumoDict["url_imagem"] as! String)
        Network.setCoverImgWithPlaceHolder(imageUrl: coverUrl, theImage: cell.coverImg)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resumoDict = self.episodesArray![indexPath.row] as Dictionary
        playerManager.shared.episodeSelected(episodeDictionary: resumoDict)
    }
}

extension InicioViewController {
    func makeResquest() {
        let link = AppConfig.urlBaseApi + "buscaResumos.php"
        
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 10
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            self.extract_json_data(dataString!)
            
        })
        
        task.resume()
    }
    
    func extract_json_data(_ data:NSString) {
        
        NSLog("json %@", data)
        
        let jsonData:Data = data.data(using: String.Encoding.ascii.rawValue)!
        
        
        do
        {
            // converter pra json
            let json:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
            
            
            // verificar success
            self.success = (json.value(forKey: "success") as! Bool)
            if (self.success!) {
                
                NSLog("Login SUCCESS");
                // dados do json
                self.episodesArray = (json.object(forKey: "resumos") as! Array)
                
            } else {
                
                NSLog("Login ERROR");
                error_msg = (json.value(forKey: "error") as! String)
            }
        }
        catch
        {
            print("error")
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
    }
    
    func onResultReceived() {

        if self.success! {
            //Salvar
            self.myTableView.reloadData()
//            AppService.util.alert("deu bom", message: "Obaaa" as! String)
            
        }
        else {
            AppService.util.alert("Erro no Login", message: error_msg!)
        }
    }
}

