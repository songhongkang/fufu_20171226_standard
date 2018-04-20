//
//  HK_BlueTooth.m
//  服服
//
//  Created by 宋宏康 on 2017/8/25.
//
//

#import "HK_BlueTooth.h"
#import "BabyToy.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "NSString+Tools.h"
#include "Des.h"
#import "JPushPlugin.h"
#import "NSTimer+Task.h"
#import "Constan.h"

#define HK_SERVICE_UUID @"4458"
#define HK_CHARACTERISTIC_UUID_CHANNEL0 @"4454"
#define HK_CHARACTERISTIC_UUID_CHANNEL1 @"4455"
#define HK_CHARACTERISTIC_UUID_CHANNEL2 @"4456"
#define HK_CHARACTERISTIC_UUID_CHANNEL3 @"4457"
#define HK_CHARACTERISTIC_UUID_CHANNEL4 @"4458"
/** 蓝牙接收到的最大值 */
static const int BLE_SEND_MAX_LEN = 20;
/** 无绑定无连接 */
static const int NOT_BANG_NOT_CONNECT = 1;
//* 无绑定有连接 
//static const int NOT_BANG_IS_CONNECT = 1;
///** 已绑定无连接 */
//static const int IS_BANG_NOT_CONNECT = 2;
///** 已绑定已连接 */
//static const int IS_BANG_IS_CONNECT = 3;
/** 考勤机正在连接 */
static const int BEL_CONNECTING = 4;
/** 考勤机连接成功 */
static const int BEL_CONNECT_SUCCESS = 5;
/** 考勤机断开连接 */
static const int BEL_DISCONNECT= 6;
/** BLE扫描超时 */
static const int BEL_CONNECT_TIMEOUT= 7;
/** 设置wifi配置成功 */
static const int SET_WIFICONFIG_SUCCESS= 8;
/** 设置wifi配置失败 */
static const int SET_WIFICONFIG_FAIL= 9;
/** 蓝牙开关关闭（手动） */
static const int BEL_STATE_OFF= 10;
/** 蓝牙开关开启（手动） */
static const int BEL_STATE_ON= 11;
/** 考勤机连接失败 */
static const int BEL_CONNECT_FAIL= 12;
/** 考勤机配置成功 */
static const int BLE_CONFIG_SUCCESS= 13;
/** 考勤机配置失败 */
static const int BLE_CONFIG_FAIL = 14;
/** 考勤机做了物理解绑 */
static const int BLE_BIND_RESTORE = 15;
/** 考勤机没有做物理解绑 */
static const int BLE_BIND_NORMAL = 16;
/** 考勤机物理解绑超时 */
static const int BLE_BIND_OVERTIME = 17;
/** 考勤机只支持无线网络 */
static const int BLE_WIFI_ONLY = 18;
/** 考勤机只支持无线网络和有线网络 */
static const int BLE_WIFIANDCABLE_ONLY = 19;
/** 查询网络连接方式  超时 */
static const int BLE_QUERYNETWORK_TIMEOVER = 20;


@interface HK_BlueTooth()
                    <CBCentralManagerDelegate,CBPeripheralDelegate>
/** 广播包 */
@property (nonatomic, strong) NSString *broadcast;
/**  周边设备的服务特征值*/
@property (nonatomic, strong) CBCharacteristic *characteristic1;
/**  周边设备的服务特征值*/
@property (nonatomic, strong) CBCharacteristic *characteristic2;
/** 设备编号 */
@property (nonatomic, strong) NSString *snNeed;
/** WiFi连接成功 */
@property (nonatomic, getter=isWifiConnect) BOOL wifiConnect;
@end

@implementation HK_BlueTooth
/** 保存定时器的字典 */
//static NSMutableDictionary<NSString *, NSTimer *> *_timerHome = nil;
/** 对象 */
static HK_BlueTooth *_instance;

+ (instancetype)hk_shareManager
{
    @synchronized (self) {
        //        // 为了防止多线程同时访问对象，造成多次分配内存空间，所以要加上线程锁
        if (_instance == nil) {
            _instance = [[self alloc] init];
//            _timerHome = [NSMutableDictionary dictionary];
//            _timerHome = [[NSMutableDictionary alloc] init];
        }
    }
    return _instance;
}

#pragma mark -help
- (void)sendDataTocharacteristic:(NSString *)testString
{
    _wifiAllData = @"";
    MyNSLog(@"\n我发送的指令----：%@",testString);
    NSString *hexString =  [BabyToy ConvertStringToHexString:testString];
    NSData *data = [BabyToy stringToHexData:hexString];
    //    MyNSLog(@"data:%@",data);
    for (int i = 0; i < [data length]; i += BLE_SEND_MAX_LEN) {
        // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
        if ((i + BLE_SEND_MAX_LEN) < [data length]) {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, BLE_SEND_MAX_LEN];
            NSData *subData = [data subdataWithRange:NSRangeFromString(rangeStr)];
            MyNSLog(@"\n分包发送的数据：%@",subData);
            //1.如果写特征有值
            if (!self.characteristic2) break;
            //发送数据
            [self.peripheral writeValue:subData forCharacteristic:self.characteristic2 type:CBCharacteristicWriteWithResponse];
            //根据接收模块的处理能力做相应延时
            usleep(20 * 1000);
        }
        else {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([data length] - i)];
            NSData *subData = [data subdataWithRange:NSRangeFromString(rangeStr)];
            MyNSLog(@"\n分包发送的数据：%@",subData);
            if (!self.characteristic2) break;
            //发送数据
            [self.peripheral writeValue:subData forCharacteristic:self.characteristic2 type:CBCharacteristicWriteWithResponse];
            usleep(20 * 1000);
        }
    }
}

- (void)hk_startBlueTools
{
    NSDictionary *dic = @{
                          CBCentralManagerOptionShowPowerAlertKey : @NO
                          };
    if (!self.manager) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:dic];
    }else{
        [self.manager scanForPeripheralsWithServices:nil options:nil];
    }
    // 初始值
    _handleCancleBleConnect = NO;
}

- (void)hk_stopBlueTools
{
    [self.manager stopScan];
}

- (void)hk_bleConnecting
{

}

#pragma mark - CBCentraManagerDelegate

/**
 蓝牙状态

 @param central 中心设备
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStatePoweredOn:
        {
            _bleState = 1;
            MyNSLog(@">>>>>>>手机蓝牙开启成功");
            [JPushPlugin hk_monitorBlueToothStates:BEL_STATE_ON withSn:@""];
            if (self.isH5OpenBlueScan) {
                NSDictionary *optionDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
                [self.manager scanForPeripheralsWithServices:nil  options:optionDic];
                _h5OpenBlueScan = NO;
            }
        }
            break;
        case CBManagerStatePoweredOff:
        {
            _bleState = 0;
            // 2017年11月24日17:42:04
            _h5OpenBlueScan = NO;
            MyNSLog(@">>>>>>>手机蓝牙没有开启成功");
            if (_successblock) {
                _successblock();
            }
            [JPushPlugin hk_monitorBlueToothStates:BEL_STATE_OFF withSn:@""];
        }
            break;
        default:
            break;
    }
}

/**
 扫描到蓝牙

 @param central 中心设备
 @param peripheral 外围设备
 @param advertisementData 广告数据
 @param RSSI 信号值
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    self.peripheral = peripheral;
    // 获取广播包数据
    NSString *hexStr = [BabyToy ConvertDataToHexString:advertisementData[@"kCBAdvDataManufacturerData"]];
//    NSString *localName = [advertisementData[@"kCBAdvDataLocalName"] lowercaseString];
    if (hexStr.length >= 42 && ![[hexStr substringWithRange:NSMakeRange(4, 26)] isEqualToString:@"00000000000000000000000000"])
    {
        // 1.先取出SN码
        _snNeed = [hexStr substringWithRange:NSMakeRange(4, 38)];
        NSData *data =   [NSString convertHexStrToData:_snNeed];
        char *testByte3 = (char *)[data bytes];
        char dest[19] = {0};
        BluetoothGetSNStr(testByte3, 19, dest, 19);
        _snNeed =  [[NSString getIosHexByCstring:dest] substringToIndex:26];
        _snNeed = [BabyToy ConvertHexStringToString:_snNeed];
        
        NSString *flag = hexStr;
        NSString *hexToBinary;
        // 取出倒数第一位和倒数第二位
        NSRange range = NSMakeRange(flag.length - 2, 2);
        
        hexToBinary = [NSString getBinaryByHex:[flag substringWithRange:range]];
        NSString *flag1 = [hexToBinary substringFromIndex:hexToBinary.length-1];
        NSString *flag2 = [hexToBinary substringWithRange:NSMakeRange(hexToBinary.length - 2, 1)];
        MyNSLog(@"============start=========");
        MyNSLog(@"sn:%@",_snNeed);
        MyNSLog(@"hexStr:%@",hexStr);
        MyNSLog(@"============end=========");

        if ([[hexStr substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"5a4b"])
        {
            // 1.判断H5是否参数带有SN码, && 匹配到成功的SN
            if ([_h5SendeSN isEqualToString:_snNeed]) {
                //2. 连接蓝牙
                [self.manager connectPeripheral:peripheral options:nil];
                //4.停止扫描
                [self.manager stopScan];
                //3.正在连接中
                [JPushPlugin hk_monitorBlueToothStates:BEL_CONNECTING withSn:@""];
                //5.回调成功后，取消定时器
                if (_successblock) {
                    _successblock();
                }
                //6.开启定时器
                [self addCommondOvertime:30 withType:BlePluginTypeConnecting];
                //4.开启定时器
                MyNSLog(@"考勤机正在连接");
            }
            //1.是中控设备 && 无绑定 && 智能设备
            if ([flag2 integerValue] == 0 && [flag1 integerValue] == 1 ) {
                if (!_h5SendeSN && _isConnect == NO) //1._h5SendeSN为空，说明是二维码扫描触发蓝牙
                {
                    _isConnect = YES;
                    //5.把_h5SendeSN设置成空
                    _h5SendeSN = nil;
                    //4. 无绑定 &&无连接
                    [JPushPlugin hk_monitorBlueToothStates:NOT_BANG_NOT_CONNECT withSn:_snNeed];
                    //1. 发送绑定的ajax请求
                    //2. 连接蓝牙
                    [self.manager connectPeripheral:peripheral options:nil];
                    //4.停止扫描
                    [self.manager stopScan];
                    //3.正在连接中
                    [JPushPlugin hk_monitorBlueToothStates:BEL_CONNECTING withSn:@""];
                    //5.回调成功后，取消定时器
                    if (_successblock) {
                        _successblock();
                    }
                    //6.开启定时器
                    [self addCommondOvertime:30 withType:BlePluginTypeConnecting];
                    //4.开启定时器
                    MyNSLog(@"考勤机正在连接");
                }
            }else{
                //1.是中控设备 &&  无绑定 &&传统设备
                if ([flag2 integerValue] == 0 && [flag1 integerValue] == 0) {
                    //2.无绑定 && 已连接
                    _blueState = 0;
                }
                // 10   		已绑定传统设备   2
                if ([flag2 integerValue] == 1 && [flag1 integerValue] == 0) {
                    //3.已绑定 && 无连接
                    _blueState = 2;
                }
                // 11    		已绑定智能设备    3
                if ([flag2 integerValue] == 1 && [flag1 integerValue] == 1) {
                    //3.已绑定 && 无连接
                    _blueState = 3;
                }
            }
        }
    }
}

/**
 蓝牙连接成功

 @param central 中心设备
 @param peripheral 外围设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    MyNSLog(@"%@", [NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.identifier]);
    self.peripheral.delegate = self;
    [self.peripheral discoverServices:nil];
    //1.取消正在连接的定时器
    if (_successblock) {
        _successblock();
    }
    //2.开启发现服务的定时器
    [self addCommondOvertime:10 withType:BlePluginTypeHavaSerices];
}

/**
 蓝牙连接失败

 @param central 中心设备
 @param peripheral 外围设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    MyNSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
    //1.把状态码发送给h5
    [JPushPlugin hk_monitorBlueToothStates:BEL_CONNECT_FAIL withSn:@""];
    //2.取消是定时
    _successblock();
    // 初始值，不让他走代理
    _manager = nil;
}

/**
 断开连接

 @param central 中心设备
 @param peripheral 外围设备
 @param error 错误码
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    MyNSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
    if (!self.isHandleCancleBleConnect) {
        //1.不是手动取消的蓝牙连接，eg:蓝牙断点，手机蓝牙关闭
        [JPushPlugin hk_monitorBlueToothStates:BEL_DISCONNECT withSn:@""];
    }else{
        _manager = nil;
    }
    //2.执行完成后设置成初始状态
    self.handleCancleBleConnect = NO;
    //3.蓝牙一对一连接flag设置成0
    _bleConnect = 0;
    // 关闭定时器
    if (_successblock) {
        _successblock();
    }
}

/**
 已发现的服务

 @param peripheral 外围设备
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error) {
        for (CBService *service in peripheral.services) {
            MyNSLog(@"serviceUUID:%@",service.UUID);
            if ([service.UUID.UUIDString isEqualToString:HK_SERVICE_UUID]) {
                [service.peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}

/**
 发现特征值

 @param peripheral 外围设备
 @param service 服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
    
        if ([characteristic.UUID.UUIDString isEqualToString:HK_CHARACTERISTIC_UUID_CHANNEL4]) {
            self.characteristic2 = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic2];
        }
    }
    if ([self.delegate respondsToSelector:@selector(hk_blueConnectSuccess)]) {
        [self.delegate hk_blueConnectSuccess];
    }
    
    if (_successblock) {
        _successblock();
    }
    //1.写入一对一的蓝牙建立连接
    [self sendDataTocharacteristic:@"HEAD=12;REQ=CONNECT;"];
    //2.开启定时器
    [self addCommondOvertime:30 withType:BlePluginTypeConnect];
}

/**
 写入数据是否成功的代理

 @param peripheral 外设
 @param characteristic 特征值
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        MyNSLog(@"===写入错误：%@",error);
    }else{
        MyNSLog(@"===写入成功");
    }
}

/**
 数据接受

 @param peripheral 外围设备
 @param characteristic 特征值
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //获取订阅特征回复的数据
    NSData *value = characteristic.value;
    NSString *string = [BabyToy ConvertDataToHexString:value];
    if (string.length == 0) return;
//    MyNSLog(@"\n蓝牙给APP发送的数据:%@",string);
    MyNSLog(@"\n蓝牙给APP发送的数据:%@,value:%@",[BabyToy ConvertHexStringToString:string],string);
    _wifiAllData  = [_wifiAllData stringByAppendingString:string];
    
    if ([[BabyToy ConvertHexStringToString:string] isEqualToString:@"RESP=CON-OK;"]){
        // 3.把连接状态的flag设置成1
        _bleConnect = 1;
        //2.蓝牙一对一连接的状态给 H5
        [JPushPlugin hk_monitorBlueToothStates:BEL_CONNECT_SUCCESS withSn:@""];
        MyNSLog(@"考勤机连接成功");
        // 4.取消定时器,取消 蓝牙连接的 定时器
        //2.关闭发现服务的定时器
        if (_successblock) {
            _successblock();
        }
        NSString *blePulginTime = [NSString stringWithFormat:@"HEAD=25;TIME=%@;",[NSString getCurrentTimesFormatter1]];
        //3.发送设置蓝牙时间的指令
        [self sendDataTocharacteristic:blePulginTime];
        //4.延时一秒，再去执行 发送 物理解绑的指令
        [self addCommondOvertime:1 withType:BlePluginTypeDelay];
        
    }else if ([[BabyToy ConvertHexStringToString:string] isEqualToString:@"RESP=TIME-OK;"]){
        //1.蓝牙考勤机时间设置成功
    }
    else if ([[BabyToy ConvertHexStringToString:_wifiAllData] hasPrefix:@"HEAD="]) { //WiFi列表获取成功
        if (self.isGetWifiListSuccess) {
            _headeString =  [[BabyToy ConvertHexStringToString:_wifiAllData] componentsSeparatedByString:@";"][0];
            _lengthStr = [_headeString substringFromIndex:5];
            self.getWifiListSuccess = NO;
        }
        
        NSInteger length =[[BabyToy ConvertHexStringToString:_wifiAllData] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//        NSInteger length =[[BabyToy ConvertHexStringToString:_wifiAllData] length];
        
        MyNSLog(@"\\\\\\start\\\\\\");
        MyNSLog(@"_str:\n%@",[BabyToy ConvertHexStringToString:_wifiAllData]);
        MyNSLog(@"\\\\\\end\\\\\\");

        
        if (length - _headeString.length  -1 == [_lengthStr intValue]) {
            //2.停止定时器 ,停止获取WiFi倒计时
            //2.关闭发现服务的定时器
            if (_successblock) {
                _successblock();
            }
            NSString *str =  [[BabyToy ConvertHexStringToString:_wifiAllData] componentsSeparatedByString:@";"][1];
            NSDictionary *dict =  [NSString dictionaryWithJsonString:str];
            
            for (NSDictionary *dic in dict[@"wifilist"]) {
           
                NSDictionary *dictJson =@{
                                          @"ssid":[[dic valueForKey:@"SSID"] base64DecodedString],
                                          @"bssid":[dic valueForKey:@"BSSID"],
                                          @"level":[NSNumber numberWithInt:[[dic valueForKey:@"SIGNAL_LEVEL"] intValue]],
                                          @"isPassWord":[[dic valueForKey:@"AUTH_TYPE"] hasPrefix:@"AUTH_OPEN"] ? @0:@1};
                
                [_wifiData addObject:dictJson];
            }
            
            NSDictionary *dictJson = @{@"list":_wifiData};
            NSString *strJson =  [NSString dictionaryToJson:dictJson];
            MyNSLog(@"strJson:%@",strJson);
            if (self.wifiListblock) {
                self.wifiListblock((NSString *)dictJson);
            }
        }
    }
    else if ([[BabyToy ConvertHexStringToString:string]  isEqualToString:@"RESP=WIFI-INFO-OK;"]) {
        // 1.WiFi设置成功
        self.wifiConnect = YES;
    }
    else if ([[BabyToy ConvertHexStringToString:string]  isEqualToString:@"RESP=WIFI-CONNECT;"] && self.isWifiConnect) {
        //6.设置_handleCancleBleConnect 位no, 后面会返回状态
        _handleCancleBleConnect = NO;
        // 1.设置WiFi成功，把状态给H5
        [JPushPlugin hk_monitorBlueToothStates:SET_WIFICONFIG_SUCCESS withSn:@""];
        //4.关闭设置WiFi的定时器
        //2.关闭发现服务的定时器
        if (_successblock) {
            _successblock();
        }
        // 3.再做一个倒计时
        [self addCommondOvertime:30 withType:BlePluginTypeCofiging];
    }
    else if ([[BabyToy ConvertHexStringToString:string] isEqualToString:@"RESP=DISCON-OK;"]){
        //4.关闭设置配置蓝牙的断开的定时器
        //2.关闭发现服务的定时器
        if (_successblock) {
            _successblock();
        }
        //3.断开蓝牙考勤机
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
    //考勤机连接成功
    else if ([[BabyToy ConvertHexStringToString:string] isEqualToString:@"RESP=BIND-OK;"]){
        MyNSLog(@"考勤机连接成功返回13");
        //.设置_handleCancleBleConnect 位YES, 后面不会返回状态
        //5.断开指令不再发送给h5
        _handleCancleBleConnect = YES;
        // 2.发送断开连接的指令给蓝牙
        [self sendDataTocharacteristic:@"HEAD=15;REQ=DISCONNECT;"];
        
        //2.关闭等待 考勤机连接成功的倒计时
        if (_successblock) {
            _successblock();
        }
//        // 蓝牙发送断开指令失败
//        if (self.peripheral) {
//            [self.manager cancelPeripheralConnection:self.peripheral];
//        }
//        // 1.关闭定时器
        [JPushPlugin hk_monitorBlueToothStates:BLE_CONFIG_SUCCESS withSn:@""];

        [self addCommondOvertime:3 withType:BlePluginTypeDisConnect];
    }
    //考勤机连接失败
    else if ([[BabyToy ConvertHexStringToString:string] isEqualToString:@"RESP=BIND-FAIL;"] && _isBlePluginTypeDisConnect==NO){
        MyNSLog(@"考勤机连接失败返回14");
        //.设置_handleCancleBleConnect 位YES, 后面不会返回状态
        //5.断开指令不再发送给h5
        _handleCancleBleConnect = YES;
        // 2.发送断开连接的指令给蓝牙
        [self sendDataTocharacteristic:@"HEAD=15;REQ=DISCONNECT;"];
        
        //2.关闭等待 考勤机连接成功的倒计时
        if (_successblock) {
            _successblock();
        }
//        // 1.关闭定时器
        [JPushPlugin hk_monitorBlueToothStates:BLE_CONFIG_FAIL withSn:@""];
        
        [self addCommondOvertime:3 withType:BlePluginTypeDisConnect];
    }
    // 物理解绑成功
    else if ([[BabyToy ConvertHexStringToString:string]  isEqualToString:@"RESP=BIND-RESTORE;"]) {
        // 1.物理解绑成功，发送指令15个h5
        [JPushPlugin hk_monitorBlueToothStates:BLE_BIND_RESTORE withSn:_snNeed];
        MyNSLog(@"发送指令15给H5");
        //2.关闭定时器
        if (_successblock) {
            _successblock();
        }
    }
    // 没有做物理解绑
    else if ([[BabyToy ConvertHexStringToString:string]  isEqualToString:@"RESP=BIND-NORMAL;"]) {
        //2.关闭定时器
        if (_successblock) {
            _successblock();
        }
        // 1.没有做物理解绑，发送指令16给h5
        [JPushPlugin hk_monitorBlueToothStates:BLE_BIND_NORMAL withSn:@""];
        MyNSLog(@"发送指令16给H5");
        [self addCommondOvertime:1 withType:BlePluginTypeDelaySendQueryNetwork];
    }
    // 只支持无线网络
    else if ([[BabyToy ConvertHexStringToString:string]  isEqualToString:@"RESP=WIFI-ONLY;"]) {
        //2.关闭定时器
        if (_successblock) {
            _successblock();
        }
        // 1.只支持无线网络，发送指令18给h5
        [JPushPlugin hk_monitorBlueToothStates:BLE_WIFI_ONLY withSn:@""];
        MyNSLog(@"发送指令18给H5");
    }
    // 支持有线和无线网络
    else if ([[BabyToy ConvertHexStringToString:string]  isEqualToString:@"RESP=WIFIANDCABLE;"]) {
        //2.关闭定时器
        if (_successblock) {
            _successblock();
        }
        // 1.支持有线和无线网络。，发送指令19给h5
        [JPushPlugin hk_monitorBlueToothStates:BLE_WIFIANDCABLE_ONLY withSn:@""];
        MyNSLog(@"发送指令19给H5");
    }
    // 配置IP成功
    else if ([[BabyToy ConvertHexStringToString:string]  isEqualToString:@"RESP=NET-CON-OK;"]) {
        //2.关闭定时器
        if (_successblock) {
            _successblock();
        }
        // 1.配置IP成功。，发送指令8给h5
        [JPushPlugin hk_monitorBlueToothStates:SET_WIFICONFIG_SUCCESS withSn:@""];
        
        //2.关闭发现服务的定时器
        if (_successblock) {
            _successblock();
        }
        // 3.再做一个倒计时
        [self addCommondOvertime:30 withType:BlePluginTypeCofiging];
        _isBlePluginTypeDisConnect = NO;
        
    }
}

#pragma mark - cutdown
- (void)addCommondOvertime:(NSTimeInterval)overtime withType:(BlePluginType)type
{
    if (_successblock) {
        _successblock();
    }
    __block NSInteger count = overtime;
    // 每次开定时器的时候，取消定时器
//    [[_timerHome valueForKey:NSStringFromSelector(_cmd)] invalidate];
    NSTimer *timer = [NSTimer task_scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *__weak timer) {
        // 倒计时
        count--;
        MyNSLog(@"倒计时类型是:%ld,count:%ld",(unsigned long)type,(long)count);
        // 失败了
        if (count == 0) {
            [self senderTypeToH5:type];
            // 取消定时器
            [timer invalidate];
            MyNSLog(@"定时器取消了！！！！");
//            [_timerHome removeObjectForKey:NSStringFromSelector(_cmd)];
        }
    }];
//    _timerHome[NSStringFromSelector(_cmd)] = timer;
    // 成功后，取消定时器
    _successblock = ^(){
        MyNSLog(@"sss定时器取消了");
        // 定时器取消了
        [timer invalidate];
//        [_timerHome removeObjectForKey:NSStringFromSelector(_cmd)];
    };
//    if (timer) {
//        _timerHome[NSStringFromSelector(_cmd)] = timer;
//    }
}

- (void)senderTypeToH5:(BlePluginType)type
{
    if (type == BlePluginTypeScan) {
        if (_blueState != 99) {
            [JPushPlugin hk_monitorBlueToothStates:_blueState withSn:@""];
            MyNSLog(@"sn----:%@",_snNeed);
        }else{
            [JPushPlugin hk_monitorBlueToothStates:BEL_CONNECT_TIMEOUT withSn:@""];
        }
        [_manager stopScan];
    }
    if (type == BlePluginTypeScanWithSn) {
        [JPushPlugin hk_monitorBlueToothStates:BEL_CONNECT_TIMEOUT withSn:@""];
        [_manager stopScan];
    }
    
   else if (type == BlePluginTypeConnecting) {
        // 发送扫描超时的指令 || ble正在连接中 30秒
        [JPushPlugin hk_monitorBlueToothStates:BEL_CONNECT_TIMEOUT withSn:@""];
        self.handleCancleBleConnect = YES;
        [_manager cancelPeripheralConnection:self.peripheral];
    }
   else if (type == BlePluginTypeConnect || type == BlePluginTypeHavaSerices) {
        // 蓝牙一对一连接失败 || 蓝牙没有发现服务
        [JPushPlugin hk_monitorBlueToothStates:BEL_CONNECT_FAIL withSn:@""];
        self.handleCancleBleConnect  = YES;
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
  else if (type == BlePluginTypeGetWifiInfor) {
        // 获取WiFi失败
        if (self.wifiListblock) {
            NSDictionary *jsonStr = @{@"List":@[]};
            self.wifiListblock((NSString *)jsonStr);
        }
    }
   else if (type == BlePluginTypeSetWifiConfig) {
        // 蓝牙配置WiFi失败
        [JPushPlugin hk_monitorBlueToothStates:SET_WIFICONFIG_FAIL withSn:@""];
    }
   else if (type == BlePluginTypeCofiging) {
       //5.断开指令不再发送给h5
       _handleCancleBleConnect = YES;
       // 2.发送断开连接的指令给蓝牙
       [self sendDataTocharacteristic:@"HEAD=15;REQ=DISCONNECT;"];
       // 1.关闭定时器
       [JPushPlugin hk_monitorBlueToothStates:BLE_CONFIG_FAIL withSn:@""];
       MyNSLog(@"发送状态码14");
        // 考勤机没有配置成功
        [self addCommondOvertime:3 withType:BlePluginTypeDisConnect];
    }
   else if (type == BlePluginTypeDisConnect) {
       // 蓝牙发送断开指令失败
       if (self.peripheral) {
           [self.manager cancelPeripheralConnection:self.peripheral];
       }
   }
   else if (type == BlePluginTypeDelay){
       //1.查询考勤机是否进行了物理解绑
       [self sendDataTocharacteristic:@"HEAD=19;REQ=RESTORE-STATUS;"];
       // 倒计时5秒，
       [self addCommondOvertime:5 withType:BlePluginTypeBindStatus];
   }
   else if (type == BlePluginTypeBindStatus){
       // 考勤机物理解绑超时
       [JPushPlugin hk_monitorBlueToothStates:BLE_BIND_OVERTIME withSn:@""];
       MyNSLog(@"发送指令17给H5");
   }
   else if (type == BlePluginTypeNetworkWay){
       // APP查询网络连接方式
       [JPushPlugin hk_monitorBlueToothStates:BLE_QUERYNETWORK_TIMEOVER withSn:@""];
       MyNSLog(@"发送指令20给H5");
   }
   else if (type == BlePluginTypeDelaySendQueryNetwork){
       [self sendDataTocharacteristic:@"HEAD=13;NETWORK=TYPE;"];
       [self addCommondOvertime:5 withType:BlePluginTypeNetworkWay];
   }
}
@end

