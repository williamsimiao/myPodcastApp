//
//  tableViewWithHeader.swift
//  myPodcastApp
//
//  Created by William on 12/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class tableViewWithHeader: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
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
        self.addSubview(headerLabel)
        self.addSubview(tableView)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
    }
}
