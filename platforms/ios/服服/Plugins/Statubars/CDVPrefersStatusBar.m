//
//  CDVPrefersStatusBar.m
//  服服
//
//  Created by 宋宏康 on 2017/6/26.
//
//

#import "CDVPrefersStatusBar.h"

@interface CDVPrefersStatusBar ()

@property (nonatomic,copy) NSString *callID;

@property (nonatomic,strong) CDVPluginResult *result;

@end

@implementation CDVPrefersStatusBar

- (void)setstatusBarStyle:(CDVInvokedUrlCommand*)command
{
    NSString *colorString = [command argumentAtIndex:0];
    if ([colorString isEqualToString:@"black"]) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    if ([colorString isEqualToString:@"white"]) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)popNative:(CDVInvokedUrlCommand *)command
{
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

@end
