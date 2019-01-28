//
//  ShowsViewController.swift
//  myPodcastApp
//
//  Created by William on 24/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import AVFoundation

class ShowsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var arrShows = [[String:AnyObject]]()
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var miniView: UIView!
    @IBOutlet weak var miniCoverImg: UIImageView!
    @IBOutlet weak var miniPlayButton: UIButton!
    @IBOutlet weak var miniLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let arrShowsId = Util.getPlist(withName: "ShowsIDs")
        print(arrShowsId as Any)
        for showId in arrShowsId! {
            let showUrl = "https://api.spreaker.com/v2/shows/" + showId
            Alamofire.request(showUrl).responseJSON { (responseData) in
                let swiftyJsonVar = JSON(responseData.result.value!)
                if let showData = swiftyJsonVar["response"]["show"].dictionaryObject {
                    self.arrShows.append(showData as [String : AnyObject])
                }
                if self.arrShows.count > 0 {
                    self.CollectionView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if playerManager.shared.currentEpisodeId != nil {
            self.setUpMiniView()
            self.miniView.isHidden = false
        }
    }
    
    func setUpMiniView() {
        Util.setMiniCoverImg(with: playerManager.shared.currentShowImageUrl!, theImage: self.miniCoverImg)
        self.miniLabel.text = playerManager.shared.currentEpisodeTitle
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as! ShowCollectionCell
        
        cell.backgroundColor = .gray
        let url = URL(string:self.arrShows[indexPath.row]["image_url"] as! String)!
        let placeholderImage = UIImage(named: "cover_placeholder")!
        cell.coverImg.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage
        )
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toEpisodeVC") {
            let episodesVC = segue.destination as! EpisodesViewController
            if let indexPath = CollectionView.indexPathsForSelectedItems?.first {
                episodesVC.dictShow = self.arrShows[indexPath.row]
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toEpisodeVC", sender: self)
    }
    
    @IBAction func miniPlayButtonAction(_ sender: Any) {
        switch playerManager.shared.getIsPlaying() {
        case true:
            if let playImg = UIImage(named: "playBranco_36") {
                self.miniPlayButton.setImage(playImg, for: UIControl.State.normal)
            }
            
        default:
            if let pauseImg = UIImage(named: "pauseBranco_36") {
                self.miniPlayButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        playerManager.shared.play()

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.view.frame.width - 4) / 3.0 , height: (self.view.frame.width - 4) / 3.0)
    }
    
    
    @IBAction func addNewShowButton(_ sender: Any) {
        
    }

}
