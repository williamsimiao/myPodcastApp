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
    var page:Int = 1

    //path for server
    var path: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibTableCell = UINib(nibName: "AutorTableCell", bundle: nil)
        tableView.register(nibTableCell, forCellReuseIdentifier: "cell")
        
        if path == "buscaAutores.php" {
            navigationItem.title = "Autores"
        }
        else if path == "buscaTopAutores.php" {
            navigationItem.title = "Top 10 Autores"
        }
        loading.isHidden = false
        loading.startAnimating()

        makeResquest(path: path!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

extension ListAutoresViewController: UITableViewDelegate, UITableViewDataSource {
    func loadMore() {
        page = page + 1
        makeResquest(path: path!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Total:\(autores.count)")
        let count = autores.count
        return count
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let tableIndex = indexPath.row
        let lastIndex = autores.count - 1
        if tableIndex == lastIndex {
            print("Reached bottom")
            loadMore()
        }
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
        
        self.selectedAutor = autores[indexPath.row]
        
        performSegue(withIdentifier: "to_detalhe_autor", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let detalheVC = segue.destination as? AutorDetalheViewController {
           detalheVC.selectedAutor = self.selectedAutor
        }
        
    }
}

extension ListAutoresViewController {
    
    func makeResquest(path: String) {
//        loading.isHidden = false
//        loading.startAnimating()
        
        
        let link = AppConfig.urlBaseApi + path
        
        var url:URL = URL(string: link)!
        let session = URLSession.shared
        
        if path == "buscaAutores.php" {
            url = AppService.util.createURLWithComponents(path: "buscaAutores.php", parameters: ["page"], values: [String(self.page)])!
        }
        
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
            
            let autoresArray = AppService.util.convertDictArrayToAutorArray(dictResumoArray: self.autoresDictArray!)
            self.autores.append(contentsOf: autoresArray)
            
            self.tableView.reloadData()
        }
        else {
            print("onResultReceived error")
            AppService.util.alert("Erro no AutorList", message: error_msg!)
        }
        
    }
}


