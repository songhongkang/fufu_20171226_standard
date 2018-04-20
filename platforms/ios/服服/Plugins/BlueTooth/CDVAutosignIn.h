//
//  CDVAutosignIn.h
//  服服
//
//  Created by 宋宏康 on 2017/6/21.
//
//

#import <Cordova/CDVPlugin.h>
#import "BabyBluetooth.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface CDVAutosignIn : CDVPlugin
// 实例化单利类
+ (CDVAutosignIn *)sharedInstance;
// 设置SN接口
- (void)setSnList:(CDVInvokedUrlCommand *)command;
// 设置登录成功
- (void)loginSuccess:(CDVInvokedUrlCommand *)command;
// 初始化蓝牙
- (void)initBlePlugin:(CDVInvokedUrlCommand *)command;
// 暂停蓝牙打卡
- (void)pauseSignIn:(CDVInvokedUrlCommand *)command;
// 重开蓝牙打卡
- (void)reopenSignIn:(CDVInvokedUrlCommand *)command;
/// 创建定时器
- (void)countDownWithTime:(int)time
           countDownBlock:(void (^)(int timeLeft))countDownBlock;
/// 创建定时器
- (void)createCountDown;
// 开启蓝牙扫描接口
- (void)hk_startBle;
    
// 保存的当前时间
@property (nonatomic,strong) NSString * currentData;
//保存的SNflag
@property (nonatomic,strong) NSString *isRegionSN;
// 蓝牙返回的时间
@property (nonatomic,strong) NSString *blueToothReturnTime;
// 定时器
@property (nonatomic,strong) dispatch_source_t timer;
// 判断定时器是否开启成功
@property (nonatomic, assign) BOOL isTimerOff;
// 判断蓝牙是否开启成功
@property (nonatomic, assign) BOOL isBleOff;
// ibeaconRegion
@property (nonatomic,strong) CLBeaconRegion *beaconRegion;
// 蓝牙主要类
@property (nonatomic, strong) CBCentralManager *centralManager;

/** h5调用接口，给蓝牙开启和关闭 
 * @"0" 表示没有任何操作
 * @"1" 表示暂停蓝牙打卡
 * @"2" 表示重开蓝牙打卡
 */
@property (nonatomic, strong) NSString *closeState;
/** 是否调用h5 */
@property (nonatomic, getter=is) BOOL band;

@end
