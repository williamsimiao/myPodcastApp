//
//  EpisodesViewController.swift
//  myPodcastApp
//
//  Created by William on 22/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class EpisodesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var playerItem:AVPlayerItem?
    let valor = 5
    var arrEpisodes = [[String:AnyObject]]()
    var dictShow = [String:AnyObject]()
    private var playerItemContext = 0

    @IBOutlet weak var miniCoverImg: UIImageView!
    @IBOutlet weak var miniPlayButton: UIButton!
    @IBOutlet weak var miniView: UIView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let showId = self.dictShow["show_id"]
        let real_id_show = showId as? NSNumber
        let id_show_string = real_id_show!.stringValue

        let showUrl = "https://api.spreaker.com/v2/shows/" + id_show_string + "/episodes"
        
        Alamofire.request(showUrl).responseJSON { (responseData) -> Void in
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
    
    override func viewWillAppear(_ animated: Bool) {
        if playerManager.shared.currentEpisodeId != nil {
            self.setUpMiniView()
            self.miniView.isHidden = false
        }
    }
    
    func setUpMiniView() {
        Util.setMiniCoverImg(with: playerManager.shared.currentShowImageUrl!, theImage: self.miniCoverImg)
        if playerManager.shared.getIsPlaying() {
            if let pauseImg = UIImage(named: "pauseBranco_36") {
                self.miniPlayButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        else {
            if let playImg = UIImage(named: "playBranco_36") {
                self.miniPlayButton.setImage(playImg, for: UIControl.State.normal)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let playingVC = segue.destination as? PlayingViewController
        if let indexPath = self.tableView.indexPathForSelectedRow {
            
            if let imgUrl = self.arrEpisodes[indexPath.row]["image_url"] {
                playerManager.shared.currentShowImageUrl = (imgUrl as! String)
                playingVC?.imageUrl = imgUrl as! String
            }
            
            if let episodeDescription = self.arrEpisodes[indexPath.row]["description"] {
                playingVC?.descriptionText.text = episodeDescription as? String
            }
        }
    }
    
    func getUrl(from episodeId:String) -> URL{
        let urlString = "https://api.spreaker.com/v2/episodes/" + episodeId + "/play"
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
                if playerManager.shared.getPlayerIsSet() {
                    playerManager.shared.changePlayingEpisode(episodeId: id_episode_string, mPlayerItem: playerItem)
                } else {
                    playerManager.shared.player_setup(episodeId: id_episode_string, motherView: self.view, mPlayerItem: playerItem)
                }
                DispatchQueue.global(qos: .background).async {
                    while !playerManager.shared.getIsPlaying() {}
                    DispatchQueue.main.async {
                        selectedCell.activity_indicator.stopAnimating()
                        self.performSegue(withIdentifier: "toPlayingVC", sender: self)
                    }
                }
            }
            else {
                self.performSegue(withIdentifier: "toPlayingVC", sender: self)
            }
        }
    }
    
    @IBAction func miniPlayAction(_ sender: Any) {
        switch playerManager.shared.getIsPlaying() {
        case true:
            if let playImg = UIImage(named: "playBranco_36") {
                self.miniPlayButton.setImage(playImg, for: UIControl.State.normal)
            }
            
        default:
            if let pauseImg = UIImage(named: "pauseBranco_36") {
                miniPlayButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        playerManager.shared.play()

    }
}
