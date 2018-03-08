//
//  JMEnumBlock.h
//  JMWireless
//
//  Created by admin on 17/3/7.
//  Copyright © 2017年 jolimark. All rights reserved.
//

#ifndef JMEnumBlock_h
#define JMEnumBlock_h
#import <CoreBluetooth/CoreBluetooth.h>

/***************************************** 枚 举 定 义 *****************************************/
#pragma mark -- 枚 举 定 义
/**
 *  @enum JMTask
 *  @discussion 当前所处任务流程
 *  @code
 *      JMNoneTask = 0, // 无任务
 *      JMConnectTask,  // 连接任务
 *      JMStatusTask,   // 查询状态任务
 *      JMStartTask,    // 开始任务
 *      JMSendTask,     // 发送数据任务
 *      JMFinishTask,   // 打印完成任务
 *      JMClearTask     // 清除打印机缓存
 *  @endcode
 */
typedef enum {
    JMNoneTask = 0, // 无任务
    JMConnectTask,  // 连接任务
    JMStatusTask,   // 查询状态任务
    JMStartTask,    // 开始任务
    JMSendTask,     // 发送数据任务
    JMFinishTask,   // 打印完成任务
    JMClearTask     // 清除打印机缓存
}JMTask;

/*!
 *  @enum JMPrinterType
 *  @discussion 打印机类型
 *  @code
 *      JMNone = 0 // 打印机类型不明
 *      JMNeedle9  // 9 针打印机
 *      JMNeedel24 // 24 针打印机
 *      JMThermal  // 热敏打印机
 *      JMInkjet   // 喷墨打印机
 *  @endcode
 */
typedef enum {
    JMNone = 0,  // 打印机类型不明
    JMNeedle9,   // 9 针打印机
    JMNeedel24,  // 24 针打印机
    JMThermal,   // 热敏打印机
    JMInkjet     // 喷墨打印机
}JMPrinterType;



/***************************************** 回 调 定 义 *****************************************/
#pragma mark -- 回 调 定 义
/*!
 *  @typedef JMComplete
 *  @discussion 完成回调
 *
 *  @param error 错误信息
 */
typedef void(^JMComplete)(NSError * _Nullable error);

/*!
 *  @typedef JMStatus
 *  打印机状态
 *
 *  @param error  错误信息
 *  @param status 状态数据（只有一个字节）
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
typedef void(^JMStatus)(NSError * _Nullable error,
                        NSData  * _Nullable status);
/*!
 *  @typedef JMDiscoverWifi
 *  @discussion 发现外设回调
 *
 *  @param error      错误信息
 *  @param macStr     mac 地址
 *  @param ipStr      ip 地址
 *  @param subnetMask 子网掩码
 *  @param otherDic   其它信息
 */
typedef void(^JMDiscoverWifi)(NSError      * _Nullable error,
                              NSString     * _Nullable macStr,
                              NSString     * _Nullable ipStr,
                              NSString     * _Nullable subnetMask,
                              NSDictionary * _Nullable otherDic);
/*!
 *  @typedef JMDiscoverBle
 *  @discussion 发现外设
 *
 *  @param error             错误信息
 *  @param peripheral        外设
 *  @param advertisementData 广播信息
 *  @param RSSI              信号强度
 */
typedef void(^JMDiscoverBle)(NSError                     * _Nullable error,
                             CBPeripheral                * _Nullable peripheral,
                             NSDictionary<NSString *,id> * _Nullable advertisementData,
                             NSNumber                    * _Nullable RSSI);
/*!
 *  @typedef JMTransformCompleted
 *  @discussion 数据转换完成回调
 *
 *  @param error 转换错误信息
 *  @param data  打印数据
 */
typedef void(^JMTransformCompleted)(NSError * _Nullable error,
                                    NSData  * _Nullable data);
#endif /* JMEnumBlock_h */










