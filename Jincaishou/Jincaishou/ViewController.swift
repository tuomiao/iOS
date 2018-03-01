//
//  ViewController.swift
//  Jincaishou
//
//  Created by tuomiao on 2018/2/24.
//  Copyright © 2018年 yachi. All rights reserved.
//

import UIKit
import JavaScriptCore
import UserNotifications
import  WebKit

class ViewController: UIViewController,WKNavigationDelegate,WKUIDelegate ,WKScriptMessageHandler{
 
    
    var webView:WKWebView!
    /// 进度条
    fileprivate var progressView = UIProgressView()
    
    var jsContext:JSContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // 检查权限
        chekPushAth()
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.userContentController = WKUserContentController()
        config.userContentController.add(self, name:"setClear")
        config.userContentController.add(self, name:"setWIFI")
        config.userContentController.add(self, name:"setMsgIconNumber")
        config.userContentController.add(self, name:"getDevToken")
        config.preferences.javaScriptEnabled = true
        
        //config.dataDetectorTypes = WKDataDetectorTypes.all
        config.allowsPictureInPictureMediaPlayback = true
        
        config.applicationNameForUserAgent = "/yalongiOS"
        //将浏览器视图全屏(在内容区域全屏,不占用顶端时间条)
        let frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width,
                           height:UIScreen.main.bounds.height)
        webView = WKWebView(frame:frame,configuration: config)
       webView.uiDelegate = self
        webView.navigationDelegate = self
        //禁用页面在最顶端时下拉拖动效果
        webView.scrollView.bounces = false
        // 监听支持KVO的属性
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.sizeToFit()
        self.view.translatesAutoresizingMaskIntoConstraints = false
//        webView.insetsLayoutMarginsFromSafeArea = true
        self.view.addSubview(webView)
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 3)
        progressView.trackTintColor = UIColor.clear
        progressView.progressTintColor = UIColor.green
        progressView.isHidden = false
         
        // 加载内容
        LoadUrl(curr_url: "http://m.guoyuandi.cn")
       //  LoadUrl(curr_url: "http://192.168.10.65")
        //        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            // 设置进度条透明度
            progressView.alpha = CGFloat(1.0 - webView.estimatedProgress)
            // 给进度条添加进度和动画
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            // 结束进度
            if Float(webView.estimatedProgress) >= 1.0{
                progressView.alpha = 0.0
                progressView .setProgress(0.0, animated: false)
            }
            print(webView.estimatedProgress)
        }
    }
    func LoadUrl(curr_url: String){
        var strurl:String
        if curr_url.isEmpty {
            strurl = "http://m.guoyuandi.cn"
        }
        else{
            strurl = curr_url
        }
        let url = URL(string:strurl)
        print(strurl)
        
        webView.load(URLRequest(url: url!))
    }
    
    func LoadHtml() {
        let path = Bundle.main.path(forResource: "index", ofType: "html")
        let urlstr = URL.init(fileURLWithPath: path!)
        webView.load(URLRequest.init(url: urlstr))
    }
    func setWebViewLoadUr(url:String,isLocal:Bool){
        if isLocal {
            LoadHtml()
        }else   {
            LoadUrl(curr_url: url)
        }
    }
    //  检查 通知权限
    func chekPushAth(){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings {
                settings in
                switch settings.authorizationStatus {
                case .authorized:
                    return
                case .notDetermined:
                    //请求授权
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge]) {
                            (accepted, error) in
                            if !accepted {
                                print("用户不允许消息通知。")
                            }
                    }
                case .denied:
                    DispatchQueue.main.async(execute: { () -> Void in
                        let alertController = UIAlertController(title: "消息推送已关闭",
                                                                message: "想要及时获取消息。点击“设置”，开启通知。",
                                                                preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
                        
                        let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
                            (action) -> Void in
                            let url = URL(string: UIApplicationOpenSettingsURLString)
                            if let url = url, UIApplication.shared.canOpenURL(url) {
                                if #available(iOS 10, *) {
                                    UIApplication.shared.open(url, options: [:],
                                                              completionHandler: {
                                                                (success) in
                                    })
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                        })
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(settingsAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
        // print(message.body)
        if message.name=="getDevToken" {
            print(dev_token)
            webView.evaluateJavaScript("setdev(\'"+dev_token+"\')", completionHandler: { (any,error) in
               
            })
        }else if message.name=="clearData"{
            setClearData()
            webView.evaluateJavaScript("DoResult(\'\')", completionHandler: { (any,error) in
                
            })
            
        }else if message.name == "setMsgIconNumber"{
            UIApplication.shared.cancelAllLocalNotifications()
            
            //创建UILocalNotification来进行本地消息通知
            let localNotification = UILocalNotification()
            //设置应用程序右上角的提醒个数
            if(localNotification.applicationIconBadgeNumber > -1 ){
                localNotification.applicationIconBadgeNumber -= 1;
                UIApplication.shared.scheduleLocalNotification(localNotification)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //页面开始加载时调用
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //当内容开始返回时调用
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 页面加载完成之后调用
        
        webView.evaluateJavaScript("setdev('\(dev_token)')") { (any, error)-> Void in
            print("setDev")
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 页面加载完成之后调用
    }
    
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        //// 接收到服务器跳转请求之后调用
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url
        
        let scheme = url?.scheme
        
        guard let schemeStr = scheme else { return
            
        }
        if schemeStr == "tel" {
            //iOS10 改为此函数
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [String : Any](), completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        
        decisionHandler(.allow)
        // 在发送请求之前，决定是否跳转
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        
        decisionHandler(.allow)
        
        // 在收到响应后，决定是否跳转
    }
    
    
    //MARK: - WKUIDelegate
    // 创建一个新的WebView
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        return WKWebView()
    }
    
    // 输入框
    // JS端调用prompt函数时，会触发此方法
    // 要求输入一段文本
    // 在原生输入得到文本内容后，通过completionHandler回调给JS
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void){
        
        
        
    }
    
    
    // 确认框
    // JS端调用confirm函数时，会触发此方法
    // 通过message可以拿到JS端所传的数据
    // 在iOS端显示原生alert得到YES/NO后
    // 通过completionHandler回调给JS端
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void){
        
        
    }
    
    
    // 警告框
    // 在JS端调用alert函数时，会触发此代理方法。
    // JS端调用alert时所传的数据可以通过message拿到
    // 在原生得到结果后，需要回调JS，是通过completionHandler回调
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
        
        
    }
    
    ///////////////////////////////////////////
    
    func setPrint() {
        // 设置打印机
        setWIFI()
    }
    
    func setWIFI() {
        // 设置wifi
        let url = URL(string: "prefs:root=WIFI")
        if let url = url, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
       
    }
    
    func setClearData() {
        // 清除缓存 DoResult
        let dateFrom: NSDate = NSDate.init(timeIntervalSince1970: 0)
     
            WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes() , modifiedSince: dateFrom as Date) {
                
                print("清空缓存完成")
        }
    }
    
    func setMsgIcon() {
        // 设置 app 角标
        UIApplication.shared.cancelAllLocalNotifications()
        
        //创建UILocalNotification来进行本地消息通知
        let localNotification = UILocalNotification()
        //设置应用程序右上角的提醒个数
        if(localNotification.applicationIconBadgeNumber > -1 ){
            localNotification.applicationIconBadgeNumber -= 1;
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }

    }
    
    
    
}
