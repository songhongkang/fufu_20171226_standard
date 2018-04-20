//
//  AppDelegate+JPush.m
//  delegateExtention
//
//  Created by 张庆贺 on 15/8/3.
//  Copyright (c) 2015年 JPush. All rights reserved.
//

#import "AppDelegate+JPush.h"
#import "JPushPlugin.h"
#import <objc/runtime.h>
#import <AdSupport/AdSupport.h>
//#import <UserNotifications/UserNotifications.h>
#import "JPushDefine.h"

@implementation AppDelegate (JPush)

+(void)load{
    Method origin1;
    Method swizzle1;
    origin1  = class_getInstanceMethod([self class],@selector(init));
    swizzle1 = class_getInstanceMethod([self class], @selector(init_plus));
    method_exchangeImplementations(origin1, swizzle1);
}

-(instancetype)init_plus{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidLaunch:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    return [self init_plus];
}

NSDictionary *_launchOptions;

-(void)applicationDidLaunch:(NSNotification *)notification{
    
    if (notification) {
        if (notification.userInfo) {
            NSDictionary *userInfo1 = [notification.userInfo valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (userInfo1.count > 0) {
                //                [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                //                    if (SharedJPushPlugin) {
                //                        [JPushPlugin fireDocumentEvent:JPushDocumentEvent_OpenNotification jsString:[userInfo1 toJsonString]];
                //                        [timer invalidate];
                //                    }
                //                }];
            }
            NSDictionary *userInfo2 = [notification.userInfo valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
            if (userInfo2.count > 0) {
                //                [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                //                    if (SharedJPushPlugin) {
                //                        [JPushPlugin fireDocumentEvent:JPushDocumentEvent_OpenNotification jsString:[userInfo2 toJsonString]];
                //                        [timer invalidate];
                //                    }
                //                }];
            }
        }
        [JPUSHService setDebugMode];
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:JPushConfig_FileName ofType:@"plist"];
        NSMutableDictionary *plistData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSNumber *delay       = [plistData valueForKey:JPushConfig_Delay];
        
        _launchOptions = notification.userInfo;
        
        if (![delay boolValue]) {
            [self startJPushSDK];
        }
        
    }
}

-(void)startJPushSDK{
    [self registerForRemoteNotification];
    [JPushPlugin setupJPushSDK:_launchOptions];
}

-(void)registerForRemoteNotification{
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
//#ifdef NSFoundationVersionNumber_iOS_9_x_Max
//        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
////        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
//        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
//#endif
//    }else
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else if([[UIDevice currentDevice].systemVersion floatValue] < 8.0){
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

// 应用在运行状态（也就是打卡状态），收到远程推送
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [JPUSHService handleRemoteNotification:userInfo];

    [JPushPlugin fireDocumentEvent:JPushDocumentEvent_ReceiveNotification jsString:[userInfo toJsonString]];
}

//而当程序处于后台或者被杀死状态，收到远程通知后，当你进入(aunch)程序时，调用-

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [JPUSHService handleRemoteNotification:userInfo];
    NSString *eventName;
    
    ///
//    当然，应用不在运行状态，不在考虑之列。只要应用运行起来了，存在以上三种状态。
//    
//    1.UIApplicationStateActive
//    这个基本没什么疑问，应用在前台运行时就是这个状态。
//    
//    2.UIApplicationStateInactive
//    待激活状。在应用运行状态下，可能引起这种状态的情况有
//    a.下接状态栏，看通知
//    b.双击home键，下面弹出任务运行栏
//    c.锁屏。应该程序也非后台状态。
//    
//    3.UIApplicationStateBackground
//    应用在后台状。引起这种状态的情况有：
//    a.按home键
//    b.启动其它应用，把当前应用挤入后台。
    
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateInactive:
            eventName = JPushDocumentEvent_OpenNotification;
            break;
        case UIApplicationStateActive:
            eventName = JPushDocumentEvent_ReceiveNotification;
            break;
        case UIApplicationStateBackground:
            eventName = JPushDocumentEvent_BackgroundNotification;
            break;
        default:
            break;
    }
    
//    NSUserDefaults *defaul = [NSUserDefaults standardUserDefaults];
//    [defaul setObject:[userInfo toJsonString] forKey:@"JPUSH_OPENMESSAGE"];
    
    if ([eventName isEqualToString:JPushDocumentEvent_OpenNotification] && !self.isBackGound) {
        
        self.hk_message = [userInfo toJsonString];

        
//        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC));
//        
//        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//            [JPushPlugin fireDocumentEvent:eventName jsString:[userInfo toJsonString]];
//            completionHandler(UIBackgroundFetchResultNewData);
//        });
//        
    } else {

        [JPushPlugin fireDocumentEvent:eventName jsString:[userInfo toJsonString]];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    
}

-(void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler{
    //    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:notification.request.content.userInfo];
    //    [JPushPlugin fireDocumentEvent:JPushDocumentEvent_ReceiveNotification jsString:[userInfo toJsonString]];
    //    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}

-(void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    //    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:response.notification.request.content.userInfo];
    //    @try {
    //        [userInfo setValue:[response valueForKey:@"userText"] forKey:@"userText"];
    //    } @catch (NSException *exception) { }
    //    [userInfo setValue:response.actionIdentifier forKey:@"actionIdentifier"];
    //    [JPushPlugin fireDocumentEvent:JPushDocumentEvent_OpenNotification jsString:[userInfo toJsonString]];
    //    completionHandler();
}

// 接受到本地推送
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:JPushDocumentEvent_ReceiveLocalNotification object:notification.userInfo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //  [application setApplicationIconBadgeNumber:0];
    //  [application cancelAllLocalNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
      [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    self.isBackGound = YES;
    
    if ([CDVAutosignIn sharedInstance].timer) {
        dispatch_source_cancel([CDVAutosignIn sharedInstance].timer);
    }
    if ([CDVAutosignIn sharedInstance].centralManager) {
        [[CDVAutosignIn sharedInstance].centralManager stopScan];
    }
}

@end
