//
//  PrintManager.swift
//  Jincaishou
//
//  Created by tuomiao on 2018/3/3.
//  Copyright © 2018年 yachi. All rights reserved.
//

import Foundation

class PrintManager {

    func Connect(ip:String,port:UInt16) {
       var wf =  JMWifi.init()
       wf.connect(withHost: ip, port: port, formRecovery: true, complete: nil)
      //wf.connect(withHost: , port: , formRecovery: <#T##Bool#>, complete: <#T##JMComplete?##JMComplete?##(Error?) -> Void#>)
    }
}
