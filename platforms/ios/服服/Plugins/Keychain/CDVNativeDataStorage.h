//
//  CDVNativeDataStorage.h
//  服服
//
//  Created by 宋宏康 on 2017/10/30.
//

#import <Cordova/CDVPlugin.h>

@interface CDVNativeDataStorage : CDVPlugin
/**
 根据指定KEY获取缓存在原生的字符串；

 @param command command description
 */
- (void)getLocalStorageVal:(CDVInvokedUrlCommand *)command;

/**
 <#Description#>

 @param command <#command description#>
 */
- (void)setLocalStorageVal:(CDVInvokedUrlCommand *)command;

@end
