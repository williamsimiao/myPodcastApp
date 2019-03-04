//
//  resumo.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import RealmSwift

class Resumo: Object {
    @objc dynamic var cod_resumo = ""
    @objc dynamic var titulo = ""
    @objc dynamic var subtitulo = ""
    @objc dynamic var temporada = ""
    @objc dynamic var episodio = ""
    @objc dynamic var url_imagem = ""
    @objc dynamic var url_podcast_10 = ""
    @objc dynamic var url_podcast_40_p = ""
    @objc dynamic var url_podcast_40_f = ""
    @objc dynamic var resumo_10 = ""
    @objc dynamic var autores = ""
    
    @objc dynamic var favoritado = 0
    @objc dynamic var downloaded = 0
    @objc dynamic var concluido = 0
    
    override static func primaryKey() -> String? {
        return "cod_resumo"
    }
}
