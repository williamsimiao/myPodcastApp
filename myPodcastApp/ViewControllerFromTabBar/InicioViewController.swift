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

class InicioViewController: InheritanceViewController, UITableViewDataSource, UITableViewDelegate {
  
    // MARK: - Properties
    var error_msg : String?
    var success : Bool?
    var episodesArray :[[String:AnyObject]]?
    var customTable : tableViewWithHeader?
    var myTableView: UITableView  =   UITableView()
    var itemsToLoad: [String] = ["One", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSubView()

        let rect = CGRect(x: 50, y: 50, width: 0, height: 0)
        self.customTable = tableViewWithHeader(frame: rect)
        setupViewOnTop(bigView: self.resizableView, subView: self.customTable!)
        self.view.layoutIfNeeded()
        
        //getting Data
        makeResquest()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get main screen bounds
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        myTableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        myTableView.dataSource = self
        myTableView.delegate = self
        
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        self.resizableView.addSubview(myTableView)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsToLoad.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        cell.textLabel?.text = self.itemsToLoad[indexPath.row]
        
        return cell
    }
    
    open func setupViewOnTop(bigView:UIView, subView:UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        bigView.addSubview(subView)
        
        //adding contrains
        
        //left and right margins
        let leadingConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bigView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)

        let trailingConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bigView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)


        //top
        let topConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bigView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)

        //bottom
        if #available(iOS 11, *) {
            let guide = bigView.safeAreaLayoutGuide

            let bottomContrain =  guide.bottomAnchor.constraint(equalTo: resizableView.bottomAnchor, constant: self.decreaseHightBy)

            NSLayoutConstraint.activate([bottomContrain])

        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                subView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: subView.bottomAnchor, constant: standardSpacing)
                ])
        }
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint])
        
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
//            AppService.util.alert("deu bom", message: "Obaaa" as! String)
            
        }
        else {
            AppService.util.alert("Erro no Login", message: error_msg as! String)
        }
    }
}

