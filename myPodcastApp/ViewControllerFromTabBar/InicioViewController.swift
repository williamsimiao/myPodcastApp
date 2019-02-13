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
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubView()
        setupTableView()
        
        //getting Data
        makeResquest()
    }
}
// MARK: - TableView
extension InicioViewController: UITableViewDataSource, UITableViewDelegate {
    func setupTableView() {
        // Get main screen bounds
        myTableView.frame = CGRect(x: 0, y: 0, width: self.resizableView.frame.width, height: self.resizableView.frame.height*0.4)
        myTableView.dataSource = self
        myTableView.delegate = self
//        myTableView.backgroundColor = .black
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        self.resizableView.addSubview(myTableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if episodesArray != nil {
            return episodesArray!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CustomCell
//        let resumoDict = self.episodesArray![indexPath.row] as Dictionary
//        cell.titleLabel.text = (resumoDict["titulo"] as! String)
//        let coverUrl = (resumoDict["url_imagem"] as! String)
////        Network.setCoverImgWithPlaceHolder(imageUrl: <#T##String#>, theImage: cell.coverImg)
        
        let resumoDict = self.episodesArray![indexPath.row] as Dictionary
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)  as UITableViewCell
        cell.textLabel?.text = (resumoDict["titulo"] as! String)


        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resumoDict = self.episodesArray![indexPath.row] as Dictionary
        playerManager.shared.player_setup(episodeDictionary: resumoDict)

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
                self.episodesArray = json.object(forKey: "resumos") as! Array
                
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
            print(episodesArray?.first)
            self.myTableView.reloadData()
//            AppService.util.alert("deu bom", message: "Obaaa" as! String)
            
        }
        else {
            AppService.util.alert("Erro no Login", message: error_msg as! String)
        }
    }
}

