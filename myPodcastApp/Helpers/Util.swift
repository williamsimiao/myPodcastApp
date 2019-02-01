//
//  Util.swift
//  myPodcastApp
//
//  Created by William on 25/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import UIKit

class Util {
    static func getUrl(forPlayingEpisode episodeId:NSNumber) -> URL{
        let episodeIdString = episodeId.stringValue
        let urlString = "https://api.spreaker.com/v2/episodes/" + episodeIdString + "/play"
        return URL(string: urlString)!
    }
    
}
