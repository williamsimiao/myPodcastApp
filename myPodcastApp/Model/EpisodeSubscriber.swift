//
//  EpisodeSubscriber.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

protocol EpisodeSubscriber: class {
    var currentEpisode: Episode? { get set }
}
