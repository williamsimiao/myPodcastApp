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
    private var playerItemContext = 0

    @IBOutlet weak var tabbar_play_button: UIBarButtonItem!
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
            self.tableView.rowHeight = CGFloat(70)
            
            if playerManager.shared.getIsPlaying() {
                let pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(EpisodesViewController.play_action(_:)))
                
                self.tabbar_play_button = pauseButton
            }
            else {
                let playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(EpisodesViewController.play_action(_:)))
                self.tabbar_play_button = playButton
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
            print("DD")
            let real_date_string = dateFormatterPrint.string(from: date)
            print(real_date_string)
            //Month
            let endOfmonth = real_date_string.firstIndex(of: " ")
            customCell.mes_label.text = String(real_date_string[...endOfmonth!])
            //Day
            let myCalendar = Calendar(identifier: .gregorian)
            let monthDay = myCalendar.component(.day, from: date)
            customCell.dia_label.text = String(monthDay)
        }
        
        
//        cell.textLabel?.text = mTitle
//        cell.detailTextLabel?.text = singleEpisode["published_at"] as? String
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
    
    func getUrl(from episodeId:String) -> URL{
        let urlString = "https://api.spreaker.com/v2/episodes/" + episodeId + "/play"
        //        let urlString = "https://api.spreaker.com/download/episode/16767333/t2021_smart_money_joao_kepler.mp3"
        print(urlString)
        return URL(string: urlString)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id_episode = self.arrEpisodes[indexPath.row]["episode_id"] {
            //Pegando o id do episode
            let real_id_episode = id_episode as? NSNumber
            let id_episode_string = real_id_episode!.stringValue
            
            let audioUrl = getUrl(from: id_episode_string)
            let myAsset = AVAsset(url: audioUrl)
            let playerItem = AVPlayerItem(asset: myAsset)
            if id_episode_string != playerManager.shared.currentEpisodeId {
                let selectedCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! episodeCell
                
                selectedCell.activity_indicator.startAnimating()
                
                playerItem.addObserver(self,
                                       forKeyPath: #keyPath(AVPlayerItem.status),
                                       options: [.old, .new],
                                       context: &self.playerItemContext)
                
                if playerManager.shared.getPlayerIsSet() {
                    playerManager.shared.changePlayingEpisode(episodeId: id_episode_string, mPlayerItem: playerItem)
                } else {
                    playerManager.shared.player_setup(episodeId: id_episode_string, motherView: self.view, mPlayerItem: playerItem)
                }
            }
            else {
                self.performSegue(withIdentifier: "toPlayingVC", sender: self)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
                
                let selectedCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! episodeCell
                selectedCell.activity_indicator.stopAnimating()
                self.performSegue(withIdentifier: "toPlayingVC", sender: self)
            case .failed:
                let alert = UIAlertController(title: "Erro", message: "Não foi possivel tocar o episódio", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            default: break
            }
        }
    }
    
    @IBAction func rewind_action(_ sender: Any) {
        playerManager.shared.rewind()
    }
    
    @IBAction func play_action(_ sender: Any) {
//        switch playerManager.shared.getIsPlaying() {
//        case true:
//            if let pauseImg = UIImage(named: "pause_36") {
//                tabbar_play_button.setBackgroundImage(pauseImg, for: UIControl.State.normal, barMetrics: UIBarMetrics)
//            }
//        default:
//            if let playImg = UIImage(named: "play_36") {
//                tabbar_play_button.setBackgroundImage(playImg, for: UIControl.State.normal, barMetrics: UIBarMetrics)
//            }
//        }
        
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
