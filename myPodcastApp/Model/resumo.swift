//
//  resumo.swift
//  myPodcastApp
//
//  Created by William on 11/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

struct Resumo : Codable {
    // MARK: - Properties
    let cod_resumo : Int
    let titulo : String?
    let subtitulo : String?
//    let descricao : String?
    let temporada : Int
    let episodio : Int
    let url_imagem : String?
    let url_podcast_10 : String?
    
//    //premium - sem ads
//    let url_podcast_40_p : String?
//    //free - com ads
//    let url_podcast_40_f : String?
//    let resumo_10 : String?
//    let cod_status : Int
//    let qtd_podcast_10 : Int
//    let qtd_podcast_40_p : Int
//    let qtd_podcast_40_f : Int
//    let qtd_resumo_10 : Int
//    let views : Int
//    let pubDate : Int
//    let created : Date
//    let modified : Date
}
