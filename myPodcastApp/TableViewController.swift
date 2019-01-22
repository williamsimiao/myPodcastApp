//
//  TableViewController.swift
//  myPodcastApp
//
//  Created by William on 21/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation
import Network
import Alamofire
import AlamofireImage
import SwiftyJSON

class TableViewController: UITableViewController {

    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    let valor = 5
    var arrEpisodes = [[String:AnyObject]]()
    var dictShow = [String:AnyObject]()
    @IBOutlet var tblEpisodes: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //Episode data
        Alamofire.request("https://api.spreaker.com/v2/shows/2885428/episodes").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let episodesData = swiftyJsonVar["response"]["items"].arrayObject {
                    self.arrEpisodes = episodesData as! [[String:AnyObject]]
                }
                if self.arrEpisodes.count > 0 {
                    self.tblEpisodes.reloadData()
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
        
//        Network.instance.download(downloadUrl: "https://jsonplaceholder.typicode.com/posts/1", saveUrl: "file.json", completion: { results in
//            print("Success post title:", results["title"].stringValue)
//        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.arrEpisodes.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let murl = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
        player_setup(url: murl!)
        player?.play()
    }
    
    func changePlayingEpisode(episodeId:String) {
        let urlString = "https://api.spreaker.com/v2/episodes/" + episodeId + "/play"
        let audioUrl = URL(string: urlString)
        let mPlayerItem = AVPlayerItem(url: audioUrl!)
        player?.replaceCurrentItem(with: mPlayerItem)
    }
    
    func player_setup(url:URL) {
        let playerItem:AVPlayerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer=AVPlayerLayer(player: player!)
        playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
        self.view.layer.addSublayer(playerLayer)
    }
    
    @IBAction func back_action(_ sender: Any) {
        let currentTime = player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) - Double(valor), preferredTimescale: currentTime!.timescale)
        player?.seek(to: jump)
    }
    
    @IBAction func play_action(_ sender: Any) {
        if player?.rate == 0 {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    @IBAction func foward_action(_ sender: Any) {
        let currentTime = player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) + Double(valor), preferredTimescale: currentTime!.timescale)
        player?.seek(to: jump)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath)
        var singleEpisode = arrEpisodes[indexPath.row]
        let mTitle = singleEpisode["title"] as? String
        cell.textLabel?.text = mTitle
        cell.detailTextLabel?.text = singleEpisode["published_at"] as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
