//
//  CDVLocation.h
//  shake_cor
//
//  Created by shangzh on 16/5/13.
//
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface CDVLocation : CDVPlugin

//定位
- (void)location:(CDVInvokedUrlCommand*)command;

//地图定位搜索附近地点
- (void)showMap:(CDVInvokedUrlCommand*)command;

//地图搜索地点
- (void)searchMap:(CDVInvokedUrlCommand*)command;

//根据经纬度在地图上显示点
- (void)showMapWithCoordinate:(CDVInvokedUrlCommand*)command;

//上报地点汇总
- (void)singCountMap:(CDVInvokedUrlCommand *)command;

//判断定位是否可用
- (void)checkCanLocation:(CDVInvokedUrlCommand *)command;
@end
