//
//  ListResumosViewController.swift
//  myPodcastApp
//
//  Created by William on 20/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class ListResumosViewController: UIViewController {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var error_msg:String!
    var success:Bool!
    var resumosDictArray :[[String:AnyObject]]?
    var resumos = [Resumo]()
    var selectedResumo: Resumo?
    let realm = AppService.realm()
    
    //path for server according to the banner selected
    var path: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibTableCell = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nibTableCell, forCellReuseIdentifier: "cell")

        let link = AppConfig.urlBaseApi + path!
        let buscaUrl = URL(string: link)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

extension ListResumosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Total:\(resumos.count)")
        return resumos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let resumo = resumos[indexPath.row]
        
        let cod_resumo = resumo.cod_resumo
        
        cell.titleLabel.text = resumo.titulo
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

extension ListResumosViewController {
    
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
                
                NSLog("Banner SUCCESS");
                // dados do json
                self.resumosDictArray = (json.object(forKey: "ultimos") as! Array)
                
            } else {
                
                NSLog("Banner ERROR");
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
            
            self.resumos = AppService.util.convertDictArrayToResumoArray(dictResumoArray: self.resumosDictArray!)
            
            self.tableView.reloadData()
        }
        else {
            print("onResultReceived error")
            AppService.util.alert("Erro no Banner", message: error_msg!)
        }
        
    }
}