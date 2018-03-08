//
//  JMWifi.h
//  JMWireless
//
//  Created by admin on 16/11/21.
//  Copyright © 2016年 jolimark. All rights reserved.
//

#import "JMWirelessBasic.h"
@class GCDAsyncSocket;
@class GCDAsyncUdpSocket;

/*! @discussion Wifi 单例对象 */
#define SINGLETONWIFI [JMWifi shareWifi]

/************************************** 类 与 函 数 定 义 **************************************/
#pragma mark -- 类 与 函 数 定 义
/*!
 *  @class JMWifi
 *  @brief       无线 Wifi 通讯
 *  @superclass  SuperClass: JMWirelessBasic
 *  @classdesign JMWifi 是一个单例类型的对象
 */
NS_CLASS_AVAILABLE_IOS(7_0)
@interface JMWifi : JMWirelessBasic
{
@private
    NSMutableArray    *broadcastMasks;  // 广播标志
    GCDAsyncSocket    *socket;          // tcp socket 实例
    GCDAsyncUdpSocket *udpSocket;       // udp socket 实例
    JMDiscoverWifi discoverWifi;        // 发现 Wifi devices 回调
}
/*! 
 *  @brief 设备端口号
 *  @link -connectWithHost:port:defendLose:complete: @/link 中设置值，在下一次设置值前，其值不变
 */
@property (nonatomic, assign, readonly) uint16_t port;
/*! 
 *  @brief 设备端 IP
 *  @link -connectWithHost:port:defendLose:complete: @/link 中设置值，在下一次设置值前，其值不变
 */
@property (nonatomic, copy, readonly, nullable) NSString *ip;


/*!
 *  @discussion 单例
 *
 *  @return JMWifi 单例对象
 */
+ (nonnull JMWifi *)shareWifi;

/*!
 *  @discussion 扫描打印机
 *
 *  @param discover 发现打印机回调
 */
- (void)scanWithDiscover:(nullable JMDiscoverWifi)discover;

/*!
 *  @discussion 连接打印机
 *
 *  @param ip         打印机IP
 *  @param port       打印机端口号
 *  @param formRecovery 是否使用防丢单协议
 *  @param complete   连接完成回调
 */
- (void)connectWithHost:(nonnull NSString *)ip
                   port:(uint16_t)port
           formRecovery:(BOOL)formRecovery
               complete:(nullable JMComplete)complete;
@end










