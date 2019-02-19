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
    var selectedEpisode : [String: AnyObject]?
    var selectedEpisodeImage : UIImage?
    var episodesArray :[[String:AnyObject]]?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resizableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.superResizableView = resizableView
        setupUI()

        //getting Data
        makeResquest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resizeForMiniView()
        tableView.reloadData()
    }
    
    func setupUI() {
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        setupNavBarTitle()
    }
    
    func setupNavBarTitle() {
        //
        //        let paragraph = NSMutableParagraphStyle()
        //        paragraph.alignment = .center
        //        let myAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: paragraph]
        //
        //        let greetingsMessage = NSLocalizedString("welcome", comment: "ola")
        //        let attributedText = NSMutableAttributedString(string: greetingsMessage, attributes: myAttributes)
        //        navigationController?.navigationBar.titleTextAttribute =  attributedText
        //
        
        //        let paragraph = NSMutableParagraphStyle()
        //        paragraph.alignment = .center
        //
        //        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: paragraph]
        //
        //        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
extension InicioViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView
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
        Network.setCoverImgWithPlaceHolder(imageUrl: coverUrl, theImage: cell.coverImg)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detalheVC = segue.destination as? DetalheViewController {
            detalheVC.selectedEpisode = self.selectedEpisode
            detalheVC.selectedEpisodeImage = self.selectedEpisodeImage
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CustomCell
        
        self.selectedEpisode = self.episodesArray![indexPath.row] as Dictionary
        self.selectedEpisodeImage = cell.coverImg.image
        performSegue(withIdentifier: "to_detail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CustomCell
//        cell.selectedBackgroundView?.backgroundColor = UIColor.white
//        cell.titleLabel.textColor = .black
//        cell.authorLabel.textColor = .black
//        cell.coverImg.layer.borderColor = UIColor.black.cgColor
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
            self.tableView.reloadData()
//            AppService.util.alert("deu bom", message: "Obaaa" as! String)
            
        }
        else {
            AppService.util.alert("Erro no Login", message: error_msg!)
        }
    }
}

