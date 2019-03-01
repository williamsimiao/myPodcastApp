//
//  resumo.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import RealmSwift

class Resumo: Object {
    @objc dynamic var cod_resumo = ""
    @objc dynamic var titulo = ""
    @objc dynamic var subtitulo = ""
    @objc dynamic var url_podcast_10 = ""
    @objc dynamic var url_podcast_40_p = ""
    @objc dynamic var url_podcast_40_f = ""
    @objc dynamic var resumo_10 = ""
    @objc dynamic var favoritado = true
    @objc dynamic var downloaded = true
    @objc dynamic var concluido = true
}
