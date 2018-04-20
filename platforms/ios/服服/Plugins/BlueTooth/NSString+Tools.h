//
//  NSString+Tools.h
//  服服
//
//  Created by 宋宏康 on 2017/7/2.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Tools)
///  获取当前时间 YYYY-MM-dd HH:mm:ss
+ (NSString*)getCurrentTimes;
/// 获取当前时间 2017-08-23-15-37-24
+ (NSString*)getCurrentTimesFormatter1;
// 获取当前时间 yyyymmddhhmmss
+ (NSString *)getCurrentFormatterTime;
///  时间差
+ (int)shijianCha:(NSString *)firstTime withSecondTime:(NSString *)secondTime;
// 判断网络情况
+ (BOOL)determineNetworkConditions;
// 工具方法  16进制数－>Byte数组
+ (NSString *)getTime:(NSString *)timer;
/**
 C语言的字符串转成iOS的十六进制字符串
 
 @param testfinal <#testfinal description#>
 @return <#return value description#>
 */
+ (NSString *)getIosHexByCstring:(char [])testfinal;
// 16进制的字符串转换成data
+ (NSData *)convertHexStrToData:(NSString *)str;

//获取当前时间戳
+ (NSString *)currentTimeStr;
//字典转json格式字符串：
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
/**
 字符串转换成json
 
 @param jsonString <#jsonString description#>
 @return <#return value description#>
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/**
 *  转换为Base64编码
 */
- (NSString *)base64EncodedString;
/**
 *  将Base64编码还原
 */
- (NSString *)base64DecodedString;
/**
 十六进制转2进制

 @param hex <#hex description#>
 @return <#return value description#>
 */
+ (NSString *)getBinaryByHex:(NSString *)hex;
@end
