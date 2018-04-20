//
//  CDVLocation.m
//  shake_cor
//
//  Created by shangzh on 16/5/13.
//
//

#import "CDVLocation.h"

#import <AMapLocationKit/AMapLocationKit.h>
#import "ShowMapViewController.h"
#import "SearchMapViewController.h"
#import "MapModel.h"
#import "ShowMapWithCoordinatViewController.h"
#import "CustomeNaigationViewController.h"
#import "SingCountMapViewController.h"
#import "Constan.h"
#import "CDVAlertMessageView.h"

#define LocationTimeout 6  //   定位超时时间，可修改，最小2s
#define ReGeocodeTimeout 3 //   逆地理请求超时时间，可修改，最小2s

@interface CDVLocation() <AMapLocationManagerDelegate,ShowMapViewControllerDelegate,SearchMapViewControllerDelegate,UIAlertViewDelegate,CLLocationManagerDelegate,CDVAlertMessageViewDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;

@property (nonatomic,strong) CDVPluginResult *result;

@property (nonatomic,copy) NSString *locationID;

@property (nonatomic,copy) NSString *callID;

@property (nonatomic,copy) NSString *address;

@property (nonatomic,strong) NSString *addressTitle;

@property (nonatomic,assign) Boolean isShowMap;

@property (nonatomic,strong) MapModel *selectedMap;

@property (nonatomic,assign) CGFloat latitude;

@property (nonatomic,assign) CGFloat longitude;

@property (nonatomic,copy) NSString *checkID;

@property (nonatomic, strong) CLLocationManager  *ilocationManager;

// 测试定位需要多久
@property (nonatomic, assign) int timeout;
@end

@implementation CDVLocation

- (void)checkCanLocation:(CDVInvokedUrlCommand *)command {
    self.checkID = command.callbackId;
    
    if (![self isCurrentAppLocatonServiceOn]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请您设置允许\"服服\"使用定位权限\n设置>隐私>定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
        
//        CDVAlertMessageView *message = [[CDVAlertMessageView alloc] initWithTitle:@"打开定位开关" message: @"进入系统【设置】>【隐私】>【定位服务】中打开开关，并允许服服使用定位服务" okButtonTitle:@"立即开启" cancelButtonTItle:@"取消" delegate:self];
        
        
//        CDVAlertMessageView *message = [[CDVAlertMessageView alloc] initWithTitle:@"打开定位开关" message: @"进入系统【设置】>【隐私】>【相册】中打开开关，并允许服服访问相册" okButtonTitle:@"立即开启" cancelButtonTItle:@"取消" delegate:self];
        
        CDVAlertMessageView *message = [[CDVAlertMessageView alloc] initWithTitle:@"打开定位开关" message:@"进入系统【设置】>【隐私】>【定位服务】中打开开关，并允许服服使用定位服务" okButtonTitle:@"立即开启" textType:TextLeft delegate:self];
        
        [message showInView:self.viewController.view];
        
        self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    } else {
        self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    }
    [self.commandDelegate sendPluginResult:self.result callbackId:self.checkID];
}

- (void)popUpView:(CDVAlertMessageView *)view accepted:(BOOL)accept {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if (Version >= 8.0f) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else {
        NSString *destPath = [NSString stringWithFormat:@"prefs:root=LOCATION_SERVICES&path=%@", identifier];
        NSURL*url2=[NSURL URLWithString:destPath];
        [[UIApplication sharedApplication] openURL:url2];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        if (Version >= 8.0f) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        else {
            NSString *destPath = [NSString stringWithFormat:@"prefs:root=LOCATION_SERVICES&path=%@", identifier];
            NSURL*url2=[NSURL URLWithString:destPath];
            [[UIApplication sharedApplication] openURL:url2];
        }
    }
}

- (void)location:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        // 这里是实现
        //    [self startCountdown];
        self.locationID = command.callbackId;
        if ([self isCurrentAppLocatonServiceOn]) {
            //定位功能可用，开始定位
            [self configLocationManager];
            [self initCompleteBlock];
            [self reGeocodeAction];
        } else {
            self.result =  [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"定位没有开启 ，请在设置中打开定位功能"];
            [self.commandDelegate sendPluginResult:self.result callbackId:self.locationID];
        }

    }];
    
}

- (void)showMap:(CDVInvokedUrlCommand *)command {
    _callID = command.callbackId;
    
    NSDictionary *dict = [command argumentAtIndex:0];
    
    ShowMapViewController *showMap = [[ShowMapViewController alloc] init];
    showMap.oldAddress = self.address;
    showMap.delegate = self;
    
    showMap.latitude = self.latitude;
    showMap.longitude = self.longitude;
    
//    showMap.latitude = [dict[@"latitude"] floatValue];
//    showMap.longitude = [dict[@"longitude"] floatValue];
//    if (self.selectedMap != nil) {
//        showMap.selecteModel = self.selectedMap;
//    }
    
    if (!showMap.selecteModel) {
        showMap.selecteModel = [[MapModel alloc] init];
    }
    if (showMap.selecteModel) {
        if ([dict[@"latitude"] length] != 0) {
            showMap.selecteModel.latitude = [dict[@"latitude"] floatValue];
        }
        if ([dict[@"longitude"] length] != 0) {
            showMap.selecteModel.longitude = [dict[@"longitude"] floatValue];
        }
        if ([dict[@"city"] length] != 0) {
            showMap.selecteModel.detailAddress = dict[@"city"];
        }
        if ([dict[@"address"] length] != 0) {
            showMap.selecteModel.title = dict[@"address"];
        }
    }

    CustomeNaigationViewController *nva = [[CustomeNaigationViewController alloc] initWithRootViewController:showMap];
    [self.viewController presentViewController:nva animated:YES completion:nil];
}

- (void)searchMap:(CDVInvokedUrlCommand *)command {
    _callID = command.callbackId;
    [self.locationManager stopUpdatingLocation];
    
    NSDictionary *location = [command argumentAtIndex:0];
    SearchMapViewController *searchMap = [[SearchMapViewController alloc] init];
    searchMap.oldAddress = [[MapModel alloc] init];
    searchMap.delegate = self;
    searchMap.oldAddress.anotherName = location[@"anotherName"];
    searchMap.oldAddress.latitude = [location[@"latitude"] floatValue];
    searchMap.oldAddress.longitude = [location[@"longitude"] floatValue];
    searchMap.oldAddress.title = location[@"address"];
    CustomeNaigationViewController *nva = [[CustomeNaigationViewController alloc] initWithRootViewController:searchMap];
    [self.viewController presentViewController:nva animated:YES completion:nil];
}

- (void)showMapWithCoordinate:(CDVInvokedUrlCommand *)command {
    self.callID = command.callbackId;
    NSDictionary *location = [command argumentAtIndex:0];
    
    ShowMapWithCoordinatViewController *coordMap = [[ShowMapWithCoordinatViewController alloc] init];
    coordMap.latitude = [location[@"latitude"] floatValue];
    coordMap.longitude = [location[@"longitude"] floatValue];
    coordMap.address = location[@"address"];
    CustomeNaigationViewController *nva = [[CustomeNaigationViewController alloc] initWithRootViewController:coordMap];
    [self.viewController presentViewController:nva animated:YES completion:nil];

}

- (void)singCountMap:(CDVInvokedUrlCommand *)command {
    _callID = command.callbackId;
    
    NSDictionary *location = [command argumentAtIndex:0];

    SingCountMapViewController *singCount = [[SingCountMapViewController alloc] init];
    singCount.target_date = location[@"target_date"];
    singCount.url = location[@"url"];
    CustomeNaigationViewController *nva = [[CustomeNaigationViewController alloc] initWithRootViewController:singCount];
    [self.viewController presentViewController:nva animated:YES completion:nil];
}

#pragma mark AMLocaton

- (void)initCompleteBlock
{
     __weak CDVLocation *weSelf = self;
    if (!self.completionBlock) {
        self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
        {
            if (error)
            {
                if (error.code == AMapLocationErrorLocateFailed)
                {
                    weSelf.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:nil];;
                    [weSelf.commandDelegate sendPluginResult:weSelf.result callbackId:weSelf.locationID];
                    return;
                }
 
            } else {
                if (location)
                {
                    if (regeocode)
                    {
                        if (regeocode.formattedAddress != nil && regeocode.formattedAddress.length > 0) {
                            
                            weSelf.address = regeocode.formattedAddress;
                            if (regeocode.province != nil && regeocode.province.length > 0) {
                                weSelf.address = [weSelf.address stringByReplacingOccurrencesOfString:regeocode.province withString:@""];
                            }
                            if (regeocode.city != nil && regeocode.city.length > 0) {
                                weSelf.address = [weSelf.address stringByReplacingOccurrencesOfString:regeocode.city withString:@""];
                            }
                            if (regeocode.district != nil && regeocode.district.length > 0) {
                                weSelf.address = [weSelf.address stringByReplacingOccurrencesOfString:regeocode.district withString:@""];
                            }
                        }
                        
                        weSelf.addressTitle = [NSString stringWithFormat:@"%@%@%@",regeocode.province,regeocode.city,regeocode.district];
                        weSelf.latitude =location.coordinate.latitude;
                        weSelf.longitude = location.coordinate.longitude;
                        if (!weSelf.isShowMap) {
                            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",location.coordinate.latitude ],@"latitude",[NSString stringWithFormat:@"%f",location.coordinate.longitude],@"longitude",weSelf.address,@"address",weSelf.addressTitle,@"city",nil];
                            
                            weSelf.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
                            [weSelf.commandDelegate sendPluginResult:weSelf.result callbackId:weSelf.locationID];
                            
                            [weSelf.locationManager stopUpdatingLocation];
                            weSelf.locationManager = nil;
                        }
                    }
                }
            }
        };
    }
}

- (void)configLocationManager
{
    if (!self.locationManager) {
        self.locationManager = [[AMapLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locationManager setPausesLocationUpdatesAutomatically:YES];
        [self.locationManager setAllowsBackgroundLocationUpdates:NO];
        [self.locationManager setLocationTimeout:LocationTimeout];
        [self.locationManager setReGeocodeTimeout:ReGeocodeTimeout];
    }
}

- (void)reGeocodeAction
{
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

- (void)locAction
{
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:self.completionBlock];
}

#pragma mark showmap delegate
- (void)selectedAdderess:(NSString *)address latitude:(CGFloat)latitude longitude:(CGFloat)longitude city:(NSString *)city detailAddress:(NSString *)detailAddress{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    if (address != nil && latitude > 0 && longitude > 0) {
        self.selectedMap = [[MapModel alloc] init];
        self.selectedMap.title = address;
        self.selectedMap.latitude = latitude;
        self.selectedMap.longitude = longitude;
        self.selectedMap.detailAddress = detailAddress;
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",latitude ],@"latitude",[NSString stringWithFormat:@"%f",longitude],@"longitude",[NSString stringWithFormat:@"%@",address],@"address",city,@"city",detailAddress,@"detailAddress",nil];
        
        self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];

    } else {
        self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:self.result callbackId:self.callID];
    
}

- (BOOL)isCurrentAppLocatonServiceOn
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark searmap delegate
- (void)selectedAddress:(MapModel *)model {
    
    NSDictionary *dic = @{@"address":model.title,@"anotherName":model.anotherName,@"latitude": [NSString stringWithFormat:@"%f",model.latitude],@"longitude":[NSString stringWithFormat:@"%f",model.longitude]};

    self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:self.result callbackId:self.callID];
}


#pragma mark getLocation fun

-(void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currLocation=[locations lastObject];
//    location.strLatitude=[NSString stringWithFormat:@"%f",currLocation.coordinate.latitude];
//    location.strLongitude=[NSString stringWithFormat:@"%f",currLocation.coordinate.longitude];

}

#pragma mark - 测试倒计时

/** 开启倒计时 */
- (void)startCountdown {
    if (_timeout > 0) {
        return;
    }
    _timeout = 60;
    // GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(_timeout <= 0 ){// 倒计时结束
            
            // 关闭定时器
            dispatch_source_cancel(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
            
        }else{// 倒计时中
            // 显示倒计时结果
            NSString *strTime = [NSString stringWithFormat:@"重发(%.2d)", _timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"strTime------>%@",strTime);
            });
            _timeout--;
        }
    });
    // 开启定时器
    dispatch_resume(_timer);
}
@end
