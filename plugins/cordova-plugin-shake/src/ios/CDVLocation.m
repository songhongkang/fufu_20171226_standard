//
//  CDVLocation.m
//  shake_cor
//
//  Created by shangzh on 16/5/13.
//
//

#import "CDVLocation.h"

#import <AMapLocationKit/AMapLocationKit.h>

#define LocationTimeout 3  //   定位超时时间，可修改，最小2s
#define ReGeocodeTimeout 3 //   逆地理请求超时时间，可修改，最小2s

@interface CDVLocation() <AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;

@property (nonatomic,strong) CDVPluginResult *result;

@property (nonatomic,copy) NSString *callID;

@end

@implementation CDVLocation

- (void)location:(CDVInvokedUrlCommand*)command {
    _callID = command.callbackId;
    NSLog(@"start====location");
    [self initCompleteBlock];
    [self configLocationManager];
    [self reGeocodeAction];
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
                NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
                
                if (error.code == AMapLocationErrorLocateFailed)
                {
                    return;
                }
            }
            
            if (location)
            {
                if (regeocode)
                {
                    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",location.coordinate.latitude ],@"latitude",[NSString stringWithFormat:@"%f",location.coordinate.longitude],@"longitude",regeocode.formattedAddress,@"address",nil];
                   weSelf.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
                    [weSelf.commandDelegate sendPluginResult:weSelf.result callbackId:weSelf.callID];
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
        
        [self.locationManager setPausesLocationUpdatesAutomatically:NO];
        
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        
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


@end
