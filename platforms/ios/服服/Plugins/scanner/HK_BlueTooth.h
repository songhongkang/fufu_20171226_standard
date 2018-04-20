//
//  HK_BlueTooth.h
//  服服
//
//  Created by 宋宏康 on 2017/8/25.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSUInteger,BlePluginType){
    BlePluginTypeConnect                        = 1,      // ble 连接
    BlePluginTypeSetTime                        = 2,      // 设置Ble时间
    BlePluginTypeGetWifiInfor                   = 3,      // 获取WiFi列表
    BlePluginTypeSetWifiConfig                  = 4,      // 配置WiFi
    BlePluginTypeDisConnect                     = 5,      // 蓝牙断开连接
    BlePluginTypeScan                           = 6,      // ble 扫描
    BlePluginTypeConnecting                     = 7,      // ble 正在连接中
    BlePluginTypeHavaSerices                    = 8,      // ble 有服务
    BlePluginTypeCofiging                       = 9,      // 考勤机配置中
    BlePluginTypeBindStatus                     = 10,     // 考勤机物理解绑中
    BlePluginTypeDelay                          = 11,     // 考勤机延时发送命令
    BlePluginTypeNetworkWay                     = 12,     // 发送APP查询网络连接方式
    BlePluginTypeDelaySendQueryNetwork          = 13,     // 考勤机延时查询网络发送命令
    BlePluginTypeScanWithSn                     = 14,      // ble 扫描带SN
};

@protocol HK_BlueToothDelegate;

typedef void(^wifiListBlock)(NSString *);

typedef void(^successBlock)(void);

@interface HK_BlueTooth : NSObject
/** 蓝牙状态 */
@property (nonatomic, assign)int bleState;
/** 中心管理者 */
@property (nonatomic, strong) CBCentralManager *manager;
/** 连接到的外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;
/** 蓝牙发送指令的类型 */
@property (nonatomic, assign)BlePluginType blePluginType;
/** wifilistBlock */
@property (nonatomic, copy)wifiListBlock wifiListblock;
/** 代理对象 */
@property (nonatomic, weak) id <HK_BlueToothDelegate> delegate;
/** 测试数据，判断getwifilist是否获取手成功 */
@property (nonatomic,getter=isGetWifiListSuccess) BOOL getWifiListSuccess;
/** wifiList Head */
@property (nonatomic, strong) NSString *headeString;
/** wifiList length */
@property (nonatomic, strong) NSString *lengthStr;
/** wifi分包接受的总数据 */
@property (nonatomic, strong) NSString *wifiAllData;
/** wifi数据 */
@property (nonatomic,strong) NSMutableArray *wifiData;
/** 成功的回调 */
@property (nonatomic, copy)successBlock successblock;
/** 是否手动取消蓝牙连接 */
@property (nonatomic, getter=isHandleCancleBleConnect) BOOL handleCancleBleConnect;
/** h5是否开启了蓝牙扫描 */
@property (nonatomic, getter=isH5OpenBlueScan) BOOL h5OpenBlueScan;
/** H5传的SN码 */
@property (nonatomic, strong)NSString *h5SendeSN;
/**
 *   蓝牙是否一对一连接
 *   1 连接
 *   0 断开
 */
@property (nonatomic, assign)int bleConnect;

/** 2017-10~26 添加 */
@property (nonatomic, assign)BOOL isConnect;

/** 是否执行断开蓝牙的倒计时 */
@property (nonatomic, assign)BOOL isBlePluginTypeDisConnect;

/** 绑定状态 */
@property (nonatomic, assign) int blueState;

/** 开始蓝牙监听的方法 */
- (void)hk_startBlueTools;
/**
 单利方法
 @return return value description
 */
+ (instancetype)hk_shareManager;
/**
 写数据往特征值里面

 @param data data description
 */
- (void)sendDataTocharacteristic:(NSString *)data;

/**
 添加一个倒计时
 
 @param countDownTime 调用这个方法的时间
 */
- (void)addCommondOvertime:(NSTimeInterval)overtime withType:(BlePluginType)type;
@end

@protocol HK_BlueToothDelegate <NSObject>
/**
 蓝牙连接状态和广播包的只身状态

 @param status 蓝牙连接状态
 @param status 广播包的状态
 @param snCode 硬件的SN码
 */
- (void)hk_blueToothConnectStatus:(NSInteger)ConnectStatus withBlueToothAdvertise:(NSInteger)status withSnCode:(NSString *)snCode;
/**
 蓝牙连接成功
 */
- (void)hk_blueConnectSuccess;
@end



