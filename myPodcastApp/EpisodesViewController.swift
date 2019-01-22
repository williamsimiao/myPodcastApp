//
//  EpisodesViewController.swift
//  myPodcastApp
//
//  Created by William on 22/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation
import Network
import Alamofire
import AlamofireImage
import SwiftyJSON

class EpisodesViewController: UIViewController, UITableViewDataSource, UITabBarDelegate {
    
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    let valor = 5
    var arrEpisodes = [[String:AnyObject]]()
    var dictShow = [String:AnyObject]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request("https://api.spreaker.com/v2/shows/2885428/episodes").responseJSON { (responseData) -> Void in
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
        
        //Show data
        Alamofire.request("https://api.spreaker.com/v2/shows/2885428").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                if let showData = swiftyJsonVar["response"]["show"].dictionaryObject {
                    self.dictShow = showData as [String:AnyObject]
                    self.navigationItem.title = self.dictShow["title"] as? String
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrEpisodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath)
        var singleEpisode = arrEpisodes[indexPath.row]
        let mTitle = singleEpisode["title"] as? String
        cell.textLabel?.text = mTitle
        cell.detailTextLabel?.text = singleEpisode["published_at"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playingVC = storyboard.instantiateViewController(withIdentifier: "PlayingViewController") as! PlayingViewController
        
        
        //Image Cover
        if let imgUrl = arrEpisodes[indexPath.row]["image_url"] {
            print(imgUrl)
            playingVC.imageUrl = imgUrl as! String
        }
        
        
        
        //Descritption
        if arrEpisodes[indexPath.row]["description"] as? String != nil {
            playingVC.descriptionText.text = arrEpisodes[indexPath.row]["description"] as? String
        }
        //Player
        playingVC.player = self.player
        self.navigationController?.pushViewController(playingVC, animated: true)
        print(arrEpisodes[indexPath.row]["episode_id"])
        //        print(arrEpisodes[indexPath.row]["episode_id"]?.isKind(of: ))
        //        String()
        //        changePlayingEpisode(episodeId: String(arrEpisodes[indexPath.row]["episode_id"] ))
        
    }
    
    @IBAction func rewind_action(_ sender: Any) {
    }
    
    @IBAction func play_action(_ sender: Any) {
    }
    
    @IBAction func foward_action(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
