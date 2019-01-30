//
//  Episode.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

struct Episode {
    
    // MARK: - Properties
    let title: String
    var duration: TimeInterval = 0
    let artist: String
    var mediaURL: URL?
    var coverArtURL: URL?
}
