//
//  resumoModel.swift
//  myPodcastApp
//
//  Created by William on 06/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

class Resumo {
    var cod_resumo : String
    var titulo : String
    var subtitulo : String
    var temporada : String
    var episodio : String
    var url_imagem : String
    var url_podcast_10 : String
    var url_podcast_40_p : String
    var url_podcast_40_f : String
    var resumo_10 : String
    var autores = [Autor]()
    
    var favoritado = 0
    var downloaded = 0
    var concluido = 0
    var iniciado = 0
    
    init(resumoEntity: ResumoEntity) {
        self.cod_resumo = resumoEntity.cod_resumo
        self.titulo = resumoEntity.titulo
        self.subtitulo = resumoEntity.subtitulo
        self.temporada = resumoEntity.temporada
        self.episodio = resumoEntity.episodio
        self.url_imagem = resumoEntity.url_imagem
        self.url_podcast_10 = resumoEntity.url_podcast_10
        self.url_podcast_40_p = resumoEntity.url_podcast_40_p
        self.url_podcast_40_f = resumoEntity.url_podcast_40_f
        self.resumo_10  = resumoEntity.resumo_10
        var autorList = [Autor]()
        for autorEntity in resumoEntity.autores {
            let newAutor = Autor(autorEntity: autorEntity)
            autorList.append(newAutor)
        }
        self.autores = autorList
    }
    
//    init?(resumoDict: [String:AnyObject]) {
//        guard let cod_resumo = resumoDict["cod_resumo"] else {
//            return nil
//        }
//        self.cod_resumo = cod_resumo as! String
//
//        guard let titulo = resumoDict["titulo"] else {
//            return nil
//        }
//        self.titulo = titulo as! String
//
//        guard let subtitulo = resumoDict["subtitulo"] else {
//            return nil
//        }
//        self.subtitulo = subtitulo as! String
//
//        guard let temporada = resumoDict["temporada"] else {
//            return nil
//        }
//        self.temporada = temporada as! String
//
//        guard let episodio = resumoDict["episodio"] else {
//            return nil
//        }
//        self.episodio = episodio as! String
//
//        guard let url_imagem = resumoDict["url_imagem"] else {
//            return nil
//        }
//        self.url_imagem = url_imagem as! String
//
//        guard let url_podcast_10 = resumoDict["url_podcast_10"] else {
//            return nil
//        }
//        self.url_podcast_10 = url_podcast_10 as! String
//
//        guard let url_podcast_40_p = resumoDict["url_podcast_40_p"] else {
//            return nil
//        }
//        self.url_podcast_40_p = url_podcast_40_p as! String
//
//        guard let url_podcast_40_f = resumoDict["url_podcast_40_f"] else {
//            return nil
//        }
//        self.url_podcast_40_f = url_podcast_40_f as! String
//
//        guard let resumo_10 = resumoDict["resumo_10"] else {
//            return nil
//        }
//        self.resumo_10 = resumo_10 as! String
//    }
}
