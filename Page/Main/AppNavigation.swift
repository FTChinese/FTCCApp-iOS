//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct AppNavigation {
    
    // MARK: - Use singleton pattern to pass speech data between view controllers.
    static let sharedInstance = AppNavigation()
    private static let appMap = [
        "News": [
            "title": "FT中文网",
            "title-image":"FTC-Header",
            "navColor": "#333333",
            "navBackGroundColor": "#f7e9d8",
            "isNavLightContent": false,
            "navRightItem": "Search",
            "navLeftItem": "Chat",
            "Channels": [
                [
                    "title": "首页",
                    "api":"https://d37m993yiqhccr.cloudfront.net/index.php/jsapi/publish/home",
                    "url":"http://www.ftchinese.com/",
                    "screenName":"homepage",
                    "Insert Content": "home"
                ],
                [
                    "title": "中国",
                    "api":"https://d37m993yiqhccr.cloudfront.net/channel/china.html?type=json",
                    "url":"http://www.ftchinese.com/channel/china.html",
                    "regularLayout": "",
                    "screenName":"homepage/china",
                    "coverTheme":"Wheat"
                ],
                [
                    "title": "全球",
                    "api":"https://d37m993yiqhccr.cloudfront.net/channel/world.html?type=json",
                    "url":"http://www.ftchinese.com/channel/world.html",
                    "screenName":"homepage/world",
                    "coverTheme":"Pink"
                ],
                [
                    "title": "金融市场",
                    "api":"https://d37m993yiqhccr.cloudfront.net/channel/markets.html?type=json",
                    "url":"http://www.ftchinese.com/channel/markets.html",
                    "screenName":"homepage/markets"
                ],
                [
                    "title": "管理",
                    "api":"https://d37m993yiqhccr.cloudfront.net/channel/management.html?type=json",
                    "url":"http://www.ftchinese.com/channel/management.html",
                    "screenName":"homepage/management",
                    "coverTheme": "Blue"
                ],
                [
                    "title": "生活时尚",
                    "api":"https://d37m993yiqhccr.cloudfront.net/channel/lifestyle.html?type=json",
                    "url":"http://www.ftchinese.com/channel/lifestyle.html",
                    "screenName":"homepage/lifestyle",
                    "coverTheme": "Lifestyle"
                ],
                [
                    "title": "专栏",
                    "api":"https://d37m993yiqhccr.cloudfront.net/channel/column.html?type=json",
                    "url":"http://www.ftchinese.com/channel/column.html",
                    "screenName":"homepage/column",
                    "coverTheme": "Opinion"
                ],
                [
                    "title": "热门文章",
                    "url":"http://www.ftchinese.com/channel/weekly.html?webview=ftcapp",
                    "compactLayout": "Simple Headline",
                    "regularLayout": "",
                    "screenName":"homepage/mostpopular"
                ],
                [
                    "title": "数据新闻",
                    "url":"http://www.ftchinese.com/channel/datanews.html?webview=ftcapp",
                    "screenName":"homepage/datanews"
                ],
                [
                    "title": "FTCC",
                    "api":"https://d37m993yiqhccr.cloudfront.net/index.php/jsapi/publish/ftcc",
                    "compactLayout": "All Cover",
                    "regularLayout": "",
                    "url":"http://www.ftchinese.com/channel/datanews.html",
                    "screenName":"homepage/ftcc"
                ],
                [
                    "title": "会议活动",
                    "url":"http://www.ftchinese.com/m/events/event.html?webview=ftcapp&001",
                    "screenName":"homepage/events"
                ],
                [
                    "title": "FT研究院",
                    "url":"http://www.ftchinese.com/m/marketing/intelligence.html?webview=ftcapp&001",
                    "screenName":"homepage/ftintelligence"
                ],
                [
                    "title": "FT电子书",
                    "type": "iap",
                    "subtype":"ebook",
                    "compactLayout": "books",
                    "screenName":"homepage/ftintelligence"
                ]
            ]
        ],
        "English": [
            "title": "每日英语",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#a84358",
            "isNavLightContent": true,
            "Channels": [
                [
                    "title": "英语电台",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=radio",
                    "url":"http://www.ftchinese.com/channel/radio.html?webview=ftcapp",
                    "screenName":"english/radio",
                    "coverTheme": ""
                ],
                [
                    "title": "双语阅读",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=ce",
                    "url":"http://www.ftchinese.com/channel/ce.html?webview=ftcapp",
                    "screenName":"english/read",
                    "coverTheme": ""
                ],
                [
                    "title": "金融英语速读",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=speedread",
                    "url":"http://www.ftchinese.com/channel/speedread.html?webview=ftcapp",
                    "screenName":"english/speedread",
                    "coverTheme": ""
                ],
                [
                    "title": "原声视频",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=ev",
                    "url":"http://www.ftchinese.com/channel/ev.html?webview=ftcapp",
                    "screenName":"english/video",
                    "coverTheme": ""
                ]
            ]
        ],
        "Academy": [
            "title": "FT商学院",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#057b93",
            "isNavLightContent": true,
            "Channels": [
                [
                    "title": "热点观察",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=hotcourse",
                    "url":"http://www.ftchinese.com/channel/mba.html",
                    "screenName":"ftacademy/hottopic",
                    "coverTheme": "Wheat"
                ],
                [
                    "title": "MBA训练营",
                    "api":"https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=mbacamp",
                    "url":"http://www.ftchinese.com/channel/mbagym.html?webview=ftcapp",
                    "screenName":"ftacademy/mbagym",
                    "coverTheme": "Wheat"
                ],
                [
                    "title": "互动小测",
                    "api":"https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=quizplus",
                    "url":"http://www.ftchinese.com/channel/mba.html",
                    "screenName":"ftacademy/quiz",
                    "coverTheme": "Wheat"
                ],
                [
                    "title": "商学院观察",
                    "api":"https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=mbastory",
                    "url":"http://www.ftchinese.com/channel/mba.html",
                    "screenName":"ftacademy/read",
                    "coverTheme": "Wheat"
                ],
                [
                    "title": "深度阅读",
                    "api":"https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=mbaread",
                    "url":"http://www.ftchinese.com/channel/mba.html",
                    "screenName":"ftacademy/read",
                    "coverTheme": "Wheat"
                ]
            ]
        ],
        "Video": [
            "title": "视频",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#008280",
            "isNavLightContent": true,
            "Channels": [
                [
                    "title": "最新",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=stream",
                    "url":"http://www.ftchinese.com/channel/stream.html?webview=ftcapp",
                    "coverTheme": "Video",
                    "compactLayout": "Video",
                    "screenName":"video"
                ],
                [
                    "title": "政经",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=vpolitics",
                    "url":"http://www.ftchinese.com/channel/vpolitics.html?webview=ftcapp",
                    "screenName":"ftacademy/politics",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "商业",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=vbusiness",
                    "url":"http://www.ftchinese.com/channel/business.html?webview=ftcapp",
                    "screenName":"ftacademy/business",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "秒懂",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=explainer",
                    "url":"http://www.ftchinese.com/channel/business.html?webview=ftcapp",
                    "screenName":"ftacademy/business",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "金融",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=vfinance",
                    "url":"http://www.ftchinese.com/channel/business.html?webview=ftcapp",
                    "screenName":"ftacademy/business",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "文化",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=vculture",
                    "url":"http://www.ftchinese.com/channel/business.html?webview=ftcapp",
                    "screenName":"ftacademy/business",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "高端视点",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=viewtop",
                    "url":"http://www.ftchinese.com/channel/business.html?webview=ftcapp",
                    "screenName":"ftacademy/business",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ],
                [
                    "title": "有色眼镜",
                    "api": "https://danla2f5eudt1.cloudfront.net/channel/json.html?pageid=tinted",
                    "url":"http://www.ftchinese.com/channel/videotinted.html?webview=ftcapp",
                    "screenName":"ftacademy/tinted",
                    "coverTheme": "Video",
                    "compactLayout": "Video"
                ]
            ]
        ],
        "MyFT": [
            "title": "我的FT",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#5a8caf",
            "isNavLightContent": true,
            "Channels": [
                [
                    "title": "关注",
                    "type": "follow",
                    "screenName":"myft",
                    "Insert Content": "follows"
                ],
                [
                    "title": "收藏",
                    "type": "clip",
                    "screenName":"myft"
                ],
                ["title": "已读",
                 "type": "read",
                 "screenName":"myft"
                ],
                [
                    "title": "偏好",
                    "api":"https://d37m993yiqhccr.cloudfront.net/users/mytopics?type=json",
                    "url":"http://www.ftchinese.com/users/mytopics",
                    "screenName":"myft/preference"
                ],
                [
                    "title": "订阅",
                    "api":"https://d37m993yiqhccr.cloudfront.net/users/favstorylist?type=json",
                    "url":"http://www.ftchinese.com/users/favstorylist",
                    "screenName":"myft/subscription"
                ],
                [
                    "title": "账户",
                    "api":"https://d37m993yiqhccr.cloudfront.net/users/discover?type=json",
                    "url":"http://www.ftchinese.com/users/discover",
                    "screenName":"myft/account"
                ]
            ]
        ]
    ]
    
    static let search = [
        "title": "Search",
        "url":"http://www.ftchinese.com/channel/weekly.html?webview=ftcapp",
        "screenName":"Search/Main",
        "type": "Search"
    ]
    
    public static func getNavigation(for tabName: String) -> [String]? {
        if let currentNavigation = appMap[tabName]?["Channels"] as? [String] {
            return currentNavigation
        }
        return nil
    }
    
    public static func getNavigationProperty(for tabName: String, of property: String) -> String? {
        if let p = appMap[tabName]?[property] as? String {
            return p
        }
        return nil
    }
    
    public static func isNavigationPropertyTrue(for tabName: String, of property: String) -> Bool {
        if let p = appMap[tabName]?[property] as? Bool {
            return p
        }
        return false
    }
    
    public static func getNavigationPropertyData(for tabName: String, of property: String) -> [[String: String]]? {
        if let p = appMap[tabName]?[property] as? [[String: String]] {
            return p
        }
        return nil
    }
    
    public static func getThemeColor(for tabName: String?) -> UIColor {
        let themeColor: UIColor
        if let tabName = tabName,
            let tabBackGroundColor = getNavigationProperty(for: tabName, of: "navBackGroundColor") {
            let isNavLightContent = isNavigationPropertyTrue(for: tabName, of: "isNavLightContent")
            if isNavLightContent == true {
                themeColor = UIColor(hex: tabBackGroundColor)
            } else {
                themeColor = UIColor(hex: Color.Tab.highlightedText)
            }
        } else {
            themeColor = UIColor(hex: Color.Tab.highlightedText)
        }
        return themeColor
    }
    
}
