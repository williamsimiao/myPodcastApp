//
//  episodeCell.swift
//  myPodcastApp
//
//  Created by William on 23/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class episodeCell: UITableViewCell {

    @IBOutlet weak var titulo_label: UILabel!
    @IBOutlet weak var dia_label: UILabel!
    @IBOutlet weak var mes_label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
