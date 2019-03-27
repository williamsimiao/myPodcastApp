
//
//  Download.swift
//  myPodcastApp
//
//  Created by William on 27/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

class Download {
    var resumo: Resumo
    init(resumo: Resumo) {
        self.resumo = resumo
    }
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    var progress: Float = 0
}
