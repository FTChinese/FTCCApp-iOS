//
//  PersonInfoViewController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

class PersonInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
//    @IBOutlet weak var mySubscribeView: UIView!
//    @IBOutlet weak var myDownloadView: UIView!
//    @IBOutlet weak var mySettingView: UIView!
//    @IBOutlet weak var myLoveView: UIView!
    @IBOutlet weak var infoTableView: UITableView!
//    @IBOutlet weak var infoTableViewCell: UITableViewCell!

  
    @IBAction func tapMyDownload(_ sender: Any) {
       if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListPerColumnViewController") as? ListPerColumnViewController
        {
            
            navigationController?.pushViewController(mySubscribeViewController, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoTableView.delegate = self
        self.infoTableView.dataSource = self
        self.infoTableView.separatorStyle = .none
        self.infoTableView.isScrollEnabled = false
        self.infoTableView.register(UINib.init(nibName: "PersonInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonInfoTableViewCell")
        self.infoTableView.register(UINib.init(nibName: "CollectTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectTableViewCell")
        self.infoTableView.register(UINib.init(nibName: "PortraitTableViewCell", bundle: nil), forCellReuseIdentifier: "PortraitTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
           return 4
        }

    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section==1 && indexPath.row == 0{
            if let mySubscribeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MySubscribeViewController") as? MySubscribeViewController {

                navigationController?.pushViewController(mySubscribeViewController, animated: true)
            }
        }


    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let reuseIdentifier = ''
//        let cellItem = tableView.dequeueReusableCell(withIdentifier: "PersonInfoTableViewCell", for: indexPath)
        if indexPath.section == 0{
            let cellItem = tableView.dequeueReusableCell(withIdentifier: "PortraitTableViewCell") as! PortraitTableViewCell
            return cellItem

        }else{

            let cellItem = tableView.dequeueReusableCell(withIdentifier: "PersonInfoTableViewCell") as! PersonInfoTableViewCell
            let name = personInfo.infoMap[indexPath.row]["imageName"]
            print("personInfo value--")
            cellItem.imageButton.setImage(UIImage(named:name as! String), for: UIControlState.normal)
            cellItem.tagLabel.text = personInfo.infoMap[indexPath.row]["tagName"] as! String
                return cellItem

        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 100.0
        }else{
            return 60.0
        }
    }

}
