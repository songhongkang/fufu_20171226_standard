//
//  CDVAutosignIn.m
//  服服
//
//  Created by 宋宏康 on 2017/6/21.
//
//
#import "CDVAutosignIn.h"
#import "JPUSHService.h"
#import "JPushPlugin.h"
#import "JPushDefine.h"
#import "BabyBluetooth.h"
#import "CDVReachability.h"
#import "AppDelegate.h"
#import "NSString+Tools.h"
#import "CDVConnection.h"
#include "Des.h"
#import "HK_BlueTooth.h"
#import "Constan.h"


#define BEACONUUID @"f59edb6a-f399-4c80-a759-d059bf84c96d"

@interface CDVAutosignIn ()<CLLocationManagerDelegate,CBCentralManagerDelegate, CBPeripheralDelegate,CBPeripheralDelegate,CBCentralManagerDelegate>

// 定位
@property (nonatomic,strong) CLLocationManager *LocationManager;


@end

@implementation CDVAutosignIn

static CDVAutosignIn *_instance;
#pragma mark - init
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    }
    return _instance;
}

// 实例化单利对象
+ (CDVAutosignIn *)sharedInstance {
    return [[self alloc] init];
}

#pragma mark - h5
// H5调用此方法，设置SN
- (void)setSnList:(CDVInvokedUrlCommand *)command
{
    NSString *sound = [command argumentAtIndex:0];
    NSLog(@"sound---->%@",sound);
    // 把获取的参数保存到Plist
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sound forKey:@"snCode"];
    [defaults synchronize];
    [self hk_startBle];
    
    
//    if (![CDVAutosignIn sharedInstance].centralManager) {
//        
//        NSDictionary *dic = @{
//                              CBCentralManagerOptionShowPowerAlertKey : @NO
//                              };
//        [CDVAutosignIn sharedInstance].centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:dic];
//    }
    
}

// 登录成功,h5会调用此方法
- (void)loginSuccess:(CDVInvokedUrlCommand *)command
{
    [CDVAutosignIn sharedInstance].isRegionSN = nil;
}

/// h5在没有网络和有网络的情况下，都会调用此方法，app启动就要调用此方法
- (void)initBlePlugin:(CDVInvokedUrlCommand *)command
{
    [self hk_startBle];
}

// 暂停蓝牙打卡
- (void)pauseSignIn:(CDVInvokedUrlCommand *)command
{
    //1.停止蓝牙扫描
    [_centralManager stopScan];
    _centralManager = nil;
    //2.定时器停止扫描
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    //3.把标志位设置成YES
    _closeState = @"1";
}

// 重开蓝牙打卡
- (void)reopenSignIn:(CDVInvokedUrlCommand *)command
{
    //4.把标志位设置成NO
    _closeState = @"2";
    //5.把定时器标志位设置成YES
    _isTimerOff = NO;
    //6.如果蓝牙对象被销毁，就要重新生成
    if (![CDVAutosignIn sharedInstance].centralManager) {
        NSDictionary *dic = @{
                              CBCentralManagerOptionShowPowerAlertKey : @NO
                              };
        [CDVAutosignIn sharedInstance].centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:dic];
    }else{
        //1.先停止蓝牙扫描
        [_centralManager stopScan];
        //2.打开蓝牙扫描
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        //3.开启定时器
        [self createCountDown];
    }
}

- (void)hk_startBle
{
    if (![CDVAutosignIn sharedInstance].centralManager) {
        NSDictionary *dic = @{
                              CBCentralManagerOptionShowPowerAlertKey : @NO
                              };
        [CDVAutosignIn sharedInstance].centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:dic];
    }else{
        //1.先停止蓝牙扫描
        [_centralManager stopScan];
        //2.打开蓝牙扫描
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}
    
    
#pragma mark - Ibeacon
// 初始化Ibeacon
- (void)initIbeacon
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BEACONUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"teste"];
    self.LocationManager = [[CLLocationManager alloc] init];
    self.LocationManager.delegate = self;
    [self.LocationManager requestStateForRegion:self.beaconRegion];
    [self.LocationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.LocationManager startMonitoringForRegion:self.beaconRegion];
    
    if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        if ([self.LocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.LocationManager requestAlwaysAuthorization];
        }
    }
}

#pragma mark - help

- (void)createCountDown
{
    [self countDownWithTime:60 countDownBlock:^(int timeLeft) {
        NSLog(@"createCountDown---->%d",timeLeft);

            if ([CDVAutosignIn sharedInstance].isRegionSN  ) {
                
                int second = [NSString shijianCha:[CDVAutosignIn sharedInstance].currentData withSecondTime:[NSString  getCurrentTimes]];
                second =  abs(second);
                // 备注 参数改成60秒
                if (second >= 60 ) {
//                    [JPushPlugin monitorBlueInRegion:[CDVAutosignIn sharedInstance].isRegionSN withInside:[CDVAutosignIn sharedInstance].blueToothReturnTime];
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString getCurrentFormatterTime] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                    [alertView show];
                    [JPushPlugin monitorBlueInRegion:[CDVAutosignIn sharedInstance].isRegionSN withInside:[NSString getCurrentFormatterTime]];
                    [CDVAutosignIn sharedInstance].isRegionSN = nil;
                }
            }
    }];    
}

//定时器
- (void)countDownWithTime:(int)time
           countDownBlock:(void (^)(int timeLeft))countDownBlock
{
    __block int timeout = time; //倒计时时间
    //全局队列    默认优先级
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if ([CDVAutosignIn sharedInstance].timer) {
        dispatch_source_cancel([CDVAutosignIn sharedInstance].timer);
    }
    //定时器模式  事件源
    [CDVAutosignIn sharedInstance].timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    //NSEC_PER_SEC是秒，＊1是每秒
    dispatch_source_set_timer([CDVAutosignIn sharedInstance].timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    //设置响应dispatch源事件的block，在dispatch源指定的队列上运行
    dispatch_source_set_event_handler([CDVAutosignIn sharedInstance].timer, ^{        
            dispatch_async(dispatch_get_main_queue(), ^{
                timeout--;
                if (countDownBlock) {
                    countDownBlock(timeout);
                }
            });
//        }
    });
    dispatch_resume([CDVAutosignIn sharedInstance].timer);
}

#pragma mark - Ble4.0
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStatePoweredOn:
        {
            NSLog(@">>>>>>>11手机蓝牙开启成功");
            [HK_BlueTooth hk_shareManager].bleState = 1;
            [CDVAutosignIn sharedInstance].isBleOff = YES;
             int second = [NSString shijianCha:[CDVAutosignIn sharedInstance].currentData withSecondTime:[NSString  getCurrentTimes]];
            
            NSLog(@"currentData------->%@\n,getCurrentTimes----->%@\n,second----->%d\n",[CDVAutosignIn sharedInstance].currentData,[NSString getCurrentTimes],second);
            
            if (second > 60 && [CDVAutosignIn sharedInstance].isRegionSN) {
                [CDVAutosignIn sharedInstance].isRegionSN = nil;
                // 为什么设置匹配成功的时间currentData
                // 主要是程序还要走 applicationDidBecomeActive
                // 其实不重置currentData也可以把。isRegionSN 已经被重置成nil了
                [CDVAutosignIn sharedInstance].currentData = [NSString getCurrentTimes];
            }
//            * @"0" 表示没有任何操作
//            * @"1" 表示暂停蓝牙打卡
            if (![CDVAutosignIn sharedInstance].isTimerOff)
            {
                if (![CDVAutosignIn sharedInstance].closeState ) {
                    [self createCountDown];
                }
                if ([[CDVAutosignIn sharedInstance].closeState  integerValue] == 2) {
                    [self createCountDown];
                }
            }
            //1.colse是否关闭状态
            if (!_closeState || [_closeState isEqualToString:@"2"]) {
                [[CDVAutosignIn sharedInstance].centralManager stopScan];
                [[CDVAutosignIn sharedInstance].centralManager scanForPeripheralsWithServices:nil options:nil];
            }
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@">>>>>>>手机蓝牙关闭");
            [HK_BlueTooth hk_shareManager].bleState = 0;
            [CDVAutosignIn sharedInstance].isBleOff = NO;
            if ([CDVAutosignIn sharedInstance].timer) {
                dispatch_source_cancel([CDVAutosignIn sharedInstance].timer);
            }
        }
            break;
        default:
            break;
    }
}

// 查到外设后，停止扫描，连接设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"考勤机蓝牙打开开起来了.....");
    NSLog(@"ManufacturerData---->%@",advertisementData);
    // 判断sn是否大概范围内
    NSData *ManufacturerData;
    if (![advertisementData objectForKey:@"kCBAdvDataManufacturerData"]) {
        ManufacturerData = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    }
    ManufacturerData=[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    
    NSString *hexStr= [BabyToy ConvertDataToHexString:ManufacturerData];
    // 临时得到sn
    NSString *snNeed;
    // 临时得到蓝牙返回的时间
    NSString *blueTime;
    
    if (hexStr.length >= 42) {
        snNeed = [hexStr substringWithRange:NSMakeRange(4, 38)];
        NSData *data =   [self convertHexStrToData:snNeed];
        char *testByte3 = (char *)[data bytes];
        char dest[19] = {0};
        BluetoothGetSNStr(testByte3, 19, dest, 19);
        
        snNeed =  [[self getIosHexByCstring:dest] substringToIndex:26];
        NSLog(@"sn------>%@",snNeed);

        blueTime =  [[self getIosHexByCstring:dest] substringFromIndex:26];
        NSLog(@"blueTime------>%@",blueTime);
        NSLog(@"blueTime------>%@",[self getIosHexByCstring:dest] );

    }else{
        snNeed = @"00";
    }
    
    NSLog(@"snNeed--->%@",snNeed);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strSn =  [defaults objectForKey:@"snCode"];
    NSLog(@"strSn--->%@",strSn);
    if ([strSn isEqualToString:@""]) return;
    NSArray *arraySn = [strSn componentsSeparatedByString:@","];
//    NSMutableArray *arrayStringSN = [NSMutableArray array];
    snNeed = [BabyToy ConvertHexStringToString:snNeed];
//    for (NSString *string in arraySn) {
//        [arrayStringSN addObject:[BabyToy ConvertStringToHexString:string]];
//    }
//
    
    
    if ([arraySn containsObject:snNeed])
    {
        NSLog(@"=====================start====================");
        NSLog(@"sn:%@",snNeed);
        NSLog(@"time:%@",[NSString getTime:blueTime]);
        NSLog(@"=====================end====================");

        if ( ![CDVAutosignIn sharedInstance].isRegionSN) {
            
            if ([NSString determineNetworkConditions])
            {
                [CDVAutosignIn sharedInstance].currentData = [NSString getCurrentTimes];
                [CDVAutosignIn sharedInstance].isRegionSN = snNeed;
                
                [CDVAutosignIn sharedInstance].blueToothReturnTime = [NSString getTime:blueTime];
                NSLog(@"进入蓝牙范围");
                
                [JPushPlugin monitorBlueInRegion:[CDVAutosignIn sharedInstance].isRegionSN withInside:[CDVAutosignIn sharedInstance].blueToothReturnTime];
                
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[CDVAutosignIn sharedInstance].blueToothReturnTime delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                [alertView show];

            }
        }
        if ([[CDVAutosignIn sharedInstance].isRegionSN isEqualToString:snNeed]) {
            [CDVAutosignIn sharedInstance].currentData = [NSString getCurrentTimes];
        }else{
            
                NSLog(@"_isRegionSNWeak--->%@\n snNeed--->%@",[CDVAutosignIn sharedInstance].isRegionSN,snNeed);
                int second = [NSString shijianCha:[CDVAutosignIn sharedInstance].currentData withSecondTime:[NSString  getCurrentTimes]];
                second =  abs(second); // 处理int类型的取绝对值
                
                NSLog(@"时间差----->%d",second);
                if (second > 60 && [CDVAutosignIn sharedInstance].isRegionSN) {
//                    [JPushPlugin monitorBlueInRegion:[CDVAutosignIn sharedInstance].isRegionSN withInside:[CDVAutosignIn sharedInstance].blueToothReturnTime];
                    
                    [JPushPlugin monitorBlueInRegion:[CDVAutosignIn sharedInstance].isRegionSN withInside:[NSString getCurrentFormatterTime]];
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString getCurrentFormatterTime] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                    [alertView show];

                    [CDVAutosignIn sharedInstance].isRegionSN = nil;
                    
                    
                }
        }
    }else{
           int second = [NSString shijianCha:[CDVAutosignIn sharedInstance].currentData withSecondTime:[NSString  getCurrentTimes]];
            second =  abs(second);
            NSLog(@"时间差----->%d",second);
            if (second > 60 && [CDVAutosignIn sharedInstance].isRegionSN) {
                
                [JPushPlugin monitorBlueInRegion:[CDVAutosignIn sharedInstance].isRegionSN withInside:[CDVAutosignIn sharedInstance].blueToothReturnTime];
                [JPushPlugin monitorBlueInRegion:[CDVAutosignIn sharedInstance].isRegionSN withInside:[NSString getCurrentFormatterTime]];
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString getCurrentFormatterTime] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                [alertView show];
                [CDVAutosignIn sharedInstance].isRegionSN = nil;
            }
    }
}

#pragma mark - IbeaconDeleagte

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{

}

// 进入监听的范围
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"baecon======== 进入");
    if (![CDVAutosignIn sharedInstance].isRegionSN) {
//        [_centralManager stopScan];
//        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"4458"]]  options:nil];
    }
}

// 离开监听的范围
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
        NSLog(@"baecon======== 离开");
//        if ([CDVAutosignIn sharedInstance].isRegionSN) {
//            [JPushPlugin monitorBlueInRegion:[CDVAutosignIn sharedInstance].isRegionSN withInside:NO];
//            [CDVAutosignIn sharedInstance].isRegionSN = nil;
//        }
}

#pragma mark - dealloc
- (void)dealloc
{
    // 取消定时器
    dispatch_source_cancel([CDVAutosignIn sharedInstance].timer);
}

/**
 C语言的字符串转成iOS的十六进制字符串
 
 @param testfinal <#testfinal description#>
 @return <#return value description#>
 */
- (NSString *)getIosHexByCstring:(char [])testfinal
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
- (NSData *)convertHexStrToData:(NSString *)str {
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

@end
