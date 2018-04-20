//
//  VC_Scan.h
//  服服
//
//  Created by 宋宏康 on 2017/8/25.
//
//

#import <UIKit/UIKit.h>

@protocol ScanVCDelegate;

@interface VC_Scan : UIViewController
/** 代理对象 */
@property (nonatomic, weak )id <ScanVCDelegate>delegate;

@end

@protocol ScanVCDelegate <NSObject>
/**
 扫描成功的回调方法
 
 @param result 扫描的结果
 */
- (void)hk_ScanSuccess:(NSString *)result;
/**
 扫描失败的回调方法
 */
- (void)hk_ScanFaild;
/**
 扫描超时的回调
 */
@optional
- (void)hk_TimeOut;
@end

