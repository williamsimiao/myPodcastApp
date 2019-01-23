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

class EpisodesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let playingVC = segue.destination as? PlayingViewController
        if let indexPath = self.tableView.indexPathForSelectedRow {
            
            if let imgUrl = self.arrEpisodes[indexPath.row]["image_original_url"] {
                playingVC?.imageUrl = imgUrl as! String
            }
            
            if let episodeDescription = self.arrEpisodes[indexPath.row]["description"] {
                playingVC?.descriptionText.text = episodeDescription as? String
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id_episode = self.arrEpisodes[indexPath.row]["episode_id"] {
            let real_id_episode = id_episode as? NSNumber
            let id_episode_string = real_id_episode!.stringValue
            if playerManager.shared.getPlayerIsSet() {
                playerManager.shared.changePlayingEpisode(episodeId: id_episode_string)
            } else {
                playerManager.shared.player_setup(episodeId: id_episode_string, motherView: self.view)
            }
        }
        
        self.performSegue(withIdentifier: "toPlayingVC", sender: self)
    }
    
    @IBAction func rewind_action(_ sender: Any) {
        playerManager.shared.rewind()
    }
    
    @IBAction func play_action(_ sender: Any) {
        playerManager.shared.play()
    }
    
    @IBAction func foward_action(_ sender: Any) {
        playerManager.shared.foward()
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
