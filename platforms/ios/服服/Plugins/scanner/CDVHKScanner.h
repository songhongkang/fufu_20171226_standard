//
//  CDVHKScanner.h
//  服服
//
//  Created by 宋宏康 on 2017/8/25.
//
//

#import <Cordova/CDVPlugin.h>

@interface CDVHKScanner : CDVPlugin

/**
 二维码扫描

 @param command command description
 */
- (void)scan:(CDVInvokedUrlCommand *)command;

/**
 蓝牙扫描

 @param command command description
 */
- (void)blueToothScan:(CDVInvokedUrlCommand *)command;

/**
 二维码扫描关闭

 @param command command description
 */
- (void)close:(CDVInvokedUrlCommand *)command;

/**
 测试

 @param command command description
 */
- (void)test:(CDVInvokedUrlCommand *)command;
@end
