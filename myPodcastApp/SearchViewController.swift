//
//  SearchViewController.swift
//  myPodcastApp
//
//  Created by William on 25/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Alamofire
import AlamofireImage
import SwiftyJSON
import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var arrShows = [[String:AnyObject]]()
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Click")
    }
    
    func searchShows(palavra:String) {
        let showUrl = "https://api.spreaker.com/v2/search?type=shows&q=" + palavra
        Alamofire.request(showUrl).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let showsData = swiftyJsonVar["response"]["items"].arrayObject {
                    self.arrShows = showsData as! [[String:AnyObject]]
                }
                if self.arrShows.count > 0 {
                    self.searchTableView.reloadData()
                }
            }
        }
    }

}
