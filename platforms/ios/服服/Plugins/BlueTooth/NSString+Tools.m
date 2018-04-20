//
//  NSString+Tools.m
//  服服
//
//  Created by 宋宏康 on 2017/7/2.
//
//

#import "NSString+Tools.h"
#import "CDVReachability.h"
#import "Constan.h"


@implementation NSString (Tools)
+ (NSString*)getCurrentTimes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    //    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}

+ (NSString*)getCurrentTimesFormatter1
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    //    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}
+ (NSString *)getCurrentFormatterTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYMMddHHmmss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    //    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}

+ (int)shijianCha:(NSString *)firstTime withSecondTime:(NSString *)secondTime
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //    NSString * dateString1 = @"2016-03-23 09:00"
    NSString * dateString1 = firstTime;
    NSString * dateString2 = secondTime;
    NSDate * date1 = [df dateFromString:dateString1];
    NSDate * date2 = [df dateFromString:dateString2];
    NSTimeInterval time = [date2 timeIntervalSinceDate:date1]; //date1是前一个时间(早)，date2是后一个时间(晚)
    return time;
}

#pragma mark - 判断当前网络情况
+ (BOOL)determineNetworkConditions
{
    CDVReachability *reach = [CDVReachability reachabilityWithHostName:@"www.apple.com"];
    //判断当前的网络状态
    if ([reach currentReachabilityStatus] == ReachableViaWWAN ||
        [reach currentReachabilityStatus] == ReachableViaWiFi) {
        return YES;
    }else{
        return NO;
    }
    
}

+ (NSString *)getTime:(NSString *)timer
{
    //    16进制数－>Byte数组
    ///// 将16进制数据转化成Byte 数组
    NSString *hexString = timer; //16进制字符串
    NSMutableString *stringData = [[NSMutableString alloc] init];
    ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length];++i)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;

        [stringData appendString:[NSString stringWithFormat:@"%0.2d",int_ch]];
    }
    
    
    NSLog(@"newData=%@",stringData);
    return stringData;
}



/**
 C语言的字符串转成iOS的十六进制字符串
 
 @param testfinal <#testfinal description#>
 @return <#return value description#>
 */
+ (NSString *)getIosHexByCstring:(char [])testfinal
{
    Byte *testByte1 = (Byte *)testfinal;
    NSString *hexStr1=@"";
    
    for(int i=0;i<19;i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",testByte1[i]&0xff]; ///16进制数
        if([newHexStr length]==1)
            hexStr1 = [NSString stringWithFormat:@"%@0%@",hexStr1,newHexStr];
        else
            hexStr1 = [NSString stringWithFormat:@"%@%@",hexStr1,newHexStr];
    }
//    NSLog(@"hexStr---->%@",hexStr1);
    return hexStr1;
}


// 16进制的字符串转换成data
+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

//获取当前时间戳
+ (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}


+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
}

- (NSString *)base64EncodedString;
{
//    return self;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *str = [data base64EncodedStringWithOptions:0];
    
    if (str) {
        return str;
    }else{
        return @"";
    }
}

- (NSString *)base64DecodedString
{
//    return self;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self options:0];
    
    NSString *str =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (str) {
        return str;
    }else{
        return @"";
    }
}

/**
 十六进制转换为二进制
 
 @param hex 十六进制数
 @return 二进制数
 */
+ (NSString *)getBinaryByHex:(NSString *)hex
{
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}


@end
