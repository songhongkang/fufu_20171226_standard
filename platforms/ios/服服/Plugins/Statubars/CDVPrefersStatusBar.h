//
//  CDVPrefersStatusBar.h
//  服服
//
//  Created by 宋宏康 on 2017/6/26.
//
//

#import <Cordova/CDVPlugin.h>

@interface CDVPrefersStatusBar : CDVPlugin
//prefersStatusBar.setstatusBarStyle

- (void)setstatusBarStyle:(CDVInvokedUrlCommand*)command;


/**
 popNative
 
 @param command command description
 */
- (void)popNative:(CDVInvokedUrlCommand *)command;
@end
