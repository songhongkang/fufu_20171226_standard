//
//  CDVHKBleScan.h
//  服服
//
//  Created by 宋宏康 on 2017/9/7.
//
//


#import <Cordova/CDVPlugin.h>

@interface CDVHKBleScan : CDVPlugin

/**
 h5调用蓝牙扫描接口

 @param command command description
 */
- (void)bleScan:(CDVInvokedUrlCommand *)command;

/**
 H5设置wifi配置

 @param command command description
 */
- (void)setWifiConfig:(CDVInvokedUrlCommand *)command;
/**
 取消蓝牙配置

 @param command command description
 */
- (void)cancelBleConfig:(CDVInvokedUrlCommand *)command;
/**
 监测蓝牙权限
 
 @param command command description
 */
- (void)checkBluetooth:(CDVInvokedUrlCommand *)command;
/**
 检测蓝牙是否一对一连接

 @param command command description
 */
- (void)checkOneToOneConnect:(CDVInvokedUrlCommand *)command;
/**
 h5调用蓝牙扫描接口带SN的

 @param command command description
 */
- (void)bleScanWithSn:(CDVInvokedUrlCommand *)command;
/**
 将原有服务器序列号删除

 @param command command description
 */
- (void)deleteSnSuccess:(CDVInvokedUrlCommand *)command;

/**
 有线网络设置

 @param command command description
 */
- (void)setWiredNetworkConfig:(CDVInvokedUrlCommand *)command;

@end



