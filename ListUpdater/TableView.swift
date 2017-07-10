//
//  TableView.swift
//  ListUpdater
//
//  Created by Joe's MacBook Pro on 2017/7/9.
//  Copyright © 2017年 joe. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    var tableUpdater:TableViewUpdater!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tableUpdater = TableViewUpdater(tableView: self.tableView)
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "reload", style: .plain, target: self, action: #selector(reload))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload() -> Void {
//        self.tableUpdater.animateReload(newData: randomData())
        DispatchQueue.global().async {
            for _ in 0...1000 {
                DispatchQueue.main.async {
                    self.tableUpdater.animateReload(newData: randomData())
                }
            }
        }
    }
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableUpdater.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableUpdater.dataSource[section].sectionItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = tableUpdater.dataSource[indexPath.section].sectionItems[indexPath.row]
        cell.textLabel?.text = data.diffIdentifier
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let data = tableUpdater.dataSource[section]
        return data.diffIdentifier
    }
}
