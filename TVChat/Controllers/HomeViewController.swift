//
//  HomeViewController.swift
//  Pods
//
//  Created by Satoshi Yokokawa on 2022/10/24.
//

import UIKit

class HomeViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.parent?.navigationItem.title = "TVChat"
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.white
        ]
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
