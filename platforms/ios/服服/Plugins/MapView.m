//
//  MapView.m
//  SingIn
//
//  Created by shangzh on 16/2/26.
//  Copyright © 2016年 shangzh. All rights reserved.
//

#import "MapView.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "CustomAnnotationView.h"

#import "MapModel.h"

#import "CDVShowAddressView.h"
#import "UIView+UIViewAnimation.h"

@interface MapView() <MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, strong) MAPointAnnotation *pointAnnotaiton;

@property (nonatomic,strong) AMapSearchAPI *amapSearch;

//用于判断是否第一次显示地图中心（搜索中有传参时需根据参数来定位中心点）
@property (nonatomic,assign) BOOL isMove;

//当前坐标点（搜索地图中）
@property (nonatomic,assign) CLLocationCoordinate2D coord;

@property (nonatomic,assign) BOOL isResponDelegate;

@end

@implementation MapView

- (id)initWithFrame:(CGRect)frame andIsCanLocation:(BOOL)locateion {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initMapViewWith:frame];
        if (locateion) {
            [self initLocationManager];
            [self.locationManager startUpdatingLocation];
            [self configLocationManager];
        }
        self.isResponDelegate = YES;
        self.isMove = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initMapViewWith:frame];
        if (self.isCanGetLocation) {
            [self initLocationManager];
            [self.locationManager startUpdatingLocation];
            [self configLocationManager];
        }
    
        self.isResponDelegate = YES;
        self.isMove = YES;
    }
    return self;
}

- (void)initMapViewWith:(CGRect)frame
{
    self.mapView = [[MAMapView alloc] initWithFrame:frame];
    
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    [self.mapView setShowsUserLocation:YES];
    
    [self addSubview:self.mapView];
}

- (void)initLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];

    [self.locationManager setLocationTimeout:6];
    
    [self.locationManager setReGeocodeTimeout:3];
}

- (void)configLocationManager
{
    [self.locationManager setPausesLocationUpdatesAutomatically:YES];
    
    [self.locationManager setAllowsBackgroundLocationUpdates:NO];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    //    [self.pointAnnotaiton setCoordinate:location.coordinate];
//    if (self.isCanGetLocation) {
//        if (self.centerCoor.latitude != 0) {
//            [self.mapView setCenterCoordinate:self.centerCoor];
//        } else {
//            [self.mapView setCenterCoordinate:location.coordinate];
//        }
//    } else {
//        if (self.centerCoor.latitude > 0 && self.centerCoor.longitude > 0) {
//             [self.mapView setCenterCoordinate:self.centerCoor animated:YES];
//        }
//    }
    
    if (self.centerCoor.latitude != 0) {
        [self.mapView setCenterCoordinate:self.centerCoor];
    } else {
        [self.mapView setCenterCoordinate:location.coordinate];
    }
    
    [self.mapView setZoomLevel:self.zoomLevel animated:NO];
    
    self.firstLocation = location.coordinate;
    
    [self.locationManager stopUpdatingLocation];
    
    if (_isResponDelegate) {
        [self.delegate completedUpdateLocation:self.firstLocation];
        _isResponDelegate = !_isResponDelegate;
    }
    
    if (self.isShowImage) {
        MAPointAnnotation *mappoint = [[MAPointAnnotation alloc] init];
        mappoint.coordinate = location.coordinate;
        [self.mapView addAnnotation:mappoint];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
        if ([annotation isKindOfClass:[MAPointAnnotation class]])
        {
            static NSString *reuseIndetifier = @"annotationReuseIndetifier";
            CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
            
            if (annotationView == nil)
            {
                annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            }
            annotationView.isShowCallout = self.isShowCallout;
            annotationView.title = annotation.title;
            if (self.isShowCallout) {
                annotationView.image = [UIImage imageNamed:@"address_small"];
                
                // 设置为NO，用以调用自定义的calloutView
                annotationView.canShowCallout = NO;
                [annotationView setSelected:YES animated:YES];
                // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
                annotationView.centerOffset = CGPointMake(0, -18);
            } else {
                //标注图片是否可以进行替换
                annotationView.markCanScal = self.markCanScal;
                annotationView.image = [UIImage imageNamed:@"address_small"];
                [annotationView setSelected:NO animated:YES];
            }
         
            return annotationView;
        }
    
    return nil;
}

- (void)stop {
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    self.mapView = nil;
    
}

- (void)setCenterLocationWithCenterCoor:(CLLocationCoordinate2D)centerCoor {
    [self.mapView setCenterCoordinate:centerCoor animated:YES];
}

- (void)addAnimation:(MAPointAnnotation *)animation {
    [self.mapView addAnnotation:animation];
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    if (wasUserAction || self.isShowLocation) {
        
        self.coord = [self.mapView convertPoint:CGPointMake(self.mapView.center.x, self.mapView.center.y-30) toCoordinateFromView:self.mapView];
        
        NSDictionary *info = [NSBundle mainBundle].infoDictionary;
        
        // 取出 高德apikey
        NSString *apikey = info[@"GDapikey"];
        
//        [AMapSearchServices sharedServices].apiKey = apikey;
        
        self.amapSearch =  [[AMapSearchAPI alloc] init];
        self.amapSearch.delegate = self;
        AMapGeoPoint *mapPoint = [AMapGeoPoint locationWithLatitude:self.coord.latitude longitude:self.coord.longitude];
        AMapReGeocodeSearchRequest *searRequest = [[AMapReGeocodeSearchRequest alloc] init];
        searRequest.location = mapPoint;
        [self.amapSearch AMapReGoecodeSearch:searRequest];
    } else {
        if (self.isMove) {
            [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.searchMapSelectModel.latitude, self.searchMapSelectModel.longitude) animated:YES];
            self.isMove = NO;
        }
    }
    
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    if (response.regeocode && !self.isCanResponser) {
        self.city = [NSString stringWithFormat:@"%@%@%@",response.regeocode.addressComponent.province,response.regeocode.addressComponent.city,response.regeocode.addressComponent.district];
        NSString *str  = response.regeocode.formattedAddress;
        NSString *address = nil;
        if (str != nil && [str length] > 0) {
            if (response.regeocode.addressComponent.province != nil && response.regeocode.addressComponent.province.length > 0) {
               str = [str stringByReplacingOccurrencesOfString:response.regeocode.addressComponent.province withString:@""];
            }
            if (response.regeocode.addressComponent.city != nil && response.regeocode.addressComponent.city.length
                 > 0) {
                str = [str stringByReplacingOccurrencesOfString:response.regeocode.addressComponent.city withString:@""];
            }
            address = str;
//            address = [[str stringByReplacingOccurrencesOfString:response.regeocode.addressComponent.province withString:@""] stringByReplacingOccurrencesOfString:response.regeocode.addressComponent.city withString:@""];
        }
        [self updateWithAddress:address latitude:self.coord.latitude longitude:self.coord.longitude];
    }
}

- (void)updateWithAddress:(NSString *)address latitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    if ([address length] > 0 && latitude > 0 && longitude > 0) {
        NSDictionary *userInfo=@{@"address":address,@"latitude":[NSString stringWithFormat:@"%f",latitude],@"longitude":[NSString stringWithFormat:@"%f",longitude]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLocation" object:self userInfo:userInfo];
    }
}

@end
