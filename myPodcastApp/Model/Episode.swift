//
//  Episode.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

struct Episode : Codable {
    
    // MARK: - Properties
    let title: String?
    var duration: TimeInterval = 0
    var streamingURL: URL?
    var coverArtURL: URL?
}



