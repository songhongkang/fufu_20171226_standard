//
//  CDVNetWorkInfo.m
//  服服
//
//  Created by shangzh on 16/6/18.
//
//

#import "CDVNetWorkInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CDVReachability.h"
#import "HK_BlueTooth.h"
#import "NSString+Tools.h"

@interface CDVNetWorkInfo()

@property (nonatomic,strong) CDVPluginResult *result;

@property (nonatomic,copy) NSString *callID;

/** wifiListCallID */
@property (nonatomic,strong) NSString *wifiListCallID;
/** reslut wifiList */
@property (nonatomic,strong) CDVPluginResult *wifiListResult;

@end

@implementation CDVNetWorkInfo

- (void)wifiList:(CDVInvokedUrlCommand *)command
{
    self.wifiListCallID = command.callbackId;
    __weak typeof(self)weakSelf = self;
    
    //1.发送蓝牙考勤机获取WiFiList的指令
    [[HK_BlueTooth hk_shareManager] sendDataTocharacteristic:@"HEAD=14;WIFI=LISTINFO;"];
    //2.发送倒计时指令
    [[HK_BlueTooth hk_shareManager] addCommondOvertime:30 withType:BlePluginTypeGetWifiInfor];
    
    [HK_BlueTooth hk_shareManager].getWifiListSuccess = YES;
    [HK_BlueTooth hk_shareManager].wifiAllData = @"";
    [HK_BlueTooth hk_shareManager].wifiData = [[NSMutableArray alloc] init];
    
    [HK_BlueTooth hk_shareManager].wifiListblock = ^(NSString *str) {
        _wifiListResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:str];
        
        //        NSLog(@"str:%@",str);
        [weakSelf.commandDelegate sendPluginResult:_wifiListResult callbackId:_wifiListCallID];
    };
}

- (void)wifiInfo:(CDVInvokedUrlCommand *)command {
    
    _callID = command.callbackId;
    
    NSString *netState = nil;
    CDVReachability *reach = [CDVReachability reachabilityWithHostName:@"www.hcios.com"];
    //判断当前的网络状态
    switch ([reach currentReachabilityStatus]) {
        case ReachableViaWWAN:
        netState = @"2G/3G/4G";
        break;
        case ReachableViaWiFi:
        netState = @"wifi";
        break;
        default:
        netState = @"nonetwork";
        break;
    }
    
    NSArray *array = [self getWifiNameAndMac];
    NSDictionary *dic = nil;
    if (array.count == 2) {
        dic = @{@"wifiName":array[0],@"mac":[self autoCompleteWIFIInfor:array[1]],@"state":@"1"};
    } else {
        if ([netState isEqualToString:@"wifi"]) {
            dic = @{@"wifiName":@"",@"mac":@"",@"state":@"-1"};
        } else {
            dic = @{@"wifiName":@"",@"mac":@"",@"state":@"0"};
        }
    }
    
#ifdef DEBUG
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[dic description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
#else
    
#endif
    
    self.result =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:self.result callbackId:self.callID];
    
}

- (NSArray *)getWifiNameAndMac {
    NSString *wifiName = @"";
    NSString *mac = @"";
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            mac = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeyBSSID];
            CFRelease(dictRef);
            
        }
        
    }
    if (wifiInterfaces != nil) {
        CFRelease(wifiInterfaces);
        return @[wifiName,mac];
    } else {
        return nil;
    }
    
}

- (NSString *)autoCompleteWIFIInfor:(NSString *)infor
{
    NSMutableString *completeStr = [[NSMutableString alloc] init];
    NSArray *array = [infor componentsSeparatedByString:@":"];
    
    for (int i = 0 ; i<array.count; i++) {
        if ([array[i] length]  != 2 && !(i == (array.count - 1))) {
            [completeStr appendString:[NSString stringWithFormat:@"0%@:",array[i]]];
        }else if ([array[i] length] != 2 && (i == (array.count - 1))){
            [completeStr appendString:[NSString stringWithFormat:@"0%@",array[i]]];
        }else if ([array[i] length] == 2 && !(i == (array.count - 1))){
            [completeStr appendString:[NSString stringWithFormat:@"%@:",array[i]]];
        }else{
            [completeStr appendString:[NSString stringWithFormat:@"%@",array[i]]];
        }
    }
    return completeStr;
}


@end
