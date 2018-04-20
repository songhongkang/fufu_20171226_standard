
//
//  CDVHKBleScan.m
//  服服
//
//  Created by 宋宏康 on 2017/9/7.
//
//

#import "CDVHKBleScan.h"
#import "HK_BlueTooth.h"
#import "NSString+Tools.h"
#import "NSTimer+Task.h"
#import "Constan.h"


@interface CDVHKBleScan()
/**  bleScanID */
@property (nonatomic, strong) NSString *bleScanID;
/** 命令 */
@property (nonatomic, strong) CDVPluginResult *pluginResult;
/** 配置wifiID */
@property (nonatomic, strong) NSString *setwifiConfigID;
/** 配置WiFiResult */
@property (nonatomic, strong) CDVPluginResult *setwifiPluginResult;
/**配置checkBleID*/
@property (nonatomic, strong) NSString *checkBleID;
/** 蓝牙开关Result */
@property (nonatomic, strong) CDVPluginResult *checkPluginResult;
/** 蓝牙一对一连接的ID */
@property (nonatomic, strong) NSString *bleConnectID;
/** 蓝牙一对一连接的Result */
@property (nonatomic, strong) CDVPluginResult *bleConnectResult;
/** 扫描接口带SN的ID */
@property (nonatomic, strong) NSString *bleScanWithSnID;
/** 扫描接口带SN的Result */
@property (nonatomic, strong) CDVPluginResult *bleScanWithSnPulginResult;
@end

@implementation CDVHKBleScan
// 蓝牙扫描
- (void)bleScan:(CDVInvokedUrlCommand *)command
{
    
    [HK_BlueTooth hk_shareManager].h5SendeSN = nil;
    [HK_BlueTooth hk_shareManager].blueState = 99;

    _bleScanID  = command.callbackId;
    HK_BlueTooth *blueToothManager = [HK_BlueTooth hk_shareManager];
    // 2017 10~26
    blueToothManager.isConnect = NO;
    
    blueToothManager.h5OpenBlueScan = YES;
    [blueToothManager hk_startBlueTools];
    if (blueToothManager.successblock) {
        blueToothManager.successblock();
    }
    [blueToothManager addCommondOvertime:30 withType:BlePluginTypeScan];
    self.pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:self.pluginResult callbackId:_bleScanID];
}

// 设置WiFi
- (void)setWifiConfig:(CDVInvokedUrlCommand *)command
{
    _setwifiConfigID = command.callbackId;
    NSDictionary *dict = [command argumentAtIndex:0];
    NSString *str = [NSString stringWithFormat:@"SSID=%@;BSSID=%@;KEY=%@;",[dict[@"ssid"] base64EncodedString],dict[@"bssid"],[dict[@"passWord"] base64EncodedString]];
    NSLog(@"setWifiConfig_str:%@",str);
    NSString *setwifiPluginString = [NSString stringWithFormat:@"HEAD=%ld;%@",(unsigned long)str.length,str];
    
    // 1.想蓝牙发送设置WiFi的指令
    [[HK_BlueTooth hk_shareManager] sendDataTocharacteristic:setwifiPluginString];
    // 2.添加倒计时
    [[HK_BlueTooth  hk_shareManager] addCommondOvertime:30 withType:BlePluginTypeSetWifiConfig];
}

// 取消蓝牙配置（连接、扫描）
- (void)cancelBleConfig:(CDVInvokedUrlCommand *)command
{
    //1.取消蓝牙扫描
    [[HK_BlueTooth hk_shareManager].manager stopScan];
    //5.取消定时器
    [HK_BlueTooth hk_shareManager].handleCancleBleConnect = YES;
    if ([HK_BlueTooth hk_shareManager].successblock) {
        [HK_BlueTooth hk_shareManager].successblock();
    }
    //2.判断是否有蓝牙外设
    if (![HK_BlueTooth hk_shareManager].peripheral) return;
    //3.发送蓝牙取消一对一连接指令
    [[HK_BlueTooth hk_shareManager] sendDataTocharacteristic:@"HEAD=15;REQ=DISCONNECT;"];
    //4.取消蓝牙一对一连接
    [[HK_BlueTooth hk_shareManager].manager cancelPeripheralConnection:[HK_BlueTooth hk_shareManager].peripheral];
}

// 监测蓝牙权限
- (void)checkBluetooth:(CDVInvokedUrlCommand *)command
{
    _checkBleID = command.callbackId;
    
    HK_BlueTooth *blueToothManager = [HK_BlueTooth hk_shareManager];
    [blueToothManager hk_startBlueTools];
    blueToothManager.h5OpenBlueScan = NO;
    
    self.checkPluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[HK_BlueTooth hk_shareManager].bleState];
    [self.commandDelegate sendPluginResult:self.checkPluginResult callbackId:self.checkBleID];
}

// 蓝牙一对一连接
- (void)checkOneToOneConnect:(CDVInvokedUrlCommand *)command
{    
    _bleConnectID = command.callbackId;
    self.bleConnectResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[HK_BlueTooth hk_shareManager].bleConnect];
    [self.commandDelegate sendPluginResult:self.bleConnectResult callbackId:_bleConnectID];
}

// h5调用蓝牙扫描接口带SN的
- (void)bleScanWithSn:(CDVInvokedUrlCommand *)command
{
    NSDictionary *dic = [command argumentAtIndex:0];
    [HK_BlueTooth hk_shareManager].h5SendeSN = [dic valueForKey:@"sn"];
    [HK_BlueTooth hk_shareManager].blueState = 0;

    _bleScanWithSnID  = command.callbackId;
    HK_BlueTooth *blueToothManager = [HK_BlueTooth hk_shareManager];
    blueToothManager.h5OpenBlueScan = YES;
    [blueToothManager hk_startBlueTools];
    if (blueToothManager.successblock) {
        blueToothManager.successblock();
    }
    [blueToothManager addCommondOvertime:30 withType:BlePluginTypeScanWithSn];
    self.bleScanWithSnPulginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:self.bleScanWithSnPulginResult callbackId:_bleScanWithSnID];
}

// 将原有服务器序列号删除
- (void)deleteSnSuccess:(CDVInvokedUrlCommand *)command
{
    [[HK_BlueTooth hk_shareManager] sendDataTocharacteristic:@"HEAD=18;REQ=UNBIND-UPDATE;"];
    //延时一秒
    [[HK_BlueTooth hk_shareManager] addCommondOvertime:1 withType:BlePluginTypeDelaySendQueryNetwork];
}

// 有线网络设置
- (void)setWiredNetworkConfig:(CDVInvokedUrlCommand *)command
{
    NSDictionary *dict = [command argumentAtIndex:0];
    
    if ([dict[@"DHCP"] integerValue] == 1) {
        [[HK_BlueTooth hk_shareManager] sendDataTocharacteristic:@"HEAD=8;DHCP=ON;"];
        [[HK_BlueTooth hk_shareManager] addCommondOvertime:30 withType:BlePluginTypeSetWifiConfig];
    }else{
        
        NSString *str = [NSString stringWithFormat:@"DHCP=OFF;IP=%@;MASK=%@;GW=%@;DNS=%@;",dict[@"IP"],dict[@"MASK"],dict[@"GW"],dict[@"DNS"]];
        NSString *strCommand = [NSString stringWithFormat:@"HEAD=%lu;%@",(unsigned long)str.length,str];
        [[HK_BlueTooth hk_shareManager] sendDataTocharacteristic:strCommand];
        [[HK_BlueTooth hk_shareManager] addCommondOvertime:30 withType:BlePluginTypeSetWifiConfig];
    }
}

@end
