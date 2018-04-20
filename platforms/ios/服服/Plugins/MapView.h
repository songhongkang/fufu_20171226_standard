//
//  MapView.h
//  SingIn
//
//  Created by shangzh on 16/2/26.
//  Copyright © 2016年 shangzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

@class MapModel;
@class MAPointAnnotation;

@protocol MapViewDelegate <NSObject>

@optional
- (void)completedUpdateLocation:(CLLocationCoordinate2D)location;

@end

@interface MapView : UIView

- (void)stop;

@property (nonatomic,assign) double zoomLevel;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic,assign) CLLocationCoordinate2D firstLocation;

@property (nonatomic,retain) id<MapViewDelegate> delegate;

//搜索地图已经选择的地点
@property (nonatomic,strong) MapModel *searchMapSelectModel;

//searchmap中是否显示当前地图
@property (nonatomic,assign) BOOL isShowLocation;

//是否显示自定义的气泡
@property (nonatomic,assign) BOOL isShowCallout;

//自定义标注是否可以修改（放大）
@property (nonatomic,assign) BOOL markCanScal;

//是否可以进行定位
@property (nonatomic,assign) BOOL isCanGetLocation;

//用图片替换当前定位标识
@property (nonatomic,assign) BOOL isShowImage;


//当前定位的省市区
@property (nonatomic,copy) NSString *city;

@property (nonatomic,assign) CLLocationCoordinate2D centerCoor;

@property (nonatomic,assign) BOOL isCanResponser;  


- (void)addAnimation:(MAPointAnnotation *)animation;

//是否可以进行定位
- (id)initWithFrame:(CGRect)frame andIsCanLocation:(BOOL)locateion;

- (void)setCenterLocationWithCenterCoor:(CLLocationCoordinate2D) centerCoor;

@end
