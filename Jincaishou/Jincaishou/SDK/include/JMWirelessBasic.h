//
//  JMWirelessBasic.h
//  JMWireless
//
//  Created by admin on 16/11/21.
//  Copyright © 2016年 jolimark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMEnumBlock.h"
#import "JMWirelessDelegate.h"

/***************************************** 类 定 义 *****************************************/
#pragma mark -- 类 定 义
/*!
 *  @class JMWirelessBasic
 *  @brief       无线通讯基类型
 *  @superclass  SuperClass: NSObject
 *  @classdesign 无线通讯的任务发送
 */
@interface JMWirelessBasic : NSObject
{
@protected
    JMTask     currentTask;      // 当前任务
    JMStatus   searchSta;        // 状态任务回调
    JMComplete conCompleted;     // 连接任务回调
    JMComplete startCompleted;   // 开始任务回调
    JMComplete sendCompleted;    // 发送任务回调
    JMComplete finishCompleted;  // 结束任务回调
    JMComplete clearCompleted;   // 清除缓存任务回调
}
/*********************************** Wifi Ble 公 有 属 性 ***********************************/
#pragma mark -- Wifi Ble 公 有 属 性
/*! @brief 无线代理 */
@property (nonatomic, weak) id<JMWirelessDelegate> delegate;
/*! @brief 扫描状态 */
@property (nonatomic, assign, readonly, getter=scan) BOOL isScanning;
/*! @brief 连接状态 */
@property (nonatomic, assign, readonly) BOOL isConnected;
/*! @brief JMPrinterType 打印机类型，连接成功后自动获取 */
@property (nonatomic, assign, readonly) JMPrinterType printerType;
/*! 
 *  @brief 连接协议，如果为 YES 则是开启防丢单，否则为非防丢单
 *  @link -connectWithPeripheral:defendLose:complete: @/link 或
 *  @link -connectWithHost:port:defendLose:complete: @/link 中设置值，在下一次设置值前，其值不变
 */
@property (nonatomic, assign, readonly) BOOL isFormRecovery;


/*********************************** Wifi Ble 公 有 函 数 ***********************************/
#pragma mark -- Wifi Ble 公 有 函 数
/*!
 *  @discussion 停止扫描
 */
- (void)stopScan;

/*!
 *  @discussion 打印机状态
 *
 *  @param status 打印机状态任务发送完成.传 nil 且未调用 -disconnect 时会调用上一次定义的回调
 *  @code
 *      // 状态位信息
 *      byte[7]   // 正在打印中
 *      byte[6]   // 打印途中出错
 *      byte[5]   // 打印完成
 *      byte[4]   // 打印机缓存区溢出
 *      byte[3]   // 切刀故障
 *      byte[2]   // 上盖打开
 *      byte[1]   // 过热
 *      byte[0]   // 纸尽
 *  @endcode
 */
- (void)statusTask:(nullable JMStatus)status;

/*!
 *  @discussion 清除打印机缓存
 *
 *  @param completed 清除缓存任务发送完成.传 nil 且未调用 -disconnect 时会调用上一次定义的回调
 */
- (void)clearBufferTask:(nullable JMComplete)completed;

/*!
 *  @discussion 发送打印开始任务
 *
 *  @param completed 打印开始任务发送完成.传 nil 且未调用 -disconnect 时会调用上一次定义的回调
 */
- (void)startTask:(nullable JMComplete)completed;

/*!
 *  @discussion 发送打印数据
 *
 *  @param  data 打印数据,为 nil 时是续发
 *  @remark 非防丢单打印时 data 取值 (0, 512]bytes，喷墨打印机或防丢单打印 data 取值 (0, ...)bytes
 *  @param  completed 打印数据发送完成(非防丢单连接不回调).如果当前为防丢单连接传 nil 且未调用 -disconnect 时会调用上一次定义的回调
 */
- (void)sendTask:(nullable NSData *)data
       completed:(nullable JMComplete)completed;

/*!
 *  @discussion 发送结束任务
 *
 *  @param completed 打印结束任务发送完成.传 nil 且未调用 -disconnect 时会调用上一次定义的回调
 */
- (void)finishTask:(nullable JMComplete)completed;

/*!
 *  @discussion 断开连接并清除回调与变量值
 */
- (void)disconnect;

/*!
 *  @discussion 将图片转换成打印数据
 *
 *  @param img  图片
 *  @param type 打印机类型
 *  @code
 *      JMNone = 0 // 打印机类型不明
 *      JMNeedle9  // 9 针打印机
 *      JMNeedel24 // 24 针打印机
 *      JMThermal  // 热敏打印机
 *  @endcode
 *
 *  @return 图片打印数据
 */
- (nullable NSData *)transformImageToData:(nonnull UIImage *)img
                                     type:(JMPrinterType)type;

/*!
 *  @discussion 将 HTML 字符串转换成打印数据
 *
 *  @param htmlData  HTML 二进制
 *  @param type      打印机类型
 *  @param completed 转换完成
 */
- (void)transformHtmlToData:(nonnull NSData *)htmlData
                       type:(JMPrinterType)type
                  completed:(nonnull JMTransformCompleted)completed;

/*!
 *  @discussion 将 JSON 转换成打印数据
 *
 *  @param json      JSON 数据
 *  @param type      打印机类型
 *  @param completed 转换完成
 */
- (void)transformJsonToData:(nonnull NSData *)json
                       type:(JMPrinterType)type
                  completed:(nonnull JMTransformCompleted)completed;
@end











