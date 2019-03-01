//
//  resumo.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import RealmSwift

class Specimen: Object {
    @objc dynamic var name = ""
    @objc dynamic var author = ""
    @objc dynamic var audio_free_url = ""
    @objc dynamic var audio_premium_40_url = ""
    @objc dynamic var audio_premium_10_url = ""
    @objc dynamic var favoritado = false
    @objc dynamic var downloaded = false
    @objc dynamic var concluido = false
}
