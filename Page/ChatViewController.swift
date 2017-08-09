//
//  ViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/2.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var keyboardNeedLayout:Bool = true
    
    //TODO: 使用override func reloadData方法重新实现数据刷新功能
    var talkData = Array(repeating:CellData(), count:6){
        didSet{
            self.talkListBlock.reloadData()
            //let num = talkData.count
            let currentIndexPath = IndexPath(row: talkData.count-1, section: 0)
            //let firstIndexPath = IndexPath(row: 0, section: 0)
            
            self.talkListBlock?.scrollToRow(at: currentIndexPath, at: .bottom, animated: true)
            
        }
    }
 

    @IBOutlet weak var talkListBlock: UITableView!
    
    @IBOutlet weak var inputBlock: UITextField!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.inputBlock.resignFirstResponder()

    }
 

    @IBAction func sendYourTalk(_ sender: UIButton) {
        if let currentYourTalk = inputBlock.text {
            let currentYourCellData = CellData(whoSays: .you, saysWhat: currentYourTalk)
            talkData.append(currentYourCellData)
            
            self.inputBlock.text = ""
            
            var currentRobotTalk = ""
            switch currentYourTalk {
            case "How are you":
                currentRobotTalk = "Fine"
            case "Hi":
                currentRobotTalk = "Hello"
            case "I love you":
                currentRobotTalk = "I love you, too"
            default:
                currentRobotTalk = "What do you say?"
            }
            let currentRobotCellData = CellData(whoSays: .robot, saysWhat: currentRobotTalk)
            talkData.append(currentRobotCellData)
            
        }

    }

    func keyboardWillShow(_ notification: NSNotification) {
        print("show")
        
        if let userInfo = notification.userInfo, let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt{
            let keyboardFrame = value.cgRectValue
            
            print(keyboardFrame.height)
            
            let intersection = self.view.frame.intersection(keyboardFrame) // 求当前view的frame与keyboardFrame的交集
            let deltaY = intersection.height
             print(deltaY)
            
            if keyboardNeedLayout {
                UIView.animate(
                    withDuration: duration,
                    delay: 0.0,
                    options: UIViewAnimationOptions(rawValue: curve),
                    animations: { _ in
                        // FIXME: There is an spooky black bar above keyboard whose height is 64. Now my temporary solution is cutting of the bar forcibly
                        self.view.frame = CGRect(x: 0, y: -deltaY+64, width: self.view.bounds.width, height: self.view.bounds.height)
                        //self.talkListBlock.frame = CGRect(x:0,y: deltaY,width:self.talkListBlock.bounds.width,height: self.talkListBlock.bounds.height - deltaY)
                        self.keyboardNeedLayout = false
                        self.view.layoutIfNeeded()
                        
                },
                    completion: nil
                )
            }
            
            
            
        }
        
    }
    func keyboardWillHide(_ notification: NSNotification) {
        print("hide")
        if let userInfo = notification.userInfo, let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt{
            let keyboardFrame = value.cgRectValue
            
            print(keyboardFrame.height)
            let intersection = self.view.frame.intersection(keyboardFrame) // 求当前view的frame与keyboardFrame的交集
            let deltaY = intersection.height
 
 
            print(deltaY)
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: UIViewAnimationOptions(rawValue: curve),
                animations: { _ in
                    
                    self.view.frame = CGRect(x: 0, y: deltaY + 64, width: self.view.bounds.width, height: self.view.bounds.height)
  
                    self.keyboardNeedLayout = true
                    self.view.layoutIfNeeded()
                    
            },
                completion: nil
            )
            
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.talkData.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellData = self.talkData[indexPath.row]
        let currentHeight = max(currentCellData.cellHeightByHeadImage, currentCellData.cellHeightByBubble)
        return currentHeight
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellData = self.talkData[indexPath.row]
        let cell = OneTalkCell(cellData, reuseId:"Talk")
        return cell
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.talkListBlock.delegate = self
        self.talkListBlock.dataSource = self // MARK:两个协议代理，一个也不能少
        
        self.talkListBlock.separatorStyle = .none //MARK:删除cell之间的分割线
        
        self.talkData.append(CellData(whoSays: .robot, saysWhat: "Hello! I am Little Ice. I am a smart robot developed by Microsoft Company. What can I do for you?"))
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
