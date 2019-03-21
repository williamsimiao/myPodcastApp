//
//  ListAutoresViewController.swift
//  myPodcastApp
//
//  Created by William on 21/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class ListAutoresViewController: UIViewController {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var error_msg:String!
    var success:Bool!
    var autoresDictArray :[[String:AnyObject]]?
    var autores = [Autor]()
    
    var selectedAutor: Autor?
    let realm = AppService.realm()
    
    //path for server
    var path: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibTableCell = UINib(nibName: "AutorTableCell", bundle: nil)
        tableView.register(nibTableCell, forCellReuseIdentifier: "cell")
        
        makeResquest(path: path!)
    }
}

extension ListAutoresViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Total:\(autores.count)")
        return autores.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AutorTableCell
        
        let autor = autores[indexPath.row]
        
        let cod_autor = autor.cod_autor
        
        cell.nameLabel.text = autor.nome
        let photoUrl = autor.url_imagem
        
        //When return from detailsVC
        cell.goBackToOriginalColors()
        
        cell.photoImg.image = UIImage(named: "sem_imagem")!
        if AppService.util.isNotNull(photoUrl as AnyObject?) {
            AppService.util.load_image_autor(photoUrl, cod_autor: cod_autor, imageview: cell.photoImg)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAutor = autores[indexPath.row]
//        performSegue(withIdentifier: "to_detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let detalheVC = segue.destination as? DetalheViewController {
//            detalheVC.selectedResumo = self.selectedAutor
//        }
        
    }
}

extension ListAutoresViewController {
    
    func makeResquest(path: String) {
        
        loading.isHidden = false
        loading.startAnimating()
        
        
        let link = AppConfig.urlBaseApi + path
        
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
                
                NSLog("AutorList SUCCESS");
                // dados do json
                self.autoresDictArray = (json.object(forKey: "autores") as! Array)
                
                
            } else {
                
                NSLog("AutorList ERROR");
                error_msg = (json.value(forKey: "error") as! String)
            }
        }
        catch
        {
            print("error: sem resposta do servidor")
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
    }
    
    func onResultReceived() {
        loading.isHidden = true
        loading.stopAnimating()
        
        
        if self.success {
            
            self.autores = AppService.util.convertDictArrayToAutorArray(dictResumoArray: self.autoresDictArray!)
            
            self.tableView.reloadData()
        }
        else {
            print("onResultReceived error")
            AppService.util.alert("Erro no AutorList", message: error_msg!)
        }
        
    }
}


