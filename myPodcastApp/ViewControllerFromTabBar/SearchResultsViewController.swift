//
//  SearchResultsViewController.swift
//  myPodcastApp
//
//  Created by William on 15/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class SearchResultsViewController: InheritanceViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var noResultLabel: UILabel!
    
    var textoBusca: String?
    var error_msg:String!
    var success:Bool!
    var resumosDictArray :[[String:AnyObject]]?
    var resumos = [Resumo]()
    var selectedResumo: Resumo?
    let realm = AppService.realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        let nibTableCell = UINib(nibName: "InicioCell", bundle: nil)
        tableView.register(nibTableCell, forCellReuseIdentifier: "cell")

        let link = AppConfig.urlBaseApi + "buscar.php"
        let buscaUrl = URL(string: link)
        let keys = ["texto"]
        let values = [self.textoBusca!]
        
        if AppService.util.isConnectedToNetwork() == false {
            let alert = UIAlertController(
                title: "Sem Internet",
                message: "Sem conexão com a internet!",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{(ACTION :UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        makeResquest(url: buscaUrl!, keys: keys, values: values)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        noResultLabel.isHidden = true
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Total:\(resumos.count)")
        return resumos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InicioCell
        let resumo = resumos[indexPath.row]
        
        let cod_resumo = resumo.cod_resumo
        
        cell.delegate = self
        cell.cod_resumo = cod_resumo
        cell.titleLabel.text = resumo.titulo
        
        let resumoEntity = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo).first
        if resumoEntity!.favoritado == 0 {
            cell.favoritoButton.imageView?.image = UIImage(named: "favoritoWhite")!
            cell.favoritoButton.tintColor = UIColor.white
        }
        else {
            cell.favoritoButton.imageView?.image = UIImage(named: "favoritoOrange")!
            cell.favoritoButton.tintColor = UIColor.init(hex: 0xFF8633)
        }
        
        let authorsList = resumo.autores
        let joinedNames = Util.joinAuthorsNames(authorsList: authorsList)
        cell.authorLabel.text = joinedNames
        let coverUrl = resumo.url_imagem
        
        //When return from detailsVC
        cell.goBackToOriginalColors()
        
        cell.coverImg.image = UIImage(named: "cover_placeholder")!
        if AppService.util.isNotNull(coverUrl as AnyObject?) {
            AppService.util.load_image_resumo(coverUrl, cod_resumo: cod_resumo, imageview: cell.coverImg)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedResumo = resumos[indexPath.row]
        performSegue(withIdentifier: "to_detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detalheVC = segue.destination as? DetalheViewController {
            detalheVC.selectedResumo = self.selectedResumo
        }

    }
}

extension SearchResultsViewController {
    
    func makeResquest(url: URL, keys: [String], values: [String]) {
        var request = URLRequest(url: url)
        let session = URLSession.shared

        loading.isHidden = false
        loading.startAnimating()
        
        let tuples = zip(keys, values)
        var keyValueArray = [String]()
        for (key, value) in tuples {
            let paramValue = key + "=" + value
            keyValueArray.append(paramValue)
        }
        let joinedData = keyValueArray.joined(separator: "&")
        
//        let postData:Data = joinedData.data(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue))!
//        let postLength:NSString = String( postData.count ) as NSString
        
        let post = joinedData as NSString
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        let postLength:NSString = String( postData.count ) as NSString
        
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.httpBody = postData
        
//        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        print("REQUEST: \(request)")
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print(error)
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
                
                NSLog("Buscar SUCCESS");
                // dados do json
                self.resumosDictArray = (json.object(forKey: "resumos") as! Array)
            } else {
                
                NSLog("Buscar ERROR");
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
        
        loading.isHidden = true
        loading.stopAnimating()
        
        if self.success {
            
            // zerar dados
            /*for entity in realm.objects(Resumo.self) {
             try! realm.write {
             self.realm.delete(entity)
             }
             }*/
            
            self.resumos = AppService.util.convertDictArrayToResumoArray(dictResumoArray: self.resumosDictArray!)
            if resumos.count <= 0 {
                noResultLabel.isHidden = false
            }
            
            self.tableView.reloadData()
        }
        else {
        }
        
    }
    
}


extension SearchResultsViewController {
    func prepareFav(salvar: String, cod_resumo: String) {
        let link = AppConfig.urlBaseApi + "salvarResumo.php"
        let url = URL(string: link)
        let keys = ["cod_usuario", "cod_resumo", "salvar"]
        
        
        let prefs:UserDefaults = UserDefaults.standard
        var cod_usuario = prefs.string(forKey: "cod_usuario")
        if cod_usuario == nil || cod_usuario == "" {
            return
        }
        
        var values = [String]()
        values.append(cod_usuario!)
        values.append(cod_resumo)
        values.append(salvar)
        makeResquestFav(url: url!, keys: keys, values: values)
    }
    
    func makeResquestFav(url: URL, keys: [String], values: [String]) {
        var request = URLRequest(url: url)
        let session = URLSession.shared
        
        
        let tuples = zip(keys, values)
        var keyValueArray = [String]()
        for (key, value) in tuples {
            let paramValue = key + "=" + value
            keyValueArray.append(paramValue)
        }
        let joinedData = keyValueArray.joined(separator: "&")
        
        //        let postData:Data = joinedData.data(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue))!
        //        let postLength:NSString = String( postData.count ) as NSString
        
        let post = joinedData as NSString
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        let postLength:NSString = String( postData.count ) as NSString
        
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.httpBody = postData
        
        //        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        print("REQUEST: \(request)")
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print(error)
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            self.extract_json_dataFav(dataString!)
            
        })
        
        task.resume()
    }
    
    func extract_json_dataFav(_ data:NSString) {
        
        NSLog("json %@", data)
        
        let jsonData:Data = data.data(using: String.Encoding.ascii.rawValue)!
        
        
        do
        {
            // converter pra json
            let json:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
            
            
            // verificar success
            self.success = (json.value(forKey: "success") as! Bool)
            if (self.success!) {
                
                NSLog("Sucesso Fav");
            } else {
                
                NSLog("erro Fav");
                error_msg = (json.value(forKey: "error") as! String)
                
            }
        }
        catch
        {
            print("error Fav")
            return
        }
        DispatchQueue.main.async(execute: onResultReceivedFav)
        
    }
    
    func onResultReceivedFav() {
        
        
        if self.success {
            print("success na Fav")
        }
        else {
            print("Erro noa Fav")
        }
        
    }
}

extension SearchResultsViewController: inicioCellDelegate {
    func changeFavoritoState(cod_resumo: String) {
        let resumos = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo)
        guard let resumoEntity = resumos.first else {
            return
        }
        let resumo = Resumo(resumoEntity: resumoEntity)
        try! self.realm.write {
            if resumoEntity.favoritado == 0 {
                resumoEntity.favoritado = 1
                prepareFav(salvar: "1", cod_resumo: resumo.cod_resumo)
            } else {
                resumoEntity.favoritado = 0
                prepareFav(salvar: "0", cod_resumo: resumo.cod_resumo)
            }
            self.realm.add(resumoEntity, update: true)
        }
    }
    
}
