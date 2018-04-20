/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  服服
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <UMMobClick/MobClick.h>
#import "JPUSHService.h"
#import "JPushPlugin.h"
#import "JPushDefine.h"
#import "BabyBluetooth.h"
#import "CDVAutosignIn.h"
#import "NSString+Tools.h"
#import "HK_BlueTooth.h"
#import "CDVPlaySound.h"


#define BEACONUUID @"f59edb6a-f399-4c80-a759-d059bf84c96d"
//#define BEACONUUID @"00000000-0111-1222-2333-344444444455"
@interface AppDelegate()

@property (nonatomic,strong) NSUserDefaults *defaults;

@property (nonatomic,assign) BOOL isRemaind;

@end

@implementation AppDelegate

@synthesize window, viewController;

- (id)init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
#if __has_feature(objc_arc)
        NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
#else
        NSURLCache* sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
#endif
    [NSURLCache setSharedURLCache:sharedCache];

    self = [super init];
    return self;
}

#pragma mark UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"paths:%@", paths[0]);
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
   
    [center addObserver:self
               selector:@selector(onNotification:)
                   name:CDVPageDidLoadNotification  // 加载完成
                 object:nil];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

#if __has_feature(objc_arc)
        self.window = [[UIWindow alloc] initWithFrame:screenBounds];
#else
        self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
#endif
    self.window.autoresizesSubviews = YES;

#if __has_feature(objc_arc)
        self.viewController = [[MainViewController alloc] init];
#else
        self.viewController = [[[MainViewController alloc] init] autorelease];
#endif

    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";

    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //友盟
    UMConfigInstance.appKey = @"5832545e76661369980019f6";
    UMConfigInstance.channelId = @"App Store";
    
    NSString *umversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:umversion];
    
    [MobClick startWithConfigure:UMConfigInstance];
    
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;

    // 取出 高德apikey
    NSString *apikey = info[@"GDapikey"];
    [AMapServices sharedServices].apiKey = apikey;
//    [AMapLocationServices sharedServices].apiKey = apikey;
//    [MAMapServices sharedServices].apiKey = apikey;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = nav;

    [self.window makeKeyAndVisible];
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    NSUserDefaults *defaul = [NSUserDefaults standardUserDefaults];

    //JPUSH自定义消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDidReceiveMessage:)
                                                 name:kJPFNetworkDidReceiveMessageNotification
                                               object:nil];
    
    //根据版本号来判断是否对www文件夹更新
    NSString *version = [defaul objectForKey:@"version"];
    
    if (![version isEqualToString:currentVersion]|| version.length == 0) {
        dispatch_queue_t queue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_sync(queue, ^{
            [self copyHtmlFile];
        });
        
        [defaul setObject:currentVersion forKey:@"version"];
    }
    
    

    
    return YES;
}

// this happens while we are running ( in the background, or from within our own app )
// only valid if 服服-Info.plist specifies a protocol to handle
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    if (!url) {
        return NO;
    }
    return YES;
}

// repost all remote and local notification using the default NSNotificationCenter so multiple plugins may respond
- (void)            application:(UIApplication*)application
    didReceiveLocalNotification:(UILocalNotification*)notification
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

#ifndef DISABLE_PUSH_NOTIFICATIONS

    - (void)                                 application:(UIApplication*)application
        didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
    {
        // re-post ( broadcast )
        NSString* token = [[[[deviceToken description]
            stringByReplacingOccurrencesOfString:@"<" withString:@""]
            stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];

        [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:token];
    }

    - (void)                                 application:(UIApplication*)application
        didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
    {
        // re-post ( broadcast )
        [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotificationError object:error];
    }
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
#else
- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
#endif
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);

//    return supportedInterfaceOrientations;
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)copyHtmlFile {
    //源路径
    NSString *sourcepath;
    NSFileManager *fm;
    NSDirectoryEnumerator *dirEnum;

    NSString *firstPath = nil;
    NSString *sonPath = nil;
    
    fm = [NSFileManager defaultManager];
    //获取当前的工作目录的路径
    sourcepath = [fm currentDirectoryPath];
    
    NSString *locaPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
      locaPath = [locaPath stringByAppendingPathComponent:@"NoCloud/www"];
     NSError *error= nil;
        //先删除文件在拷备
        if ([fm fileExistsAtPath:locaPath]) {
            [fm removeItemAtPath:locaPath error:&error];
        }
    
    if (![fm fileExistsAtPath:locaPath]) {
        sourcepath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"www"] ;
        //遍历这个目录的第一种方法：（深度遍历，会递归枚举它的内容）
        dirEnum = [fm enumeratorAtPath:sourcepath];
        
        firstPath = [NSString stringWithFormat:@"%@/",sourcepath];
        BOOL isDir = NO;
        while ((sourcepath = [dirEnum nextObject]) != nil)
        {
            Boolean isExite = [fm fileExistsAtPath:[firstPath stringByAppendingPathComponent:sourcepath] isDirectory:&isDir];
            if(isExite && isDir)//是文件夹
            {
                if (![fm fileExistsAtPath:[locaPath stringByAppendingPathComponent:sourcepath]]) {
                    [fm createDirectoryAtPath:[locaPath stringByAppendingPathComponent:sourcepath] withIntermediateDirectories:YES attributes:nil error:nil];
                    sonPath = [locaPath stringByAppendingPathComponent:sourcepath];
                }
            } else {
                NSData *content = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@%@",firstPath,sourcepath]];
                if (content != nil) {
                    [content writeToFile:[NSString stringWithFormat:@"%@/%@",locaPath,sourcepath] atomically:YES];
                }
                
            }
            
        }

    }
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
       return YES;
}

- (void)networkDidReceiveMessage:(NSNotification *)notification{    
    if (_isCordovaInit) {
        if (notification && notification.userInfo) {
            [JPushPlugin fireDocumentEvent:JPushDocumentEvent_ReceiveMessage jsString:[notification.userInfo  toJsonString]];
        }
    }else{
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            if (notification && notification.userInfo) {
                [JPushPlugin fireDocumentEvent:JPushDocumentEvent_ReceiveMessage jsString:[notification.userInfo  toJsonString]];
            }
        });
    }
}
    
// 程序变成活跃状态
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    int second = [NSString shijianCha:[CDVAutosignIn sharedInstance].currentData withSecondTime:[NSString  getCurrentTimes]];
//    NSLog(@"currentData------->%@\n,getCurrentTimes----->%@\n,second----->%d\n",[CDVAutosignIn sharedInstance].currentData,[NSString getCurrentTimes],second);
    second =  abs(second);

    if (second > 60 && [CDVAutosignIn sharedInstance].isRegionSN) {
        // 这里把时间赋值给当前时间,就是在倒计时哪里用到了，如果不赋值成初始时间，倒计时的时间大于60分钟，会提示离开状态
        // 必须要把时间设置成 当前时间，应为下面我开启定时器，如果不设置，定时器的时间差大于60，提示离开。
        // 1.把当前时间变量初始化
        [CDVAutosignIn sharedInstance].currentData =    [NSString getCurrentTimes];
        // 2.flag设置成空
        [CDVAutosignIn sharedInstance].isRegionSN = nil;
    }
    
    if ([CDVAutosignIn sharedInstance].isBleOff) {
        if (![CDVAutosignIn sharedInstance].closeState
            || [[CDVAutosignIn sharedInstance].closeState isEqualToString:@"2"]) {
            [[CDVAutosignIn sharedInstance] createCountDown];
            [CDVAutosignIn sharedInstance].isTimerOff = YES;
            [[CDVAutosignIn sharedInstance] hk_startBle];
        }
    }else{
        [CDVAutosignIn sharedInstance].isTimerOff = NO;
    }
}

-  (void)applicationWillTerminate:(UIApplication *)application
{
    [CDVAutosignIn sharedInstance].isRegionSN = nil;
    [CDVAutosignIn sharedInstance].currentData = nil;
    NSLog(@"应用程序将要退出，通常用于保存数据和一些退出前的清理工作");
}

- (void)onNotification:(NSNotification *)notification {
    NSLog(@"onNotification");
    _isCordovaInit  = YES;
    [CDVAutosignIn sharedInstance].isRegionSN = nil;
    [self listenNetWorkingStatus]; //监听网络是否可用
}

#pragma mark - 监听网络变化
-(void)listenNetWorkingStatus{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    // 设置网络检测的站点
    NSString *remoteHostName = @"www.apple.com";
    
    self.hostReachability = [CDVReachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [CDVReachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

- (void) reachabilityChanged:(NSNotification *)note
{
    CDVReachability* curReach = [note object];
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(CDVReachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus) {
        case 0:
            if (!_isNotNet) {
                NSLog(@"NotReachable----无网络");
                _isNet = YES;
            }
            break;
        default:
            if (_isNet) {
                NSLog(@"NotReachable----有网络");
                _isNet = NO;
                int second = [NSString shijianCha:[CDVAutosignIn sharedInstance].currentData withSecondTime:[NSString  getCurrentTimes]];
                
                NSLog(@"currentData------->%@\n,getCurrentTimes----->%@\n,second----->%d\n",[CDVAutosignIn sharedInstance].currentData,[NSString getCurrentTimes],second);
                
                if (second < 60) {

                }else{
                    if ([CDVAutosignIn sharedInstance].isRegionSN) {
                        [CDVAutosignIn sharedInstance].isRegionSN = nil;
                    }
                }
            }
            break;
    }
}

@end
