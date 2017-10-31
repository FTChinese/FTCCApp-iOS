//
//  PersonInfoViewController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PersonInfoViewController: UIViewController {
    
    @IBOutlet weak var mySubscribeView: UIView!
    @IBOutlet weak var myDownloadView: UIView!
    @IBOutlet weak var mySettingView: UIView!
    @IBOutlet weak var myLoveView: UIView!
//    @IBOutlet weak var subscribeTableViewCell: UITableViewCell!
//    @IBOutlet weak var downloadTableViewCell: UITableViewCell!
//    @IBOutlet weak var favoritesTableViewCell: UITableViewCell!
//    @IBOutlet weak var settingTableViewCell: UITableViewCell!
//    @IBOutlet weak var walletTableViewCell: UITableViewCell!
    @IBAction func tapMySubscribe(_ sender: Any) {

    }
    @IBAction func tapMyDownload(_ sender: Any) {
       if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListPerColumnViewController") as? ListPerColumnViewController
        {
            
            navigationController?.pushViewController(mySubscribeViewController, animated: true)
        }
    }
    @IBAction func tapMySettinge(_ sender: Any) {
        
    }
    @IBAction func tapMyLove(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.infoTableView.separatorStyle = .none

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    




}
