//
//  CDVHKScanner.m
//  服服
//
//  Created by 宋宏康 on 2017/8/25.
//
//

#import "CDVHKScanner.h"
#import "VC_Scan.h"
#import "CDVAutosignIn.h"
#import "HK_BlueTooth.h"
#import "Constan.h"

@interface CDVHKScanner () <
                            ScanVCDelegate,HK_BlueToothDelegate>
/** qrscanID */
@property (nonatomic,strong) NSString *qrScanID;
/** 命令返回结果 */
@property (nonatomic, strong)CDVPluginResult *result;
/** 蓝牙扫描的ID */
@property (nonatomic,strong) NSString *blueToothScanID;
/** 蓝牙返回的命令结果 */
@property (nonatomic, strong)CDVPluginResult *blueToothResult;
@end

@implementation CDVHKScanner
#pragma mark - H5调用方法

-(void)pluginInitialize{
    
//    [hk_blueToothState shareManger_BlueTooth];
}

- (void)scan:(CDVInvokedUrlCommand *)command
{
    _qrScanID = [command callbackId];
    VC_Scan *scan = [[VC_Scan alloc] init];
    scan.delegate = self;
    [self.viewController.navigationController pushViewController:scan animated:YES];
}

- (void)blueToothScan:(CDVInvokedUrlCommand *)command
{
    _blueToothScanID = command.callbackId;
    HK_BlueTooth *blueToothManager = [HK_BlueTooth hk_shareManager];
    [blueToothManager hk_startBlueTools];
    blueToothManager.delegate = self;
}

- (void)close:(CDVInvokedUrlCommand *)command
{
    NSLog(@"colse");
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

- (void)test:(CDVInvokedUrlCommand *)command
{
//    [[HK_BlueTooth hk_shareManager] teststring];
}

#pragma mark - ScanVCDelegate
// 扫描成功
- (void)hk_ScanSuccess:(NSString *)result
{
    self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:self.result callbackId:self.qrScanID];
}

// 扫描失败
- (void)hk_ScanFaild
{
    self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:self.result callbackId:self.qrScanID];
}

#pragma mark  - HK_BlueToothDelegate
- (void)hk_blueToothConnectStatus:(NSInteger)ConnectStatus                withBlueToothAdvertise:(NSInteger)status
                       withSnCode:(NSString *)snCode
{
    
}

/**
 蓝牙连接成功
 */
- (void) hk_blueConnectSuccess
{
    self.blueToothResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:self.blueToothResult callbackId:_blueToothScanID];
}
@end
