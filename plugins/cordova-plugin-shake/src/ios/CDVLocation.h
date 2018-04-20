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

- (void)location:(CDVInvokedUrlCommand*)command;

@end
