//
//  AudioPlayerController.swift
//  Page
//
//  Created by huiyun.he on 22/08/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import WebKit
import SafariServices

class TabBarAudioContent {
    static let sharedInstance = TabBarAudioContent()
    var body = [String: String]()
    var item: ContentItem?
    var player:AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil
    var audioHeadLine: String? = nil
    var audioUrl: URL? = nil
    var duration: CMTime? = nil
    var time:CMTime? = nil
    var sliderValue:Float? = nil
    var isPlaying:Bool=false
    var isPlayFinish:Bool=false
    var isPlayStart:Bool=false
    var fetchResults: [ContentSection]?
    var items = [ContentItem]()
    var mode:Int?
    var playingIndex:Int?
}


class AudioPlayerController: UIViewController,UIScrollViewDelegate,WKNavigationDelegate,UIViewControllerTransitioningDelegate,UIGestureRecognizerDelegate{
    
    private var audioTitle = ""
    private var audioUrlString = ""
    private var audioId = ""
    private lazy var player: AVPlayer? = nil
    private lazy var playerItem: AVPlayerItem? = nil
    //    private lazy var webView: WKWebView? = nil
    private let nowPlayingCenter = NowPlayingCenter()
    private let download = DownloadHelper(directory: "audio")
    
    private var queuePlayer:AVQueuePlayer?
    private var playerItems: [AVPlayerItem]? = []
    private var urls: [URL] = []
    private var urlStrings: [String]? = []
    private var urlOrigStrings: [String] = []
    private var urlTempStrings: [String] = []
    private var urlAssets: [AVURLAsset]? = []
    
    var item: ContentItem?
    var themeColor: String?
    
    var fetchAudioResults: [ContentSection]?
    var fetchesAudioObject = ContentFetchResults(
        apiUrl: "",
        fetchResults: [ContentSection]()
    )
    let imageWidth = 408   // 16 * 52
    let imageHeight = 234  // 9 * 52
    private var playingUrlStr:String? = ""
    private var playingIndex:Int = 0
    private var playingUrl:URL? = nil
    var count:Int = 0
    var tabView = CustomSmallPlayView()
    
    let love = UIButton()
    let downloadButton = UIButtonEnhanced()
    let playlist = UIButton()
    let share = UIButton()
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var preAudio: UIButton!
    @IBOutlet weak var nextAudio: UIButton!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playStatus: UILabel!
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var back: UIButton!
    
    @IBAction func hideAudioButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        print("this hideAudioButton")
    }
    @objc func openPlayList(_ sender: UIButton) {
        if let listPerColumnViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListPerColumnViewController") as? ListPerColumnViewController {
            listPerColumnViewController.fetchListResults = TabBarAudioContent.sharedInstance.fetchResults
            listPerColumnViewController.modalPresentationStyle = .custom
            self.present(listPerColumnViewController, animated: true, completion: nil)
        }
    }
    @IBAction func ButtonPlayPause(_ sender: UIButton) {
        if let player = player {
            print("ButtonPlayPause\(player)")
            if player.rate != 0 && player.error == nil {
                player.pause()
                playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = false
            } else {
                player.play()
                player.replaceCurrentItem(with: playerItem)
                playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
                TabBarAudioContent.sharedInstance.isPlaying = true
                // TODO: - Need to find a way to display media duration and current time in lock screen
                var mediaLength: NSNumber = 0
                if let d = self.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        mediaLength = duration as NSNumber
                    }
                }
                
                var currentTime: NSNumber = 0
                if let c = self.playerItem?.currentTime() {
                    let currentTime1 = CMTimeGetSeconds(c)
                    if currentTime1.isNaN == false {
                        currentTime = currentTime1 as NSNumber
                    }
                }
                nowPlayingCenter.updateInfo(
                    title: audioTitle,
                    artist: "FT中文网",
                    albumArt: UIImage(named: "cover.jpg"),
                    currentTime: currentTime,
                    mediaLength: mediaLength,
                    PlaybackRate: 1.0
                )
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    @IBAction func switchToPreAudio(_ sender: UIButton) {
        count = (urlOrigStrings.count)
        removePlayerItemObservers()
        print("urlString playingIndex pre\(playingIndex)")
        if fetchAudioResults != nil {
            playingIndex = playingIndex-1
            if playingIndex < 0{
                playingIndex = count - 1
                
            }
            updateSingleTonData()
            prepareAudioPlay()
        }
    }
    @IBAction func switchToNextAudio(_ sender: UIButton) {
        count = (urlOrigStrings.count)
        if fetchAudioResults != nil {
            removePlayerItemObservers()
            playingIndex += 1
            if playingIndex >= count{
                playingIndex = 0
            }
            print("urlString playingIndex\(playingIndex)")
            updateSingleTonData()
            prepareAudioPlay()
            
        }
        
    }
    
    @IBAction func skipForward(_ sender: UIButton) {
        let currentSliderValue = self.progressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue + 15), 1)
        playerItem?.seek(to: currentTime)
        self.progressSlider.value = currentSliderValue + 15
    }
    @IBAction func skipBackward(_ sender: UIButton) {
        let currentSliderValue = self.progressSlider.value
        let currentTime = CMTimeMake(Int64(currentSliderValue - 15), 1)
        playerItem?.seek(to: currentTime)
        self.progressSlider.value = currentSliderValue - 15
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
        //        NowPlayingCenter().updatePlayingCenter()
        
    }
    
    
    
    @objc func favorite(_ sender: UIButton) {
        print("hideAudioButton favorite button")
    }
    
    
    @objc func share(_ sender: UIButton) {
        if let item = item {
            self.launchActionSheet(for: item)
        }
    }
    @objc func download(_ sender: Any) {
        let body = TabBarAudioContent.sharedInstance.body
        if let audioFileUrl = body["audioFileUrl"]{
            audioUrlString = audioFileUrl.replacingOccurrences(
                of: "^(http).+(album/)",
                with: "https://du3rcmbgk4e8q.cloudfront.net/album/",
                options: .regularExpression
            )
            audioUrlString =  audioUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        
        if audioUrlString != "" {
            print("download button\( audioUrlString)")
            if let button = sender as? UIButtonEnhanced {
                // FIXME: should handle all the status and actions to the download helper
                download.takeActions(audioUrlString, currentStatus: button.status)
                print("download button\( button.status)")
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.width
        //        let height = UIScreen.main.bounds.height
        let buttonWidth:CGFloat = 19
        let buttonHeight: CGFloat = 19
        let margin:CGFloat = 20
        let space = (width - margin*2 - buttonWidth*4)/3
        let spaceBetweenListAndView: CGFloat = 30
        
        playlist.attributedTitle(for: UIControlState.normal)
        playlist.setImage(UIImage(named:"ListBtn"), for: UIControlState.normal)
        playlist.addTarget(self, action: #selector(self.openPlayList(_:)), for: UIControlEvents.touchUpInside)
        
        
        downloadButton.attributedTitle(for: UIControlState.normal)
        downloadButton.setImage(UIImage(named:"DownLoadBtn"), for: UIControlState.normal)
        downloadButton.addTarget(self, action: #selector(self.download(_:)), for: UIControlEvents.touchUpInside)
        
        
        love.attributedTitle(for: UIControlState.normal)
        love.setImage(UIImage(named:"LoveBtn"), for: UIControlState.normal)
        love.addTarget(self, action: #selector(self.favorite(_:)), for: UIControlEvents.touchUpInside)
        
        
        share.attributedTitle(for: UIControlState.normal)
        share.setImage(UIImage(named:"ShareBtn"), for: UIControlState.normal)
        share.addTarget(self, action: #selector(self.share(_:)), for: UIControlEvents.touchUpInside)
        
        containerView.addSubview(playlist)
        containerView.addSubview(downloadButton)
        containerView.addSubview(love)
        containerView.addSubview(share)
        
        self.playlist.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.back, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        
        self.containerView.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.containerView.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.containerView.addConstraint(NSLayoutConstraint(item: playlist, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonHeight))
        
        
        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.share, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -space))
        self.containerView.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.containerView.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.containerView.addConstraint(NSLayoutConstraint(item: downloadButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonHeight))
        
        self.love.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.playlist, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: space))
        self.containerView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.containerView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.containerView.addConstraint(NSLayoutConstraint(item: love, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonHeight))
        
        
        self.share.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.forward, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -spaceBetweenListAndView))
        self.containerView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonWidth))
        self.containerView.addConstraint(NSLayoutConstraint(item: share, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: buttonHeight))
        

        playStatus.textColor = UIColor(hex: Color.Content.background)
        let themeColor = UIColor(hex: Color.Content.headline)
        audioImage.backgroundColor = themeColor

        initStyle()
        fetchAudioResults = TabBarAudioContent.sharedInstance.fetchResults
        player = TabBarAudioContent.sharedInstance.player
        playerItem = TabBarAudioContent.sharedInstance.playerItem
        parseAudioMessage()
        getPlayingUrl()
        addPlayerItemObservers()
        updateProgressSlider()
        let data = fetchAudioResults![0].items[2]
        if let loadedImage = data.coverImage {
            audioImage.image = loadedImage
            print ("image is already loaded, no need to download again. ")
        } else {
            data.loadImage(type:"cover", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.audioImage.image = cellContentItem.coverImage
            })
        }
        
        audioImage.layer.cornerRadius = 125
        audioImage.layer.borderWidth = 7
        audioImage.layer.borderColor = UIColor(hex: "#138f9b").cgColor
        audioImage.clipsToBounds = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        super.viewWillAppear(animated)
        let screenName = "/\(DeviceInfo.checkDeviceType())/audio/\(audioId)/\(audioTitle)"
        Track.screenView(screenName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if self.isMovingFromParentViewController {
            if let player = player {
                player.pause()
                self.player = nil
            }
        } else {
            print ("Audio is not being popped")
        }
    }
    
    private func initStyle() {
        let progressThumbImage = UIImage(named: "SliderImg")
        let aa = progressThumbImage?.imageWithImage(image: progressThumbImage!, scaledToSize: CGSize(width: 15, height: 15))
        progressSlider.setThumbImage(aa, for: .normal)
        progressSlider.maximumTrackTintColor = UIColor.white
        progressSlider.minimumTrackTintColor = UIColor(hex: "#05d5e9")
    }
    
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func updateProgressSlider(){
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
            if let d = self?.playerItem?.duration {
                let duration = CMTimeGetSeconds(d)
                if duration.isNaN == false {
                    self?.progressSlider.maximumValue = Float(duration)
                    if self?.progressSlider.isHighlighted == false {
                        self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
                    }
                    TabBarAudioContent.sharedInstance.duration = d
                    TabBarAudioContent.sharedInstance.time = time
                    self?.updatePlayTime(current: time, duration: d)
                }
            }
        }
    }
    private func getPlayingUrl(){
        //        get playingIndex
        playingIndex = 0
        urlOrigStrings = []
        var playerItemTemp : AVPlayerItem?
        if let fetchAudioResults = fetchAudioResults {
            for (index, item0) in fetchAudioResults[0].items.enumerated() {
                if let fileUrl = item0.caudio {
                    urlOrigStrings.append(fileUrl)
                    if audioUrlString == fileUrl{
                        playingUrlStr = fileUrl
                        playingIndex = index
                    }
                    if let urlAsset = URL(string: fileUrl){
                        playerItemTemp = AVPlayerItem(url: urlAsset) //可以用于播放的playItem
                        playerItems?.append(playerItemTemp!)
                    }
                    
                }
            }
        }
        print("urlString filtered audioUrlString --\(audioUrlString)")
        //        print("urlString playerItems000---\(String(describing: playerItems))")
        
        print("urlString playingIndex222--\(playingIndex)")
        TabBarAudioContent.sharedInstance.playingIndex = playingIndex
        
    }
    
    @objc func reloadAudioView(){
        removePlayerItemObservers()
        if let item = TabBarAudioContent.sharedInstance.item,let audioUrlStrFromList = item.caudio{
            print("audioUrlStrFromList--\(audioUrlStrFromList)")
            audioUrlString = audioUrlStrFromList
            prepareAudioPlay()
            TabBarAudioContent.sharedInstance.item = item
            self.playStatus.text = item.headline
            TabBarAudioContent.sharedInstance.body["title"] = item.headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioUrlStrFromList
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(item.id)"
            parseAudioMessage()
        }
        
        
    }
    //    获取tabBar中的数据，此函数仅仅是刚出来运行，应该与上一首（调用prepareAudioPlay()）分开使用？我觉得后面可以考虑合并，因为假如下一首了，对播放器的操作isPlaying不会相应更新？（可以更新，通过暂停播放按钮控制）
    //    全部用全局导致每次更新代码都得用全局更新，不然不会变化
    private func getDataFromeTab(){
        item = TabBarAudioContent.sharedInstance.item
        parseAudioMessage()
        //            获取从tabBar中播放的数据
        playStatus.text=TabBarAudioContent.sharedInstance.item?.headline
        player = TabBarAudioContent.sharedInstance.player
        playerItem = TabBarAudioContent.sharedInstance.playerItem
        //        let isPlaying = TabBarAudioContent.sharedInstance.isPlaying
        if player != nil {
            
        }else {
            
        }
        
        var currentTimeFromTab: NSNumber = 0
        if let c = TabBarAudioContent.sharedInstance.playerItem?.currentTime() {
            let currentTime1 = CMTimeGetSeconds(c)
            if currentTime1.isNaN == false {
                currentTimeFromTab = currentTime1 as NSNumber
            }
        }
        
        if let player = player{
            if TabBarAudioContent.sharedInstance.isPlaying{
                playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
                player.play()
                player.replaceCurrentItem(with: playerItem)
            }else{
                playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
                player.pause()
            }
            //            nowPlayingCenter.updateTimeForPlayerItem(player)
            //            updateProgressSlider()
            // MARK: - Update audio play progress
            //            player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
            //                print("addPeriodicTimeObserver action")
            //                if let d = self?.playerItem?.duration {
            //                    let duration = CMTimeGetSeconds(d)
            //                    if duration.isNaN == false {
            //                        self?.progressSlider.maximumValue = Float(duration)
            //                        if self?.progressSlider.isHighlighted == false {
            //                            self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
            //                        }
            //                        TabBarAudioContent.sharedInstance.duration = d
            //                        TabBarAudioContent.sharedInstance.time = time
            //                        self?.updatePlayTime(current: time, duration: d)
            //                    }
            //                }
            //            }
            
            print("getDataFromeTab player----\(player)--playerItem---\(String(describing: playerItem))")
        }
        addPlayerItemObservers()
        
        print("getDataFromeTab--\(currentTimeFromTab)----\(String(describing: player))")
    }
    
    private func parseAudioMessage() {
        let body = TabBarAudioContent.sharedInstance.body
        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
            audioTitle = title
            audioUrlString = audioFileUrl
            audioId = interactiveUrl.replacingOccurrences(
                of: "^.*interactive/([0-9]+).*$",
                with: "$1",
                options: .regularExpression
            )
            ShareHelper.sharedInstance.webPageTitle = title
            print("parsed audioUrlString--\(audioUrlString)")
        }
    }
    
    private func prepareAudioPlay() {
        audioUrlString = audioUrlString.replacingOccurrences(
            of: "^(http).+(album/)",
            with: "https://du3rcmbgk4e8q.cloudfront.net/album/",
            options: .regularExpression
        )
        audioUrlString =  audioUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = URL(string: audioUrlString) {
            // MARK: - Check if the file already exists locally
            var audioUrl = url
            //print ("checking the file in documents: \(audioUrlString)")
            let cleanAudioUrl = audioUrlString.replacingOccurrences(of: "%20", with: " ")
            if let localAudioFile = download.checkDownloadedFileInDirectory(cleanAudioUrl) {
                print ("The Audio is already downloaded")
                audioUrl = URL(fileURLWithPath: localAudioFile)
                downloadButton.setImage(UIImage(named:"DeleteButton"), for: .normal)
            }
            // MARK: - Draw a circle around the downloadButton
            downloadButton.drawCircle()
            
            let asset = AVURLAsset(url: audioUrl)
            
            playerItem = AVPlayerItem(asset: asset)
            
            if player != nil {
                
            }else {
                player = AVPlayer()
                
            }
            
            TabBarAudioContent.sharedInstance.playerItem = playerItem
            TabBarAudioContent.sharedInstance.audioUrl = audioUrl
            TabBarAudioContent.sharedInstance.audioHeadLine = item?.headline
            
            if let player = player {
                player.play()
            }
            playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            // MARK: - If user is using wifi, buffer the audio immediately
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            // MARK: - Update audio play progress
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
                if let d = TabBarAudioContent.sharedInstance.playerItem?.duration {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        self?.progressSlider.maximumValue = Float(duration)
                        if self?.progressSlider.isHighlighted == false {
                            self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        }
                        self?.updatePlayTime(current: time, duration: d)
                        TabBarAudioContent.sharedInstance.duration = d
                        TabBarAudioContent.sharedInstance.time = time
                    }
                }
            }
            
            addDownloadObserve()
            addPlayerItemObservers()
            NowPlayingCenter().updatePlayingCenter()
            enableBackGroundMode()
            NotificationCenter.default.removeObserver(
                self,
                name: Notification.Name(rawValue: "reloadView"),
                object: nil
            )
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadView"), object: self)
            //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMiniPlay"), object: self)
        }
    }
    func updateSingleTonData(){
        if let fetchAudioResults = fetchAudioResults, let audioFileUrl = fetchAudioResults[0].items[playingIndex].caudio {
            TabBarAudioContent.sharedInstance.item = fetchAudioResults[0].items[playingIndex]
            self.tabView.playStatus.text = fetchAudioResults[0].items[playingIndex].headline
            self.audioImage.image = fetchAudioResults[0].items[playingIndex].coverImage
            TabBarAudioContent.sharedInstance.body["title"] = fetchAudioResults[0].items[playingIndex].headline
            TabBarAudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
            TabBarAudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(fetchAudioResults[0].items[playingIndex].id)"
            TabBarAudioContent.sharedInstance.playingIndex = playingIndex
            parseAudioMessage()
        }
    }
    
    @objc public func updatePlayButtonUI() {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                self.playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            } else {
                self.playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
            }
        }
    }
    
    
    deinit {
        removePlayerItemObservers()
        removeDownloadObserve()
        
        // MARK: - Remove Observe Audio Route Change and Update UI accordingly
        NotificationCenter.default.removeObserver(
            self,
            // MARK: - It has to be NSNotification, not Notification
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil
        )
        NotificationCenter.default.removeObserver(self)
        print ("deinit successfully and observer removed")
    }
    
    
    
    func removeAllAudios() {
        Download.removeFiles(["mp3"])
        //        downloadButton.status = .remote
    }
    
    private func updateAVPlayerWithLocalUrl() {
        if let localAudioFile = download.checkDownloadedFileInDirectory(audioUrlString) {
            let currentSliderValue = self.progressSlider.value
            let audioUrl = URL(fileURLWithPath: localAudioFile)
            let asset = AVURLAsset(url: audioUrl)
            removePlayerItemObservers()
            playerItem = AVPlayerItem(asset: asset)
            player?.replaceCurrentItem(with: playerItem)
            addPlayerItemObservers()
            let currentTime = CMTimeMake(Int64(currentSliderValue), 1)
            playerItem?.seek(to: currentTime)
            nowPlayingCenter.updateTimeForPlayerItem(player)
            print ("now use local file to play at \(currentTime)")
        }
    }
    
    private func removePlayerItemObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
    }
    
    private func addPlayerItemObservers() {
        // MARK: - Observe Play to the End
        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // MARK: - Update buffer status
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }
    
    func removeDownloadObserve(){
        // MARK: - Remove Observe download status change
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: download.downloadStatusNotificationName),
            object: nil
        )
        // MARK: - Remove Observe download progress change
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: download.downloadProgressNotificationName),
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: "reloadView"),
            object: nil
        )
    }
    // MARK: - Observe download status change
    func addDownloadObserve(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleDownloadStatusChange(_:)),
            name: Notification.Name(rawValue: download.downloadStatusNotificationName),
            object: nil
        )
        
        // MARK: - Observe download progress change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleDownloadProgressChange(_:)),
            name: Notification.Name(rawValue: download.downloadProgressNotificationName),
            object: nil
        )
    }
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        playDuration.text = "-\((duration-time).durationText)"
        playTime.text = time.durationText
    }
    
    //    This function is used many times and seems to be reused
    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] event in
            print("resume speech")
            self?.player?.play()
            self?.playAndPauseButton.setImage(UIImage(named:"PauseBtn"), for: UIControlState.normal)
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] event in
            print ("pause speech")
            self?.player?.pause()
            self?.playAndPauseButton.setImage(UIImage(named:"HomePlayBtn"), for: UIControlState.normal)
            
            return .success
        }
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        
        let skipForwardIntervalCommand =  MPRemoteCommandCenter.shared().skipForwardCommand
        skipForwardIntervalCommand.preferredIntervals = [NSNumber(value: 15)]
        
        skipForwardIntervalCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            print("前进15s")
            if let currrentPlayingTime = TabBarAudioContent.sharedInstance.time{
                let currentSliderValue = CMTimeGetSeconds(currrentPlayingTime)
                let currentTime = CMTimeMake(Int64(currentSliderValue + 15), 1)
                TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
                self.progressSlider.value = Float(currentSliderValue + 15)
                NowPlayingCenter().updatePlayingCenter()
            }
            
            return .success
        }
        
        let skipBackwardIntervalCommand =  MPRemoteCommandCenter.shared().skipBackwardCommand
        
        skipBackwardIntervalCommand.preferredIntervals = [NSNumber(value: 15)]
        skipBackwardIntervalCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            print("后退15s")
            if let currrentPlayingTime = TabBarAudioContent.sharedInstance.time{
                let currentSliderValue = CMTimeGetSeconds(currrentPlayingTime)
                let currentTime = CMTimeMake(Int64(currentSliderValue - 15), 1)
                TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
                self.progressSlider.value = Float(currentSliderValue - 15)
                NowPlayingCenter().updatePlayingCenter()
            }
            return .success
        }
        
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        
        
        let changePlaybackPositionCommand = MPRemoteCommandCenter.shared().changePlaybackPositionCommand
        changePlaybackPositionCommand.isEnabled = true
        changePlaybackPositionCommand.addTarget { (MPRemoteCommandEvent:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            let changePlaybackPositionCommandEvent = MPRemoteCommandEvent as! MPChangePlaybackPositionCommandEvent
            let positionTime = changePlaybackPositionCommandEvent.positionTime
            if let totlaTime = TabBarAudioContent.sharedInstance.player?.currentItem?.duration{
                
                let currentTime = CMTimeMake(Int64(totlaTime.value) * Int64(positionTime)/Int64(CMTimeGetSeconds(totlaTime)), 1)
                //                TabBarAudioContent.sharedInstance.playerItem?.seek(to: currentTime)
                //                NowPlayingCenter().updatePlayingCenter()
                print("changePlaybackPosition currentTime\(currentTime)")
                print("changePlaybackPosition currentTime positionTime\(positionTime)")
                //                滑动会触发playerDidFinishPlaying()函数？
            }
            return .success;
        }
        
        
    }
    
    
    
    @objc func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: .normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
        //        orderPlay()
        let mode = TabBarAudioContent.sharedInstance.mode
        print("mode11 \(String(describing: mode))")
        if let mode = TabBarAudioContent.sharedInstance.mode {
            switch mode {
            case 0:
                orderPlay()
            case 1:
                onePlay()
            case 2:
                randomPlay()
            default:
                orderPlay()
            }
        }
        else{
            orderPlay()
        }
    }
    
    func orderPlay(){
        count = urlOrigStrings.count
        removePlayerItemObservers()
        playingIndex += 1
        if playingIndex >= count{
            playingIndex = 0
            
        }
        print("urlString playingIndex---\(playingIndex)")
        updateSingleTonData()
        prepareAudioPlay()
        let currentItem = TabBarAudioContent.sharedInstance.player?.currentItem
        let nextItem = playerItems?[playingIndex]
        queuePlayer?.advanceToNextItem()
        currentItem?.seek(to: kCMTimeZero)
        queuePlayer?.insert(nextItem!, after: currentItem)
        self.player?.play()
    }
    func randomPlay(){
        let randomIndex = Int(arc4random_uniform(UInt32(urlOrigStrings.count)))
        removePlayerItemObservers()
        playingIndex = randomIndex
        print("urlString playingIndex---\(playingIndex)")
        updateSingleTonData()
        prepareAudioPlay()
        let currentItem = TabBarAudioContent.sharedInstance.player?.currentItem
        let nextItem = playerItems?[playingIndex]
        queuePlayer?.advanceToNextItem()
        currentItem?.seek(to: kCMTimeZero)
        queuePlayer?.insert(nextItem!, after: currentItem)
        self.player?.play()
    }
    func onePlay(){
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.playAndPauseButton.setImage(UIImage(named:"PlayBtn"), for: UIControlState.normal)
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    
    
    //    此函数会执行，下一首应该更新audioTitle的值
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let k = keyPath {
                switch k {
                case "playbackBufferEmpty":
                    // Show loader
                    print ("is loading...")
                    playStatus.text = "加载中..."
                    
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    print ("should be playing. Duration is \(String(describing: playerItem?.duration))")
                    playStatus.text = audioTitle
                case "playbackBufferFull":
                    // Hide loader
                    print ("load successfully")
                    playStatus.text = audioTitle
                default:
                    playStatus.text = audioTitle
                    break
                }
            }
            if let time = playerItem?.currentTime(), let duration = playerItem?.duration {
                updatePlayTime(current: time, duration: duration)
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    
    
    @objc public func handleDownloadStatusChange(_ notification: Notification) {
        DispatchQueue.main.async() {
            if let object = notification.object as? (id: String, status: DownloadStatus) {
                let status = object.status
                let id = object.id
                // MARK: The Player Need to verify that the current file matches status change
                let cleanAudioUrl = self.audioUrlString.replacingOccurrences(of: "%20", with: "")
                print ("Handle download Status Change: \(cleanAudioUrl) =? \(id)")
                if cleanAudioUrl.contains(id) == true {
                    switch status {
                    case .downloading, .remote:
                        self.downloadButton.progress = 0
                    case .paused, .resumed:
                        break
                    case .success:
                        // MARK: if a file is downloaded, prepare the audio asset again
                        self.updateAVPlayerWithLocalUrl()
                        self.downloadButton.progress = 0
                    }
                    print ("notification received for \(status)")
                    self.downloadButton.status = status
                    
                }
            }
        }
    }
    
    @objc public func handleDownloadProgressChange(_ notification: Notification) {
        DispatchQueue.main.async() {
            if let object = notification.object as? (id: String, percentage: Float, downloaded: String, total: String) {
                let id = object.id
                let percentage = object.percentage
                // MARK: The Player Need to verify that the current file matches status change
                let cleanAudioUrl = self.audioUrlString.replacingOccurrences(of: "%20", with: "")
                if cleanAudioUrl.contains(id) == true {
                    self.downloadButton.progress = percentage/100
                    self.downloadButton.status = .resumed
                }
            }
        }
    }
    
    //init 不能少，写在viewDidLoad中不生效
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            return CustomPresentationController(presentedViewController: presented, presenting: presenting)
        }
        
        return nil
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            print("present animation")
            return CustomPresentationAnimation(isPresenting: true)
        }
        else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            return CustomPresentationAnimation(isPresenting: false)
        }
        else {
            return nil
        }
    }
    
}

