//
//  ViewController.swift
//  ListUpdater
//
//  Created by Joe's MacBook Pro on 2017/7/9.
//  Copyright © 2017年 joe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func table(_ sender: Any) {
        self.navigationController?.pushViewController(TableViewController.init(nibName: nil, bundle: nil), animated: true)
    }

    @IBAction func collection(_ sender: Any) {
        self.navigationController?.pushViewController(CollectionViewController.init(nibName: nil, bundle: nil), animated: true)
    }
}

