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
    
    static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    static func convertSecondsToDateString(seconds:Float64) -> String {
        let parts = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        return String(parts.0) + ":" + String(parts.1) + ":" + String(parts.2)

    }

    
}
