//
//  tableViewWithHeader.swift
//  myPodcastApp
//
//  Created by William on 12/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class tableViewWithHeader: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var itemsToLoad: [String] = ["One", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three", "Two", "Three"]

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    func commonInit() {
        Bundle.main.loadNibNamed("tableViewWithHeader", owner: self, options: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        headerLabel.text = "Testando"
        self.addSubview(contentView)
        self.addSubview(headerLabel)
        self.addSubview(tableView)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsToLoad.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = itemsToLoad[indexPath.row]
        return cell
    }
}
