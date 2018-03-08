//
//  JMWirelessDelegate.h
//  JMWireless
//
//  Created by admin on 16/12/5.
//  Copyright © 2016年 jolimark. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#ifndef JMWirelessDelegate_h
#define JMWirelessDelegate_h
/*!
 *  @protocol JMWirelessDelegate
 *  
 *  @brief 无线代理
 */
@protocol JMWirelessDelegate
<
    NSObject
>
@optional
/************************************* 用 于 非 防 丢 单 打 印 *************************************/
#pragma mark -- 非防丢单连接，数据发送完成
/*!
 *  非防丢单连接，数据发送完成代理
 *
 *  @param error 发送错误
 */
- (void)wirelessSendOver:(nullable NSError *)error;



/*************************************** Wifi 代 理 ***************************************/
#pragma mark -- Wifi 代理
/*!
 *  Wifi 断开连接代理
 *
 *  @param error 断开错误
 */
- (void)wifiDisconnected:(nullable NSError *)error;



/*************************************** Ble 代 理 ***************************************/
#pragma mark -- Ble 代 理
/*!
 *  蓝牙状态改变代理
 *
 *  @param state 蓝牙状态
 */
- (void)bleUpdateState:(CBCentralManagerState)state;

/*!
 *  蓝牙断开连接代理
 *
 *  @param error 断开错误
 */
- (void)bleDisconnected:(nullable NSError *)error;
@end
#endif /* JMWirelessDelegate_h */





