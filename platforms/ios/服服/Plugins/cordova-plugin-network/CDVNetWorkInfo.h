//
//  CDVNetWorkInfo.h
//  服服
//
//  Created by shangzh on 16/6/18.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface CDVNetWorkInfo : CDVPlugin
/**
 wifi信息

 @param command command description
 */
- (void)wifiInfo:(CDVInvokedUrlCommand*)command;
/**
 wifi列表

 @param command command description
 */
- (void)wifiList:(CDVInvokedUrlCommand *)command;
@end

