//
//  AppDelegate.swift
//  Jincaishou
//
//  Created by tuomiao on 2018/2/24.
//  Copyright © 2018年 yachi. All rights reserved.
//

import UIKit
import UserNotifications

public var dev_token:String = "";//声明一个全局变量；

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let notificationHandler = NotificationHandler()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //请求通知权限
      //  self.window?.rootViewController = ViewController as UIViewController
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) {
                    (accepted, error) in
                    if !accepted {
                        print("用户不允许消息通知。")
                    }
                    print("zhuce tongzhi")
            }
        } else {
            // Fallback on earlier versions
            var settings:UIUserNotificationSettings = UIUserNotificationSettings(types: UIUserNotificationType(rawValue: UIUserNotificationType.RawValue(UInt8(UIUserNotificationType.alert.rawValue)|UInt8(UIUserNotificationType.sound.rawValue)|UInt8(UIUserNotificationType.badge.rawValue))), categories: nil)
         
            
            UIApplication.shared.registerUserNotificationSettings(settings)
           // UIApplication.shared.registerForRemoteNotifications()
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = notificationHandler
            print("shezhi weituo")
        } else {
            // Fallback on earlier versions
            
        }
        
        //向APNs请求token
        UIApplication.shared.registerForRemoteNotifications()

//        /////// user-agent ///////
//            var _webview = UIWebView(frame: CGRect.zero);
//        var old_agent = _webview.stringByEvaluatingJavaScript(from: "navigator.userAgent")
//        var new_agent = old_agent;
//        if   !old_agent!.hasSuffix("yalongiOS")
//        {
//            new_agent = old_agent?.appending("/yalongiOS")
//        }
//        print(new_agent)
//        var dic:Dictionary = Dictionary<String,String>()
//        dic["UserAgent"] = new_agent
//      //  dic["User-Agent"] = new_agent
//       // (objects: new_agent,forKeys: "new_agent")
//
//        UserDefaults.standard.register(defaults: dic)
//        UserDefaults.standard.synchronize()
        return true
    }
    //token请求回调
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //打印出获取到的token字符串
        dev_token=deviceToken.hexString
        print("hui diao token:\(dev_token)")
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
//对Data类型进行扩展
extension Data {
    //将Data转换为String
    var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}



class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    //在应用内展示通知
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
    
        completionHandler([.alert, .sound,.badge])
        
        // 如果不想显示某个通知，可以直接用空 options 调用 completionHandler:
        // completionHandler([])
    }
    //对通知进行响应（用户与通知进行交互时被调用）
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
        @escaping () -> Void) {
        
        do{
            //获取通知附加数据
            var url :String="",msgId:String="";
            
            if response.notification.request.content.userInfo["RedirectUrl"] == nil {
                print(response.notification.request.content.userInfo)
                let aps = response.notification.request.content.userInfo["aps"] as! [String:AnyObject]
                let tmp = aps["alert"]as! [String:AnyObject]
                if    tmp.keys.contains("MessageReceiverId"){
                    url = tmp["RedirectUrl"] as! String
                }
            }
            else{
                url = response.notification.request.content.userInfo["RedirectUrl"] as! String
                
            }
            
            if response.notification.request.content.userInfo["MessageReceiverId"] == nil {
                let aps = response.notification.request.content.userInfo["aps"] as! [String:AnyObject]
                let tmp = aps["alert"]as! [String:AnyObject]
                
                if    tmp.keys.contains("MessageReceiverId"){
                    msgId = tmp["MessageReceiverId"] as! String
                }
            }
            else{
                msgId = response.notification.request.content.userInfo["MessageReceiverId"] as! String
                
            }
            
            if msgId != nil {
                do{
                    // 转换成URL
                    let url = URL(string: "http://teststpb.guoyuandi.cn/Data/PushMsg/UpdateMessageRead?mrId=\(msgId)" )
                    // 转换成NSURLRequest
                    let lastRequest = URLRequest(url: url!)
                    NSURLConnection.sendAsynchronousRequest(lastRequest, queue:OperationQueue()) { (res, data, error)in
                        
                        
                        
                    }
                    
                    
                }catch{
                    
                }
            }
            print(url)
            if !url.isEmpty{
                let vc:UIViewController
                let win = UIApplication.shared.keyWindow
                let currview = win?.subviews[0]
                if  currview?.next is UIViewController{
                    vc=currview?.next as! UIViewController
                }
                else{
                    vc = (win?.rootViewController)!
                }
                (vc as! ViewController).setWebViewLoadUr(url: url, isLocal: false)
                // WebView.webloadType(self,.url(url:url))
            }
            // UIApplication().applicationIconBadgeNumber-=1;
            //清除所有本地推送
            UIApplication.shared.cancelAllLocalNotifications()
            
            //创建UILocalNotification来进行本地消息通知
            let localNotification = UILocalNotification()
            //设置应用程序右上角的提醒个数
            localNotification.applicationIconBadgeNumber -= 1;
            UIApplication.shared.scheduleLocalNotification(localNotification)
            
        }
        catch {
            
        }
        
        
        completionHandler()
    }
}

