//
//  JMBle.h
//  JMWireless
//
//  Created by admin on 16/11/21.
//  Copyright © 2016年 jolimark. All rights reserved.
//

#import "JMWirelessBasic.h"

/*! @discussion 蓝牙单例对象 */
#define SINGLETONBLE [JMBle shareBle]

/************************************** 类 与 函 数 定 义 **************************************/
#pragma mark -- 类 与 函 数 定 义
/*!
 *  @class JMBle
 *  @brief       无线蓝牙通讯
 *  @superclass  SuperClass: JMWirelessBasic
 *  @classdesign JMBle 是一个单例类型的对象
 */
NS_CLASS_AVAILABLE_IOS(7_1)
@interface JMBle : JMWirelessBasic
<
    CBPeripheralDelegate,
    CBCentralManagerDelegate
>
{
@private
    NSTimer          *conTimeout;      // 连接超时
    CBCentralManager *centralManager;  // 蓝牙
    JMDiscoverBle discoverBle;         // 发现 ble 回调
}
/*! 
 *  @brief 外设
 *  @link -connectWithPeripheral:defendLose:complete: @/link 中设置值，在下一次设置值前，其值不变 
 */
@property (nonatomic, strong, readonly, nullable) CBPeripheral *peripheral;
/*! @brief 蓝牙状态 */
@property (nonatomic, assign, readonly) CBCentralManagerState state;


/*!
 *  @discussion 单例
 *
 *  @return JMBle 单例对象
 */
+ (nonnull JMBle *)shareBle;

/*!
 *  @discussion 扫描打印机
 *
 *  @param discover 发现打印机回调
 */
- (void)scanWithDiscover:(nullable JMDiscoverBle)discover;

/*!
 *  @discussion 连接外设
 *
 *  @param peripheral 外设
 *  @param formRecovery 是否使用防丢单协议
 *  @param completed  连接完成回调
 */
- (void)connectWithPeripheral:(nonnull CBPeripheral *)peripheral
                 formRecovery:(BOOL)formRecovery
                     complete:(nullable JMComplete)completed;
@end








