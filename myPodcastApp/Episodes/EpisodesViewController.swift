//
//  EpisodesViewController.swift
//  myPodcastApp
//
//  Created by William on 22/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import MediaPlayer
import Alamofire
import AlamofireImage
import SwiftyJSON

class EpisodesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var arrEpisodes = [[String:AnyObject]]()
    var dictShow = [String:AnyObject]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let showId = "2885428"
        let showUrl = "https://api.spreaker.com/v2/shows/" + showId
        Alamofire.request(showUrl).responseJSON { (responseData) in
            let swiftyJsonVar = JSON(responseData.result.value!)
            if let showData = swiftyJsonVar["response"]["show"].dictionaryObject {
                self.dictShow = showData as [String : AnyObject]
            }
        }

        let episodesUrl = "https://api.spreaker.com/v2/shows/" + showId + "/episodes"
        Alamofire.request(episodesUrl).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let episodesData = swiftyJsonVar["response"]["items"].arrayObject {
                    self.arrEpisodes = episodesData as! [[String:AnyObject]]
                }
                if self.arrEpisodes.count > 0 {
                    self.tableView.reloadData()
                }
            }
        }
        self.tableView.rowHeight = CGFloat(70)
        self.navigationItem.title = self.dictShow["title"] as? String
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrEpisodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath)
        var singleEpisode = arrEpisodes[indexPath.row]
        
        //Title
        let mTitle = singleEpisode["title"] as? String
        let customCell = cell as! episodeCell
        customCell.titulo_label.text = mTitle
        
        //Date of publication
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        if let date = dateFormatterGet.date(from: (singleEpisode["published_at"] as? String)!) {
            let real_date_string = dateFormatterPrint.string(from: date)
            //Month
            let endOfmonth = real_date_string.firstIndex(of: " ")
            customCell.mes_label.text = String(real_date_string[...endOfmonth!])
            //Day
            let myCalendar = Calendar(identifier: .gregorian)
            let monthDay = myCalendar.component(.day, from: date)
            customCell.dia_label.text = String(monthDay)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id_episode = self.arrEpisodes[indexPath.row]["episode_id"] {
            //Pegando o id do episode
            let real_id_episode = id_episode as? NSNumber
            let id_episode_string = real_id_episode!.stringValue
            
            //Manda o id do episodio para o layerManager
            playerManager.shared.episodeDict = self.arrEpisodes[indexPath.row]

            self.performSegue(withIdentifier: "toPlayingVC", sender: self)

        }
    }
}
