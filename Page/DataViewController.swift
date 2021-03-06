//
//  DataViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
import WebKit
import StoreKit
import MediaPlayer

class DataViewController: UICollectionViewController, UINavigationControllerDelegate, UICollectionViewDataSourcePrefetching {
    var isLandscape = false
    var refreshControl = UIRefreshControl()
    let flowLayout = PageCollectionViewLayoutV()
    let flowLayoutH = PageCollectionViewLayoutH()
    let columnNum: CGFloat = 1 //use number of columns instead of a static maximum cell width
    var cellWidth: CGFloat = 0
    var themeColor: String? = nil
    var coverTheme: String?
    var layoutStrategy: String?
    var isVisible = false
    let maxWidth: CGFloat = 768
    // MARK: If it's the first time web view loading, no need to record PV and refresh ad iframes
    // var isWebViewFirstLoading = true
    
    fileprivate let itemsPerRowForRegular: CGFloat = 3
    fileprivate let itemsPerRowForCompact: CGFloat = 1
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    // MARK: Search
    fileprivate lazy var searchBar: UISearchBar? = nil
    fileprivate var searchKeywords: String? = nil {
        didSet {
            search()
        }
    }
    fileprivate var fetches = ContentFetchResults(
        apiUrl: "",
        fetchResults: [ContentSection]()
    )
    fileprivate let contentAPI = ContentFetch()
    var dataObject = [String: String]()
    var pageTitle: String = ""
    
    public lazy var webView: WKWebView? = nil
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let dataObjectType = dataObject["type"] ?? ""
        // MARK: - Request Data from Server
        if dataObject["api"] != nil || ["follow", "read", "clip", "iap", "setting", "options"].contains(dataObjectType){
            //            let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
            //            let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
            
            // MARK: - Get Layout Strategy
            let layoutKey = layoutType()
            if let layoutValue = dataObject[layoutKey] {
                layoutStrategy = layoutValue
            } else {
                layoutStrategy = nil
            }
            
            collectionView?.dataSource = self
            collectionView?.delegate = self
            if #available(iOS 10.0, *) {
                collectionView?.isPrefetchingEnabled = true
                collectionView?.prefetchDataSource = self
            }
            
            if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.minimumInteritemSpacing = 0
                flowLayout.minimumLineSpacing = 0
                //FIXME: Why does this break scrolling?
                //flowLayout.sectionHeadersPinToVisibleBounds = true
                //flowLayout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
                
                let collectionViewInsets = UIEdgeInsetsMake(14, 0, 0, 0)
                collectionView?.contentInset = collectionViewInsets;
                collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(collectionViewInsets.top, 0, collectionViewInsets.bottom, 0);
                
                
                //                let paddingSpace = sectionInsets.left * (getSizeInfo().itemsPerRow + 1)
                //                let availableWidth = view.frame.width - paddingSpace
                //                //print("availableWidth : \(availableWidth)")
                //
                //                if (horizontalClass != .regular || verticalCass != .regular) && layoutStrategy != "Icons" {
                //                    if #available(iOS 10.0, *) {
                //                        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
                //                    } else {
                //                        flowLayout.estimatedItemSize = CGSize(width: availableWidth, height: 250)
                //                    }
                //                    cellWidth = availableWidth
                //                }
                
                //let paddingSpace = sectionInsets.left * (getSizeInfo().itemsPerRow + 1)
                let availableWidth = min(view.frame.width, maxWidth)
                //print("availableWidth : \(availableWidth)")
                if #available(iOS 10.0, *) {
                    flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
                } else {
                    flowLayout.estimatedItemSize = CGSize(width: availableWidth, height: 250)
                }
                cellWidth = availableWidth
                
            }
            
            
            collectionView?.register(UINib.init(nibName: "ChannelCell", bundle: nil), forCellWithReuseIdentifier: "ChannelCell")
            collectionView?.register(UINib.init(nibName: "CoverCell", bundle: nil), forCellWithReuseIdentifier: "CoverCell")
            collectionView?.register(UINib.init(nibName: "ThemeCoverCell", bundle: nil), forCellWithReuseIdentifier: "ThemeCoverCell")
            collectionView?.register(UINib.init(nibName: "VideoCoverCell", bundle: nil), forCellWithReuseIdentifier: "VideoCoverCell")
            collectionView?.register(UINib.init(nibName: "ClassicCoverCell", bundle: nil), forCellWithReuseIdentifier: "ClassicCoverCell")
            collectionView?.register(UINib.init(nibName: "SmoothCoverCell", bundle: nil), forCellWithReuseIdentifier: "SmoothCoverCell")
            collectionView?.register(UINib.init(nibName: "OutOfBoxCoverCell", bundle: nil), forCellWithReuseIdentifier: "OutOfBoxCoverCell")
            collectionView?.register(UINib.init(nibName: "IconCell", bundle: nil), forCellWithReuseIdentifier: "IconCell")
            collectionView?.register(UINib.init(nibName: "BigImageCell", bundle: nil), forCellWithReuseIdentifier: "BigImageCell")
            collectionView?.register(UINib.init(nibName: "LineCell", bundle: nil), forCellWithReuseIdentifier: "LineCell")
            collectionView?.register(UINib.init(nibName: "PaidPostCell", bundle: nil), forCellWithReuseIdentifier: "PaidPostCell")
            collectionView?.register(UINib.init(nibName: "FollowCell", bundle: nil), forCellWithReuseIdentifier: "FollowCell")
            collectionView?.register(UINib.init(nibName: "SettingCell", bundle: nil), forCellWithReuseIdentifier: "SettingCell")
            collectionView?.register(UINib.init(nibName: "OptionCell", bundle: nil), forCellWithReuseIdentifier: "OptionCell")
            collectionView?.register(UINib.init(nibName: "BookCell", bundle: nil), forCellWithReuseIdentifier: "BookCell")
            collectionView?.register(UINib.init(nibName: "HeadlineCell", bundle: nil), forCellWithReuseIdentifier: "HeadlineCell")
            collectionView?.register(UINib.init(nibName: "Ad", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Ad")
            collectionView?.register(UINib.init(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
            collectionView?.register(UINib.init(nibName: "SimpleHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SimpleHeaderView")
            
            // MARK: Cell for Regular Size
//            collectionView?.register(UINib.init(nibName: "ChannelCellRegular", bundle: nil), forCellWithReuseIdentifier: "ChannelCellRegular")
//            collectionView?.register(UINib.init(nibName: "CoverCellRegular", bundle: nil), forCellWithReuseIdentifier: "CoverCellRegular")
//            collectionView?.register(UINib.init(nibName: "AdCellRegular", bundle: nil), forCellWithReuseIdentifier: "AdCellRegular")
//            collectionView?.register(UINib.init(nibName: "HotArticleCellRegular", bundle: nil), forCellWithReuseIdentifier: "HotArticleCellRegular")
            
            // MARK: - Update Styles
            view.backgroundColor = UIColor(hex: Color.Content.background)
            collectionView?.backgroundColor = UIColor(hex: Color.Content.background)
            // MARK: - show refresh controll only when there is api
            if dataObject["api"] != nil || dataObjectType == "follow" {
                if #available(iOS 10.0, *) {
                    refreshControl.addTarget(self, action: #selector(refreshControlDidFire(sender:)), for: .valueChanged)
                    collectionView?.refreshControl = refreshControl
                }
            }
            
            // MARK: - Get Content Data for the Page
            requestNewContent()
        } else if let urlStringOriginal = dataObject["url"] {
            let urlString = APIs.convert(urlStringOriginal)
            self.view.backgroundColor = UIColor(hex: Color.Content.background)
            //            self.edgesForExtendedLayout = []
            //            self.extendedLayoutIncludesOpaqueBars = false
            let config = WKWebViewConfiguration()
            
            // MARK: Tell the web view what kind of connection the user is currently on
            let contentController = WKUserContentController();
            let jsCode = "window.gConnectionType = '\(Connection.current())';window.gNoImageWithData='\(Setting.getSwitchStatus("no-image-with-data"))';"
            let userScript = WKUserScript(
                source: jsCode,
                injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                forMainFrameOnly: true
            )
            contentController.addUserScript(userScript)
            // MARK: This is Very Important! Use LeadAvoider so that ARC kicks in correctly.
            contentController.add(LeakAvoider(delegate:self), name: "alert")
            contentController.add(LeakAvoider(delegate:self), name: "items")
            contentController.add(LeakAvoider(delegate:self), name: "selectItem")
            config.userContentController = contentController
            config.allowsInlineMediaPlayback = true
            
            // MARK: Add the webview as a subview of containerView
            webView = WKWebView(frame: self.view.bounds, configuration: config)
            view = webView
            view.clipsToBounds = true
            webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // MARK: Use this so that I don't have to calculate the frame of the webView, which can be tricky.
            //            webView = WKWebView(frame: self.view.bounds, configuration: config)
            //            self.view = self.webView
            let webViewBG = UIColor(hex: Color.Content.background)
            webView?.isOpaque = true
            webView?.backgroundColor = webViewBG
            webView?.scrollView.backgroundColor = webViewBG
            
            // MARK: This makes the web view scroll like native
            webView?.scrollView.delegate = self
            webView?.navigationDelegate = self
            webView?.clipsToBounds = true
            webView?.scrollView.bounces = true
            refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControlEvents.valueChanged)
            webView?.scrollView.addSubview(refreshControl)
            
            if dataObjectType == "Search" {
                searchBar = UISearchBar()
                searchBar?.sizeToFit()
                searchBar?.showsScopeBar = true
                navigationItem.titleView = searchBar
                searchBar?.becomeFirstResponder()
                searchBar?.delegate = self
                let urlStringSearch = APIs.convert(APIs.searchUrl)
                //let urlStringSearch = APIs.searchUrl
                if let url = URL(string: urlStringSearch) {
                    let request = URLRequest(url: url)
                    let fileName = GB2Big5.convertHTMLFileName("search")
                    if let adHTMLPath = Bundle.main.path(forResource: fileName, ofType: "html"){
                        do {
                            let searchHTML = getSearchHistoryHTML()
                            let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                                .replacingOccurrences(of: "{search-html}", with: searchHTML)
                            let storyHTML = storyTemplate as String
                            self.webView?.loadHTMLString(storyHTML, baseURL:url)
                        } catch {
                            //self.webView?.load(request)
                        }
                    } else {
                        self.webView?.load(request)
                    }
                }
            } else if dataObjectType == "account" {
                if let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    let fileName = GB2Big5.convertHTMLFileName("account")
                    if let adHTMLPath = Bundle.main.path(forResource: fileName, ofType: "html"){
                        do {
                            let storyTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                            let storyHTML = GB2Big5.convert(storyTemplate as String)
                            self.webView?.loadHTMLString(storyHTML, baseURL:url)
                        } catch {
                            //self.webView?.load(request)
                        }
                    } else {
                        self.webView?.load(request)
                    }
                }
            }  else if let listAPI = dataObject["listapi"] {
                let fileExtension = "html"
                requestNewContentForWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
                renderWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
            } else if let url = URL(string: urlString) {
                print ("Open url: \(urlString)")
                let request = URLRequest(url: url)
                webView?.load(request)
            }
        }
        
        
        // MARK: Only update the navigation title when it is pushed
        navigationItem.title = pageTitle.removingPercentEncoding
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(paidPostUpdate(_:)),
            name: Notification.Name(rawValue: Event.paidPostUpdate(for: pageTitle)),
            object: nil)
        
        //openHTMLInBundle("register", title: "注册", isFullScreen: true, hidesBottomBar: true)
    }
    
    @objc public func refreshWebView(_ sender: Any) {
        if let listAPI = dataObject["listapi"],
            let urlStringOriginal = dataObject["url"] {
            let urlString = APIs.convert(urlStringOriginal)
            let fileExtension = "html"
            requestNewContentForWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
        }
    }
    
    private func requestNewContentForWebview(_ listAPI: String, urlString: String, fileExtension: String) {
        view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        let listAPIString = APIs.convert(Download.addVersion(listAPI))
        if let url = URL(string: listAPIString) {
            Download.getDataFromUrl(url) {[weak self] (data, response, error)  in
                if let data = data, error == nil {
                    Download.saveFile(data, filename: listAPI, to: .cachesDirectory, as: fileExtension)
                }
                DispatchQueue.main.async {
                    self?.activityIndicator.removeFromSuperview()
                }
                self?.renderWebview (listAPI, urlString: urlString, fileExtension: fileExtension)
            }
        }
    }
    
    private func renderWebview (_ listAPI: String, urlString: String, fileExtension: String) {
        DispatchQueue.global().async {
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                let fileName = GB2Big5.convertHTMLFileName("list")
                if let adHTMLPath = Bundle.main.path(forResource: fileName, ofType: "html") {
                    do {
                        let defaultString = "Loading..."
                        let listContentString: String
                        if let listContentData = Download.readFile(listAPI, for: .cachesDirectory, as: fileExtension) {
                            listContentString = String(data: listContentData, encoding: String.Encoding.utf8) ?? defaultString
                        } else {
                            listContentString = defaultString
                        }
                        let listTemplate = try NSString(contentsOfFile:adHTMLPath, encoding:String.Encoding.utf8.rawValue)
                        let listHTML = (listTemplate as String)
                            .replacingOccurrences(of: "{list-content}", with: listContentString)
                        //print (listHTML)
                        DispatchQueue.main.async {
                            self.webView?.loadHTMLString(listHTML, baseURL:url)
                            self.refreshControl.endRefreshing()
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.webView?.load(request)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.webView?.load(request)
                    }
                }
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("view will appear called")
        isVisible = true
        if let screeName = dataObject["screenName"] {
            Track.screenView("/\(DeviceInfo.checkDeviceType())/\(screeName)")
        }
        //updateWebviewTraffic()
        filterDataWithAudioUrl()
        //TabBarAudioContent.sharedInstance.fetchResults = fetches.fetchResults
        // MARK: In setting page, you might need to update UI to reflected change in preference
        if let type = dataObject["type"],
            type == "setting" {
            loadSettings()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print ("view did disappear called. ")
        isVisible = false
        // MARK: if web view is not used, no need to do anything
        if webView == nil {
            return
        }
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { [weak self] timer in
                if self?.isVisible == false {
                    if let listAPI = self?.dataObject["listapi"],
                        let urlStringOriginal = self?.dataObject["url"] {
                        let fileExtension = "html"
                        let urlString = APIs.convert(urlStringOriginal)
                        self?.webViewScrollPoint = self?.webView?.scrollView.contentOffset
                        self?.renderWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
                        print ("the view is not visible, render web view called")
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
                            if let webViewScrollPoint = self?.webViewScrollPoint {
                                self?.webView?.scrollView.setContentOffset(webViewScrollPoint, animated: false)
                            }
                        }
                    }
                } else {
                    print ("the view is visible, nothing called")
                }
            }
        }
    }
    
    
    //    private func updateWebviewTraffic() {
    //        if isWebViewFirstLoading == true {
    //            isWebViewFirstLoading = false
    //            return
    //        }
    //
    //
    //        //        if let listAPI = dataObject["listapi"],
    //        //        let urlStringOriginal = dataObject["url"] {
    //        //            let fileExtension = "html"
    //        //            let urlString = APIs.convert(urlStringOriginal)
    //        //            webViewScrollPoint = webView?.scrollView.contentOffset
    //        //            renderWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
    //        //        }
    //
    //        //let jsCode = "refreshAllAds();ga('send', 'pageview');"
    //        let jsCode = "ga('send', 'pageview');"
    //        webView?.evaluateJavaScript(jsCode) { (result, error) in
    //            if error == nil {
    //                print ("pv recorded and ad refreshed")
    //            } else {
    //                print (error ?? "pv record error")
    //                // MARK: If the javascript cannot be executed effectively, might need to refresh the web view.
    //                self.refreshWebView(self.refreshControl)
    //            }
    //        }
    //
    //    }
    
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //
    //        print ("view did appear called")
    //    }
    
    
    //    override func viewWillLayoutSubviews() {
    //        //         print("33333")//第一次启动出现3次，转屏出现一次
    //        super.viewWillLayoutSubviews()
    //        print ("view will layout subviews called")
    //        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
    //        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
    //
    //        if horizontalClass == .regular && verticalCass == .regular {
    //            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
    //                isLandscape = true
    //                collectionView?.collectionViewLayout=flowLayoutH
    //                flowLayoutH.minimumInteritemSpacing = 0
    //                flowLayoutH.minimumLineSpacing = 0
    //            }
    //
    //            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
    //                isLandscape = false
    //                collectionView?.collectionViewLayout=flowLayout
    //                flowLayout.minimumInteritemSpacing = 0
    //                flowLayout.minimumLineSpacing = 0
    //            }
    //        }
    //    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("view will transition called. ")//第一次启动不运行，转屏出现一次
        collectionView?.reloadData()
    }
    
    deinit {
        //MARK: Remove Paid Post Observer
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: Event.paidPostUpdate(for: pageTitle)),
            object: nil
        )
        print ("Data View Controller of \(pageTitle) removed successfully")
    }
    
    private func getAPI(_ urlString: String) {
//        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
//        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
        view.addSubview(activityIndicator)
        // activityIndicator.frame = view.bounds
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        // MARK: Check the local file
        if let data = Download.readFile(urlString, for: .cachesDirectory, as: "json") {
            //print ("found \(urlString) in caches directory. ")
            if let resultsDictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            {
                let contentSections = contentAPI.formatJSON(resultsDictionary)
                let results = ContentFetchResults(apiUrl: urlString, fetchResults: contentSections)
                print ("update UI from local")
                updateUI(with: results)
                //print ("update UI from local file with \(urlString)")
            }
        }
        
        // MARK: Get the updated API from Internet
        let acturalUrlString = APIs.convert(urlString)
        contentAPI.fetchContentForUrl(acturalUrlString, fetchUpdate: .Always) {
            [weak self] results, error in
            DispatchQueue.main.async {
                self?.activityIndicator.removeFromSuperview()
                self?.refreshControl.endRefreshing()
                if let error = error {
                    print("Error searching : \(error)")
                    return
                }
                if let results = results {
                    // MARK: When updating UI from the internet, the viewable ad will be updated too, which makes sense
                    print ("update UI from the internet with \(acturalUrlString)")
                    self?.updateUI(with: results)
                    // FIXME: It is important to reload Data here, not inside the updateUI. But Why? What's the difference?
                    self?.collectionView?.reloadData()
                    self?.prefetch()
                }
            }
        }
    }
    
    
    private func prefetch() {
        let statusType = IJReachability().connectedToNetworkOfType()
        if statusType == .wiFi {
            print ("User is on Wifi, Continue to prefetch content")
            let sections = fetches.fetchResults
            for section in sections {
                let items = section.items
                for item in items {
                    if item.type == "story" {
                        let apiUrl = APIs.get(item.id, type: item.type)
                        if Download.readFile(apiUrl, for: .cachesDirectory, as: "json") == nil {
                            print ("File needs to be downloaded. id: \(item.id), type: \(item.type), api url is \(apiUrl)")
                        } else {
                            //print ("File already exists. id: \(item.id), type: \(item.type), api url is \(apiUrl)")
                        }
                        Download.downloadUrl(apiUrl, to: .cachesDirectory, as: "json")
                        
                        if Download.readFile(item.image, for: .cachesDirectory, as: "cover") == nil {
                            item.loadImage(
                                type:"cover",
                                width: ImageSize.cover.width,
                                height: ImageSize.cover.height,
                                completion:{ (cellContentItem, error) in
                                    //print ("\(item.image) is prefetched! ")
                            }
                            )
                        }
                        if Download.readFile(item.image, for: .cachesDirectory, as: "thumbnail") == nil {
                            item.loadImage(
                                type:"thumbnail",
                                width: ImageSize.thumbnail.width,
                                height: ImageSize.thumbnail.height,
                                completion:{ (cellContentItem, error) in
                                    //print ("\(item.image) is prefetched! ")
                            }
                            )
                        }
                    }
                }
            }
        }
    }
    
    
    fileprivate func updateUI(with results: ContentFetchResults) {
        // MARK: - Insert Ads into the fetch results
        let layoutWay:String
//        if horizontalClass == .regular && verticalCass == .regular {
//            layoutWay = dataObject["regularLayout"] ?? "ipadhome"
//        } else {
//            layoutWay = dataObject["compactLayout"] ?? "home"
//        }
        layoutWay = dataObject["compactLayout"] ?? "home"
        // MARK: Insert Content
        let fetchResultsWithContent: [ContentSection]
        if let insertContentLayoutWay = dataObject["Insert Content"] {
            fetchResultsWithContent = SupplementContent.insertContent(insertContentLayoutWay, to: results.fetchResults)
        } else {
            fetchResultsWithContent = results.fetchResults
        }
        
        // MARK: Insert Ads
        let fetchResultsWithAds = AdLayout.insertAds(layoutWay, to: fetchResultsWithContent)
        
        let resultsWithAds = ContentFetchResults(
            apiUrl: results.apiUrl,
            fetchResults: fetchResultsWithAds
        )
        if resultsWithAds.fetchResults.count > 0 {
            self.fetches = resultsWithAds
            self.collectionView?.reloadData()
        }
        
        activityIndicator.removeFromSuperview()
        refreshControl.endRefreshing()
        
    }
    
    
    private func requestNewContent() {
//        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
//        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
        if let api = dataObject["api"] {
            getAPI(api)
        } else if let type = dataObject["type"] {
            if type == "clip" || type == "read" {
                let contentSections = ContentSection(
                    title: "",
                    items: Download.get(type),
                    type: "List",
                    adid: ""
                )
                let results = ContentFetchResults(apiUrl: "", fetchResults: [contentSections])
                updateUI(with: results)
            } else if type == "iap" {
                loadProducts()
            } else if type == "setting" {
                loadSettings()
            } else if type == "options" {
                loadOptions()
            } else if type == "follow" {
                let urlString = APIs.get("follow", type: type)
                getAPI(urlString)
            } else {
                let urlString = APIs.get("", type: type)
                getAPI(urlString)
            }
        } else {
            //TODO: Show a warning if there's no api to get
            print("results : error")
        }
    }
    
    
    @objc func paidPostUpdate(_ notification: Notification) {
        if let itemCell = notification.object as? ContentItem {
            let section = itemCell.section
            let row = itemCell.row
            if fetches.fetchResults.count > section {
                if fetches.fetchResults[section].items.count > row {
                    if itemCell.adModel?.headline != nil{
                        print ("Paid Post: The adModel has headline. Update data source and reload. ")
                        fetches.fetchResults[section].items[row].adModel = itemCell.adModel
                        collectionView?.reloadData()
                    } else {
                        print ("Paid Post: The adModel has no headline")
                    }
                }
            }
        }
    }
    
    
    @objc func refreshControlDidFire(sender:AnyObject) {
        print ("pull to refresh fired")
        // TODO: Handle Pull to Refresh
        requestNewContent()
    }
    
    private var webViewScrollPoint: CGPoint?
    
    //    private func updateWebviewTraffic() {
    //        if isWebViewFirstLoading == true {
    //            isWebViewFirstLoading = false
    //            return
    //        }
    //
    //
    ////        if let listAPI = dataObject["listapi"],
    ////        let urlStringOriginal = dataObject["url"] {
    ////            let fileExtension = "html"
    ////            let urlString = APIs.convert(urlStringOriginal)
    ////            webViewScrollPoint = webView?.scrollView.contentOffset
    ////            renderWebview(listAPI, urlString: urlString, fileExtension: fileExtension)
    ////        }
    //
    //        //let jsCode = "refreshAllAds();ga('send', 'pageview');"
    //        let jsCode = "ga('send', 'pageview');"
    //        webView?.evaluateJavaScript(jsCode) { (result, error) in
    //            if error == nil {
    //                print ("pv recorded and ad refreshed")
    //            } else {
    //                print (error ?? "pv record error")
    //                // MARK: If the javascript cannot be executed effectively, might need to refresh the web view.
    //                self.refreshWebView(self.refreshControl)
    //            }
    //        }
    //
    //    }
    
    // MARK: if you are back from a pushed view controller, scroll to the original position
    //    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    //        //print ("web view did finish navigation called! Should Scroll to the previous position if you are back from a pushed view controller! ")
    //        if let webViewScrollPoint = webViewScrollPoint {
    //            webView.scrollView.setContentOffset(webViewScrollPoint, animated: false)
    //        }
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetches.fetchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // print ("items.count-- \(fetches.fetchResults[section].items.count) ----items.count")
        
        return fetches.fetchResults[section].items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = getReuseIdentifierForCell(indexPath)
        let cellItem = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        print ("cell life: cell for item at section: \(indexPath.section), row: \(indexPath.row)")
        switch reuseIdentifier {
        case "CoverCell":
            if let cell = cellItem as? CoverCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "ThemeCoverCell":
            if let cell = cellItem as? ThemeCoverCell {
                cell.coverTheme = coverTheme
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "VideoCoverCell":
            if let cell = cellItem as? VideoCoverCell {
                cell.coverTheme = coverTheme
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "SmoothCoverCell", "ClassicCoverCell":
            if let cell = cellItem as? SmoothCoverCell {
                cell.coverTheme = coverTheme
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "OutOfBoxCoverCell":
            if let cell = cellItem as? OutOfBoxCoverCell {
                cell.coverTheme = coverTheme
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "IconCell":
            if let cell = cellItem as? IconCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "BigImageCell":
            if let cell = cellItem as? BigImageCell {
                cell.cellWidth = cellWidth
                cell.themeColor = self.themeColor
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.soundButton.addTarget(self, action: #selector(self.openPlay), for: UIControlEvents.touchUpInside)
                cell.updateUI()
                return cell
            }
        case "HeadlineCell":
            if let cell = cellItem as? HeadlineCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "CoverCellRegular":
            if let cell = cellItem as? CoverCellRegular {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "ChannelCellRegular":
            if let cell = cellItem as? ChannelCellRegular {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "AdCellRegular":
            if let cell = cellItem as? AdCellRegular {
                cell.cellWidth = cellWidth
                cell.updateUI()
                //when itemCell change in AdCellRegular, updateUI() will be executed.After adding ad,comment the code
                //                if cell.bounds.height<330{
                //                    cell.adHint.isHidden=true
                //                }else{
                //                    cell.adHint.isHidden=false
                //                }
                return cell
            }
        case "HotArticleCellRegular":
            if let cell = cellItem as? HotArticleCellRegular {
                cell.cellWidth = cellWidth
                cell.updateUI()
                //              cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        case "LineCell":
            if let cell = cellItem as? LineCell {
                cell.pageTitle = pageTitle
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.cellWidth = cellWidth
                cell.updateUI()
                return cell
            }
        case "PaidPostCell":
            if let cell = cellItem as? PaidPostCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.pageTitle = pageTitle
                cell.updateUI()
                return cell
            }
        case "BookCell":
            if let cell = cellItem as? BookCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.pageTitle = pageTitle
                cell.themeColor = themeColor
                cell.updateUI()
                return cell
            }
        case "FollowCell":
            if let cell = cellItem as? FollowCell {
                cell.cellWidth = cellWidth
                cell.themeColor = themeColor
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "SettingCell":
            if let cell = cellItem as? SettingCell {
                cell.cellWidth = cellWidth
                cell.themeColor = themeColor
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "OptionCell":
            if let cell = cellItem as? OptionCell {
                cell.cellWidth = cellWidth
                cell.themeColor = themeColor
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.updateUI()
                return cell
            }
        case "EmptyCell":
            return cellItem
        default:
            if let cell = cellItem as? ChannelCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                cell.pageTitle = pageTitle
                cell.updateUI()
                return cell
            }
        }
        return cellItem
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print ("cell life: prefetch")
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let reuseIdentifier = getReuseIdentifierForSectionHeader(indexPath.section).reuseId ?? ""
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: reuseIdentifier,
                for: indexPath
            )
            
            // MARK: - a common tag gesture for all kinds of headers
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleTapGesture(_:)))
            headerView.isUserInteractionEnabled = true
            headerView.addGestureRecognizer(tapGestureRecognizer)
            switch reuseIdentifier {
            case "Ad":
                let ad = headerView as! Ad
                ad.contentSection = fetches.fetchResults[indexPath.section]
                ad.updateUI()
                //print ("indexPath.section-- \(indexPath.section) ----indexPath.section")
                return ad
            case "HeaderView":
                let headerView = headerView as! HeaderView
                headerView.headerWidth = cellWidth
                headerView.themeColor = themeColor
                headerView.contentSection = fetches.fetchResults[indexPath.section]
                return headerView
            case "SimpleHeaderView":
                let headerView = headerView as! SimpleHeaderView
                headerView.headerWidth = cellWidth
                headerView.themeColor = themeColor
                headerView.contentSection = fetches.fetchResults[indexPath.section]
                return headerView
            default:
                assert(false, "Unknown Identifier")
            }
            //            print ("headerView---- \(headerView) ----headerView")
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
        let reuseIdentifier = getReuseIdentifierForSectionHeader(indexPath.section).reuseId ?? ""
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        return headerView
    }
    
    // Calculate Height for Headers
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if getReuseIdentifierForSectionHeader(section).reuseId != nil {
            return getReuseIdentifierForSectionHeader(section).sectionSize
        }
        return CGSize.zero
        
        //return CGSize(width: 300, height: 250)
    }
    
    // MARK: - Use different cell based on different strategy
    fileprivate func getReuseIdentifierForCell(_ indexPath: IndexPath) -> String {
        // MARK: - Check if the IndexPath is out of range
        if fetches.fetchResults.count < indexPath.section + 1 {
            return "EmptyCell"
        }
        
        let section = fetches.fetchResults[indexPath.section]
        if section.items.count < indexPath.row + 1 {
            print ("\(section.title) out of range, item count is \(section.items.count) and row is \(indexPath.row)")
            return "EmptyCell"
        }
        
        // MARK: Go on if the IndexPath is in range
        let item = section.items[indexPath.row]
        let sectionTitle = section.title
        let isCover = ((indexPath.row == 0 && sectionTitle != "") || item.isCover == true)
        
        let reuseIdentifier: String
        
        if item.type == "ad"{
            if item.adModel == nil || item.adModel?.headline == nil {
                reuseIdentifier = "LineCell"
            } else {
                reuseIdentifier = "PaidPostCell"
            }
        } else if layoutStrategy == "Simple Headline" {
            if isCover {
                reuseIdentifier = "CoverCell"
            } else {
                reuseIdentifier = "HeadlineCell"
            }
        } else if layoutStrategy == "All Cover" {
            reuseIdentifier = "BigImageCell"
        } else if layoutStrategy == "Video" {
            reuseIdentifier = "VideoCoverCell"
        } else if layoutStrategy?.hasPrefix("OutOfBox") == true {
            reuseIdentifier = "OutOfBoxCoverCell"
        } else if layoutStrategy?.hasPrefix("SmoothCover") == true {
            reuseIdentifier = "SmoothCoverCell"
        } else if layoutStrategy == "Icons" {
            reuseIdentifier = "IconCell"
        } else {
//            let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
//            let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
            /*
            if horizontalClass == .regular && verticalCass == .regular {
                
                var isAd = false
                var isHot = false
                let isCover = ((indexPath.row == 0 ) )
                
                //                print("isLandscape----\(isLandscape)")
                
                if !isLandscape{
                    if indexPath.row == 6 {isAd = true}else{isAd = false}
                    if indexPath.row == 10 {isHot = true}else{isHot = false}
                } else if isLandscape {
                    isAd = (indexPath.row == 5)
                    isHot = (indexPath.row == 9)
                }
                
                //                if UIDevice.current.orientation.isPortrait{
                //                    if indexPath.row == 6 {isAd = true}else{isAd = false}
                //                    if indexPath.row == 10 {isHot = true}else{isHot = false}
                //                }else if UIDevice.current.orientation.isLandscape {
                //                    isAd = (indexPath.row == 5)
                //                    isHot = (indexPath.row == 9)
                //                }
                
                
                if isCover && !isAd && !isHot {
                    reuseIdentifier = "CoverCellRegular"
                } else if isAd && !isCover && !isHot {
                    reuseIdentifier = "AdCellRegular"
                } else if !isAd && !isCover && isHot {
                    reuseIdentifier = "HotArticleCellRegular"
                }
                else {
                    reuseIdentifier = "ChannelCellRegular"
                }
            } else {
 */
                if item.type == "ebook" {
                    reuseIdentifier = "BookCell"
                } else if item.type == "follow" {
                    reuseIdentifier = "FollowCell"
                } else if item.type == "setting" {
                    reuseIdentifier = "SettingCell"
                } else if item.type == "option" {
                    reuseIdentifier = "OptionCell"
                } else if isCover {
                    if let coverTheme = coverTheme {
                        reuseIdentifier = Color.Theme.getCellIndentifier(coverTheme)
                    } else {
                        reuseIdentifier = "CoverCell"
                    }
                } else {
                    reuseIdentifier = "ChannelCell"
                }
            
        }
        //        print ("reuseIdentifier---- \(reuseIdentifier) ----reuseIdentifier")
        return reuseIdentifier
    }
    
    private func getReuseIdentifierForSectionHeader(_ sectionIndex: Int) -> (reuseId: String?, sectionSize: CGSize) {
        var reuseIdentifier: String? = nil
        var sectionSize: CGSize = .zero
        if fetches.fetchResults.count > sectionIndex {
            let sectionType = fetches.fetchResults[sectionIndex].type
            switch sectionType {
            case "Banner":
                reuseIdentifier = "Ad"
                sectionSize = CGSize(width: view.frame.width, height: view.frame.width/4)
            case "MPU":
                reuseIdentifier = "Ad"
                sectionSize = CGSize(width: 300, height: 250)
            case "HalfPage":
                reuseIdentifier = "Ad"
                sectionSize = CGSize(width: 300, height: 600)
            case "List", "Group":
                if ![""].contains(fetches.fetchResults[sectionIndex].title) {
                    switch sectionType {
                    case "Group":
                        reuseIdentifier = "SimpleHeaderView"
                        sectionSize = CGSize(width: view.frame.width, height: 44)
                    default:
                        reuseIdentifier = "HeaderView"
                        sectionSize = CGSize(width: view.frame.width, height: 60)
                    }
                    
                } else {
                    reuseIdentifier = nil
                    sectionSize = CGSize.zero
                }
            default:
                reuseIdentifier = nil
                sectionSize = CGSize.zero
            }
        }
        return (reuseId: reuseIdentifier, sectionSize: sectionSize)
    }
    
    
    var playerAPI = PlayerAPI()
    @objc func openPlay(sender: UIButton?){
        playerAPI.openPlay()
    }
    func filterDataWithAudioUrl(){
        var resultsWithAudioUrl = [ContentSection]()
        let results = fetches.fetchResults
        for (_, section) in results.enumerated() {
            
            print("TabBarAudioContent section.items.count \(section.items.count)")
            for i in 0 ..< section.items.count {
                
                if section.items[i].caudio != nil || section.items[i].eaudio != nil{
                    resultsWithAudioUrl.append(section)
                }
            }
        }
        TabBarAudioContent.sharedInstance.fetchResults = resultsWithAudioUrl
    }
    
    
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    
    // MARK: - Handle user tapping on a cell
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return handleItemSelect(indexPath)
    }
    
    // MARK: - Move the handle cell selection to a function so that it can be used in different cases
    fileprivate func handleItemSelect(_ indexPath: IndexPath) -> Bool {
        // MARK: Check the fetchResults to make sure there's no out-of-range error
        if fetches.fetchResults.count <= indexPath.section {
            print ("There is not enough sections in fetchResults")
            return false
        }
        if fetches.fetchResults[indexPath.section].items.count <= indexPath.row {
            print ("Row is \(indexPath.row). There is not enough rows in fetchResults Section")
            return false
        }
        let selectedItem = fetches.fetchResults[indexPath.section].items[indexPath.row]
        // MARK: For a normal cell, allow the action to go through. For special types of cell, such as advertisment in a wkwebview, do not take any action and let wkwebview handle tap.
        // MARK: if it is an audio file, push the audio view controller
        if let audioFileUrl = selectedItem.audioFileUrl {
            if let audioPlayer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayer") as? AudioPlayer {
                AudioContent.sharedInstance.body["title"] = selectedItem.headline
                AudioContent.sharedInstance.body["audioFileUrl"] = audioFileUrl
                AudioContent.sharedInstance.body["interactiveUrl"] = "/index.php/ft/interactive/\(selectedItem.id)"
                audioPlayer.item = selectedItem
                audioPlayer.themeColor = themeColor
                navigationController?.pushViewController(audioPlayer, animated: true)
            }
        } else {
            switch selectedItem.type {
            case "column":
                if let dataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataViewController") as? DataViewController {
                    dataViewController.dataObject = [
                        "title": selectedItem.headline,
                        //"api":"https://d37m993yiqhccr.cloudfront.net/channel/lifestyle.html?type=json",
                        "listapi":"https://danla2f5eudt1.cloudfront.net/column/\(selectedItem.id)?webview=ftcapp&bodyonly=yes",
                        "url":"http://www.ftchinese.com/column/\(selectedItem.id)",
                        "screenName":"homepage/column/\(selectedItem.id)",
                        "compactLayout": "OutOfBox",
                        "coverTheme": "OutOfBox-LifeStyle"
                    ]
                    dataViewController.pageTitle = selectedItem.headline
                    navigationController?.pushViewController(dataViewController, animated: true)
                    return false
                }
            case "setting":
                let optionInfo = Setting.get(selectedItem.id)
                if let optionType = optionInfo.type {
                    if optionType == "switch" {
                        return false
                    } else {
                        Setting.handle(selectedItem.id, type: optionType, title: selectedItem.headline)
                    }
                } else {
                    return false
                }
            case "option":
                if let optionsId = dataObject["id"] {
                    let selectedIndex = indexPath.row
                    fetches = ContentFetchResults(
                        apiUrl: fetches.apiUrl,
                        fetchResults: Setting.updateOption(optionsId, with: selectedIndex, from: fetches.fetchResults)
                    )
                    collectionView?.reloadData()
                }
                return true
            case "ad", "follow":
                print ("Tap an ad. Let the cell handle it by itself. ")
                return false
            case "ebook":
                if let contentItemViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentItemViewController") as? ContentItemViewController {
                    contentItemViewController.dataObject = selectedItem
                    contentItemViewController.hidesBottomBarWhenPushed = true
                    contentItemViewController.themeColor = themeColor
                    navigationController?.pushViewController(contentItemViewController, animated: true)
                }
                
            case "ViewController":
                if let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                    navigationController?.pushViewController(chatViewController, animated: true)
                }
                break
                
            default:
                //MARK: if it is a story, video or other types of HTML based content, push the detailViewController
                if let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail View") as? DetailViewController {
                    var pageData1 = [ContentItem]()
                    //                    var pageData2 = [ContentItem]()
                    var currentPageIndex = 0
                    var pageIndexCount = 0
                    for (sectionIndex, section) in fetches.fetchResults.enumerated() {
                        for (itemIndex, item) in section.items.enumerated() {
                            if ["story", "video", "interactive", "photo"].contains(item.type) {
                                if sectionIndex == indexPath.section && itemIndex == indexPath.row {
                                    currentPageIndex = pageIndexCount
                                }
                                pageData1.append(item)
                                pageIndexCount += 1
                            }
                            
                        }
                    }
                    let pageDataRaw = pageData1
                    
                    /* MARK: - Reorder the page
                     for (sectionIndex, section) in fetches.fetchResults.enumerated() {
                     for (itemIndex, item) in section.items.enumerated() {
                     if ["story", "video", "interactive", "photo"].contains(item.type) {
                     if sectionIndex > indexPath.section || (sectionIndex == indexPath.section && itemIndex >= indexPath.row) {
                     pageData1.append(item)
                     } else {
                     pageData2.append(item)
                     }
                     
                     }
                     }
                     }
                     
                     let pageDataRaw = pageData1 //+ pageData2
                     */
                    
                    
                    let withAd = AdLayout.insertFullScreenAd(to: pageDataRaw, for: currentPageIndex)
                    let pageData = withAd.contentItems
                    print (pageData)
                    currentPageIndex = withAd.pageIndex
                    pageData[currentPageIndex].isLandingPage = true
                    detailViewController.themeColor = themeColor
                    detailViewController.contentPageData = pageData
                    detailViewController.currentPageIndex = currentPageIndex
                    navigationController?.pushViewController(detailViewController, animated: true)
                }
            }
        }
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        //        print ("prepare for segue here")
        
    }
    
    @objc open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        //navigationController?.performSegue(withIdentifier: "Show News Detail", sender: self)
        //performSegue(withIdentifier: "Show Detail Content", sender: self)
        //        print ("header view tapped")
        
        
    }
    
}


extension DataViewController {
    
    // MARK: - load IAP products and update UI
    fileprivate func loadProducts() {
        IAPs.shared.products = []
        FTCProducts.store.requestProducts{[weak self] success, products in
            if success {
                if let products = products {
                    //self?.products = products
                    IAPs.shared.products = products
                }
            }
            // MARK: - Get product regardless of the request result
            print ("product loaded: \(String(describing: IAPs.shared.products))")
            
            let contentSections = ContentSection(
                title: "",
                items: IAP.get(IAPs.shared.products, in: "ebook"),
                type: "List",
                adid: ""
            )
            let results = ContentFetchResults(apiUrl: "", fetchResults: [contentSections])
//            let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
//            let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
            self?.updateUI(with: results)
            
            
            //            self.productToJSCode(self.products, jsVariableName: "displayProductsOnHome", jsVariableType: "function")
            //            self.productToJSCode(self.products, jsVariableName: "iapProducts", jsVariableType: "object")
        }
        
    }
    
    
}

extension DataViewController {
    
    // MARK: - load settings and update UI
    fileprivate func loadSettings() {
        let contentSections = GB2Big5.convert(Settings.page)
        let results = ContentFetchResults(apiUrl: "", fetchResults: contentSections)
//        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
//        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
        updateUI(with: results)
    }
    
    // MARK: load options and update UI
    fileprivate func loadOptions() {
        if let id = dataObject["id"] {
            let contentSections = GB2Big5.convert(Setting.getContentSections(id))
            let results = ContentFetchResults(apiUrl: "", fetchResults: contentSections)
//            let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
//            let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
            updateUI(with: results)
            
        }
    }
    
    
}



extension DataViewController : UICollectionViewDelegateFlowLayout {
    
    func getSizeInfo() -> (sizeClass: UIUserInterfaceSizeClass, itemsPerRow: CGFloat) {
        let horizontalClass = UIScreen.main.traitCollection.horizontalSizeClass
        let verticalCass = UIScreen.main.traitCollection.verticalSizeClass
        let itemsPerRow: CGFloat
        let currentSizeClass: UIUserInterfaceSizeClass
        if horizontalClass != .regular || verticalCass != .regular {
            itemsPerRow = 1
            currentSizeClass = .compact
        } else {
            itemsPerRow = 3
            currentSizeClass = .regular
        }
        return (currentSizeClass, itemsPerRow)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print ("sizeFor Item At called")
        let sizeInfo = getSizeInfo()
        let itemsPerRow = sizeInfo.itemsPerRow
        let currentSizeClass = sizeInfo.sizeClass
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem: CGFloat
        let heightPerItem: CGFloat
        // TODO: Should do the layout based on cell's properties
        let reuseIdentifier = getReuseIdentifierForCell(indexPath)
        if reuseIdentifier == "SettingCell" || reuseIdentifier == "OptionCell" {
            widthPerItem = availableWidth / itemsPerRow
            heightPerItem = 44
        } else if reuseIdentifier == "BookCell" {
            widthPerItem = availableWidth / itemsPerRow
            heightPerItem = 160 + 14 + 14
        }  else if reuseIdentifier == "IconCell" {
            widthPerItem = availableWidth / 3
            heightPerItem = availableWidth / 3 + 60
        } else if indexPath.row == 0 && indexPath.section == 1{
            if currentSizeClass == .regular {
                widthPerItem = (availableWidth / itemsPerRow) * 2
                heightPerItem = widthPerItem * 0.618
            } else {
                widthPerItem = availableWidth
                heightPerItem = widthPerItem * 2
            }
        } else {
            widthPerItem = availableWidth / itemsPerRow
            heightPerItem = widthPerItem * 0.618
        }
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}


// MARK: Handle links here
extension DataViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if navigationAction.navigationType == .linkActivated{
                if urlString.range(of: "mailto:") != nil{
                    UIApplication.shared.openURL(url)
                } else {
                    openLink(url)
                }
                decisionHandler(.cancel)
            }  else {
                decisionHandler(.allow)
            }
        }
    }
}

// MARK: Handle Message from Web View
extension DataViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "items" {
            fetches = ContentFetchResults(
                apiUrl: "",
                fetchResults: contentAPI.formatJSON(message.body)
            )
            prefetch()
        } else if message.name == "selectItem" {
            //print (message.body)
            if let rowString = message.body as? String,
                let row = Int(rowString) {
                let indexPath = IndexPath(row: row, section: 0)
                _ = handleItemSelect(indexPath)
            } else {
                print ("item row is not an int: \(message.body)")
            }
        } else if let body = message.body as? [String: String] {
            if message.name == "alert" {
                if let title = body["title"], let lead = body["message"] {
                    Alert.present(title, message: lead)
                }
            }
        }
    }
}


//extension DataViewController {
//    // MARK: - There's a bug on iOS 9 so that you can't set decelerationRate directly on webView
//    // MARK: - http://stackoverflow.com/questions/31369538/cannot-change-wkwebviews-scroll-rate-on-ios-9-beta
//    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
//    }
//}

// MARK: Search Related Functions. As FTC don't have a well-structured https search API yet, use web to render search.
extension DataViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        searchKeywords = searchBar.text
    }
    
    fileprivate func search() {
        if let keywords = searchKeywords, keywords != "" {
            let jsCode = APIs.jsForSearch(keywords)
            webView?.evaluateJavaScript(jsCode) { (result, error) in
                if result != nil {
                    print (result ?? "unprintable JS result")
                }
            }
            searchBar?.resignFirstResponder()
            // MARK: Remember My Last Search Key Words
            let searchHistoryMaxLength = 10
            var searchHistory = UserDefaults.standard.array(forKey: Key.searchHistory) as? [String] ?? [String]()
            searchHistory = searchHistory.filter{
                $0 != keywords
            }
            searchHistory.insert(keywords, at: 0)
            var searchHistoryNew = [String]()
            for (index, value) in searchHistory.enumerated() {
                if index < searchHistoryMaxLength {
                    searchHistoryNew.append(value)
                }
            }
            UserDefaults.standard.set(searchHistoryNew, forKey: Key.searchHistory)
        }
    }
    
    fileprivate func getSearchHistoryHTML() -> String {
        let searchHistory = UserDefaults.standard.array(forKey: Key.searchHistory) as? [String] ?? [String]()
        var searchHistoryHTML = ""
        for (index, keyword) in searchHistory.enumerated() {
            let firstChildClass: String
            if index == 0 {
                firstChildClass = " first-child"
            } else {
                firstChildClass = ""
            }
            searchHistoryHTML += "<div onclick=\"search('\(keyword)')\" class=\"oneStory story\(firstChildClass)\"><div class=\"headline\">\(keyword)</div></div>"
        }
        if searchHistoryHTML != "" {
            searchHistoryHTML = "<a class=\"section\"><span>\(GB2Big5.convert("搜索历史"))</span></a>" + searchHistoryHTML
        } else {
            searchHistoryHTML = "<div class=\"oneStory story first-child\"><div class=\"headline\">\(GB2Big5.convert("输入关键字开始搜索"))</div></div>"
        }
        return searchHistoryHTML
    }
    
}



// MARK: - Private
//private extension DataViewController {
//    func itemForIndexPath(indexPath: IndexPath) -> ContentItem {
//        return fetches[(indexPath as NSIndexPath).section].fetchResults[(indexPath as IndexPath).row]
//    }
//}

/*
 extension DataViewController {
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
 return true
 }
 
 override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
 return true
 }
 
 override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
 
 print ("performAction called! ")
 }
 
 }
 */
