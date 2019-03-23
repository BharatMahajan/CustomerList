//
//  HomeViewController.swift
//  CustomerList
//
//  Created by Bharat Mahajan on 22/03/19.
//  Copyright © 2019 BharatMahajan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
