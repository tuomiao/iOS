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
        self.view.window?.rootViewController = ViewController()
        // 检查权限
        chekPushAth()
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.userContentController = WKUserContentController()
        config.userContentController.add(self, name:"setClear")
        config.userContentController.add(self, name:"setWIFI")
        config.userContentController.add(self, name:"setMsgIconNumber")
        config.userContentController.add(self, name:"getDevToken")
        config.userContentController.add(self, name:"setPrint")
        config.userContentController.add(self, name:"printPicture")//
        config.userContentController.add(self, name:"goBack")
        config.userContentController.add(self, name:"goForward")
        config.userContentController.add(self, name:"reload")
        config.preferences.javaScriptEnabled = true
        
        //config.dataDetectorTypes = WKDataDetectorTypes.all
        // config.allowsPictureInPictureMediaPlayback = true
        
        config.applicationNameForUserAgent = "/yalongiOS"
        //将浏览器视图全屏(在内容区域全屏,不占用顶端时间条)
        let frame = CGRect(x:0, y:20, width:UIScreen.main.bounds.width,
                           height:UIScreen.main.bounds.height-20)
        webView = WKWebView(frame:frame,configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        //禁用页面在最顶端时下拉拖动效果
        webView.scrollView.bounces = false
        // 监听支持KVO的属性
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.sizeToFit()
        // self.view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            webView.insetsLayoutMarginsFromSafeArea = true
        } else {
            // Fallback on earlier versions
        }
        
        self.view.addSubview(webView)
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 5)
        progressView.trackTintColor = UIColor.clear
        progressView.progressTintColor = UIColor.green
        progressView.isHidden = false
        webView.addSubview(progressView)
        // 加载内容
        LoadUrl(curr_url: "http://testm.guoyuandi.cn")
        //  LoadUrl(curr_url: "http://192.168.10.65")
        //        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.alwaysBounceVertical = false
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = [ UIRectEdge.bottom , UIRectEdge.left , UIRectEdge.right]
        self.navigationController?.navigationBar.isTranslucent = true
        self.view.backgroundColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated:Bool) {
        
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        
        
    }
    override func viewDidAppear(_ animated:Bool) {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
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
        if message.name=="getDevToken" { // 获取 DevToken
            print(dev_token)
            webView.evaluateJavaScript("setdev(\'"+dev_token+"\','\(UIDevice.current.name)')", completionHandler: { (any,error) in
                //            print(UIDevice.current.name)
                //                print(UIDevice.current.identifierForVendor)
                //                print(UIDevice.current.localizedModel)
                //                print(UIDevice.current.model)
                //               // Mirror(reflecting:utsname().machine).children.reduce("")
                //                print(UIDevice.current.systemName)
                //                print(UIDevice.current.systemVersion)
                //                print(UIDevice.current.description)
            })
        }else if message.name=="clearData"{ // 清除缓存
            setClearData()
            webView.evaluateJavaScript("DoResult(\'\')", completionHandler: { (any,error) in
                
            })
            
        }else if message.name == "setMsgIconNumber"{ // 设置角标
            UIApplication.shared.cancelAllLocalNotifications()
            
            //创建UILocalNotification来进行本地消息通知
            let localNotification = UILocalNotification()
            //设置应用程序右上角的提醒个数
            if(localNotification.applicationIconBadgeNumber > -1 ){
                localNotification.applicationIconBadgeNumber -= 1;
                UIApplication.shared.scheduleLocalNotification(localNotification)
            }
        }else if message.name == "setPrint" { // 设置打印机
            setPrint()
        } else if message.name == "printPicture" { // 打印图片
            printPicture(path: message.body as! String)
        } else if message.name == "goBack" { // 后退
            webView.goBack()
        } else if message.name == "goForward" { // 前进
            webView.goForward()
        } else if message.name == "reload" { // 刷新
            webView.reload()
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //页面开始加载时调用
        let url:String = (webView.url?.absoluteString)!
        print(url)
        if  url.contains("fs.guoyuandi.cn"){
            webView.stopLoading()
            UIApplication.shared.openURL( URL(string: url)!)
        }
//        var url = webView.url?.absoluteString
//        if let url = NSURL(string:"http://www.apple.com/itunes/charts/paid-apps/")  {
//
//            UIApplication.sharedApplication().openURL(url)
//        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //当内容开始返回时调用
        print("didCommit")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 页面加载完成之后调用
        webView.scrollView.scrollsToTop = true
        print("didFinish:\( webView.scrollView.contentSize.height) --  \( webView.scrollView.contentSize.width)")
        if #available(iOS 11.0, *) {
            print(view.safeAreaInsets)
            print(webView.safeAreaInsets)
        } else {
            // Fallback on earlier versions
        }
        //  webView.evaluateJavaScript("setdev('\(dev_token)')") { (any, error)-> Void in
        //   print("setDev")
        // }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 页面加载完成之后调用
        print("didFail")
        
    }
    
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        //// 接收到服务器跳转请求之后调用
        print("didReceiveServerRedirectForProvisionalNavigation")
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
        switch navigationAction.navigationType {
        case WKNavigationType.linkActivated:
            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
            break
        case WKNavigationType.formSubmitted:
            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
            break
        case WKNavigationType.backForward:
            break
        case WKNavigationType.reload:
            break
        case WKNavigationType.formResubmitted:
            break
        case WKNavigationType.other:
            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
            break
        }
        decisionHandler(.allow)
        // 在发送请求之前，决定是否跳转
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        print("decidePolicyFor")
        decisionHandler(.allow)
        
        // 在收到响应后，决定是否跳转
    }
    
    
    //MARK: - WKUIDelegate
    // 创建一个新的WebView
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("createWebViewWith")
        return WKWebView()
    }
    
    // 输入框
    // JS端调用prompt函数时，会触发此方法
    // 要求输入一段文本
    // 在原生输入得到文本内容后，通过completionHandler回调给JS
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void){
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) -> Void in
            textField.textColor = UIColor.red
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) -> Void in
            completionHandler(alert.textFields![0].text!)
        }))
        self.present(alert, animated: true, completion: nil)
        print("prompt")
        
    }
    
    
    // 确认框
    // JS端调用confirm函数时，会触发此方法
    // 通过message可以拿到JS端所传的数据
    // 在iOS端显示原生alert得到YES/NO后
    // 通过completionHandler回调给JS端
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    // 警告框
    // 在JS端调用alert函数时，会触发此代理方法。
    // JS端调用alert时所传的数据可以通过message拿到
    // 在原生得到结果后，需要回调JS，是通过completionHandler回调
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) -> Void in
            completionHandler()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) -> Void in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    ///////////////////////////////////////////
    
    
    
    //保存请求链接
    fileprivate var snapShotsArray:Array<Any>?
    //请求链接处理
    fileprivate func pushCurrentSnapshotView(_ request: NSURLRequest) -> Void {
        // 连接是否为空
        guard let urlStr = snapShotsArray?.last else { return }
        // 转换成URL
        let url = URL(string: urlStr as! String)
        // 转换成NSURLRequest
        let lastRequest = NSURLRequest(url: url!)
        // 如果url是很奇怪的就不push
        if request.url?.absoluteString == "about:blank"{ return }
        return //
        // 如果url一样就不进行push
        if (lastRequest.url?.absoluteString == request.url?.absoluteString) {return}
        // snapshotView
        let currentSnapShotView = webView.snapshotView(afterScreenUpdates: true);
        //向数组添加字典
        snapShotsArray = [["request":request,"snapShotView":currentSnapShotView]]
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWIFISet"{
            let controller = segue.destination as! WIFISettingController
            // controller.itemString = sender as? String
        }
    }
    
    ///////////////////////////////////////////
    
    func setPrint() {
        // 设置打印机
        self.performSegue(withIdentifier: "ShowWIFISet", sender: "")
        
        //        let sb = UIStoryboard(name: "Main", bundle:   Bundle.main)
        //        let vc = sb.instantiateViewController(withIdentifier: "WIFISettingController")
        //        self.presentingViewController?.addChildViewController(vc)
    }
    
    func printPicture(path:String) {
        print(path)
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
