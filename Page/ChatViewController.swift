//
//  ViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/8/2.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import Foundation

//var globalTalkData = Array(repeating: CellData(), count: 1)

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var keyboardNeedLayout:Bool = true
    
    // 一些实验数据
    let textSaysWhat = SaysWhat(saysType: .text, saysContent: "Hello! I am Little Ice. I am a smart robot developed by Microsoft Company. What can I do for you?")
      //MARK:属性初始化时不能直接使用其他属性
    let textCellData = CellData(whoSays: .robot, saysWhat:SaysWhat(saysType: .text, saysContent: "Hello! I am Little Ice. I am a smart robot developed by Microsoft Company. What can I do for you?"))
    let imageSayWhat = SaysWhat(saysType: .image, saysImage: "landscape.jpeg")
    let imageCellData = CellData(whoSays: .robot, saysWhat: SaysWhat(saysType: .image, saysImage: "landscape.jpeg"))
    let cardSayWhat = SaysWhat(saysType:.card,saysTitle:"Look at the Beautiful landscape",saysDescription:"It is very beautiful, I love that place. When I was young,I have lived there for 2 years with my grandma.",saysCover:"landscape.jpeg")
    let cardCellData = CellData(whoSays: .robot, saysWhat: SaysWhat(saysType:.card,saysTitle:"Look at the Beautiful landscape",saysDescription:"It is very beautiful, I love that place. When I was young,I have lived there for 2 years with my grandma.",saysCover:"landscape.jpeg"))
    
    //TODO: 使用override func reloadData方法重新实现数据刷新功能
    var talkData = Array(repeating: CellData(), count: 1) {
    
        didSet {
            print("tableReloadData")
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
            let currentYouSaysWhat = SaysWhat(saysType: .text, saysContent: currentYourTalk)
            let currentYouCellData = CellData(whoSays: .you, saysWhat: currentYouSaysWhat)
            self.talkData.append(currentYouCellData)
            
            self.inputBlock.text = ""
            
            
            //var currentRobotTalk = ""
            //var currentRobotSaysWhat = SaysWhat()
            var currentRobotCellData = CellData()
            
            switch currentYourTalk {
                /*
            case "How are you":
                currentRobotTalk = "Fine"
                currentRobotSaysWhat = SaysWhat(saysType: .text, saysContent: currentRobotTalk)
                currentRobotCellData = CellData(whoSays: .robot, saysWhat: currentRobotSaysWhat)
            case "Hi":
                currentRobotTalk = "Hello"
                currentRobotSaysWhat = SaysWhat(saysType: .text, saysContent: currentRobotTalk)
                currentRobotCellData = CellData(whoSays: .robot, saysWhat: currentRobotSaysWhat)
            case "I love you":
                currentRobotTalk = "I love you, too"
                currentRobotSaysWhat = SaysWhat(saysType: .text, saysContent: currentRobotTalk)
                currentRobotCellData = CellData(whoSays: .robot, saysWhat: currentRobotSaysWhat)
                 */
            case "text":
                currentRobotCellData = self.textCellData
                self.talkData.append(currentRobotCellData)
            case "image":
                currentRobotCellData = self.imageCellData
                self.talkData.append(currentRobotCellData)
            case "card":
                currentRobotCellData = self.cardCellData
                self.talkData.append(currentRobotCellData)
            default:
                self.createTalkRequest(myInputText:currentYourTalk)
                /*
                
                currentRobotTalk = "What do you say?"
                currentRobotSaysWhat = SaysWhat(saysType: .text, saysContent: currentRobotTalk)
                currentRobotCellData = CellData(whoSays: .robot, saysWhat: currentRobotSaysWhat)
                
                talkData.append(currentRobotCellData)
                 */
            }
            
            //talkListBlock.reloadData()
            
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
                        self.view.frame = CGRect(x: 0, y: -deltaY + 64, width: self.view.bounds.width, height: self.view.bounds.height)
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
                    
                    self.view.frame = CGRect(x: 0, y: deltaY+64, width: self.view.bounds.width, height: self.view.bounds.height)
  
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
    
    func createTalkRequest (myInputText inputText:String = "") {
        
        print("Execute createTalkRequest")
        
        let bodyString = "{\"query\":\"\(inputText)\",\"messageType\":\"text\"}"
        let urlString = "https://sai-pilot.msxiaobing.com/api/Conversation/GetResponse?api-version=2017-06-15-Int"
        
        let appIdField = "x-msxiaoice-request-app-id"
        let appId = "XI36GDstzRkCzD18Fh"
        let secret = "5c3c48acd5434663897109d18a2f62c5"
        
        
        let timestampField = "x-msxiaoice-request-timestamp"
        let timestamp = Int(Date().timeIntervalSince1970)//生成时间戳
        print("timestamp:\(timestamp)")
        
        let userIdField = "x-msxiaoice-request-user-id"
        let userId = "e10adc3949ba59abbe56e057f20f883e"
        
        let signatureField = "x-msxiaoice-request-signature"
        print("signatureField:\(signatureField)")
        let signature = computeSignature(verb: "post", path: "/api/Conversation/GetResponse", paramList: ["api-version=2017-06-15-Int"], headerList: ["\(appIdField):\(appId)","\(userIdField):\(userId)"], body: bodyString, timestamp: timestamp, secretKey: secret)
        
        print("signature:\(signature)")
        
        if let url = URL(string: urlString),
            let body = bodyString.data(using: .utf8)
        { // 将String转化为Data
            var talkRequest = URLRequest(url:url)
            talkRequest.httpMethod = "POST"
            talkRequest.httpBody = body
            talkRequest.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            talkRequest.setValue(appId, forHTTPHeaderField: appIdField)
            talkRequest.setValue(String(timestamp), forHTTPHeaderField: timestampField)
            talkRequest.setValue(signature, forHTTPHeaderField: signatureField)
            talkRequest.setValue(userId, forHTTPHeaderField: userIdField)
            
            let talkRequestContentLengthValue = talkRequest.value(forHTTPHeaderField: "Content-Length") ?? ""
            let talkRequestUserIdValue = talkRequest.value(forHTTPHeaderField: userIdField) ?? ""
            print("talkRequest' userIdField value:\(talkRequestUserIdValue)")
            print("talkRequest' ContentLengthField value:\(talkRequestContentLengthValue)")
            //var  currentTableData = tableData
            (URLSession.shared.dataTask(with: talkRequest) {
                (data,response,error) in
                /*
                 if let response = response,
                 let data = data,
                 let string = String(data: data, encoding: .utf8) {
                 print("Response:\(response)")
                 print("DATA:\n\(string) \n End DATA \n")
                 
                 } else if let error = error {
                 print("Error:\(error)")
                 }
                 */
                if error != nil {
                    /* wycNOTE:
                     * guard语句的执行取决于一个表达式的布尔值。可以使用guard语句来要求条件必须为真时，以执行guard语句后面的代码。不同于if语句，一个guard语句总是有一个else从句，条件不为真则执行else从句中的代码
                     */
                    print("Error:(error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("Status code is not 200. It is \(httpStatus.statusCode)")
                    return
                }
                
                if let data = data, let dataString = String(data: data, encoding: .utf8){
                    print("Overview Data:\(dataString)")
                    //var myTalkData = tableData
                    let defaultRobotTalk = "What do you say?"
                    let defaultRobotSaysWhat = SaysWhat(saysType: .text, saysContent: defaultRobotTalk)
                    let defaultRobotCellData = CellData(whoSays: .robot, saysWhat: defaultRobotSaysWhat)
                    
                    let responseCellData = createResponseCellData(data: data) ?? defaultRobotCellData
                    self.talkData.append(responseCellData)
                  
                    
                    
                }
                
            }).resume()
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.talkListBlock.delegate = self
        self.talkListBlock.dataSource = self // MARK:两个协议代理，一个也不能少
        
        self.talkListBlock.separatorStyle = .none //MARK:删除cell之间的分割线
        
        
        self.talkData.append(self.textCellData)
        self.talkData.append(self.imageCellData)
        self.talkData.append(self.cardCellData)

        
        
  
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
