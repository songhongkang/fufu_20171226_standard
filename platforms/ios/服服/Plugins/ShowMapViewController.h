//
//  ShowMapViewController.h
//  服服
//
//  Created by shangzh on 16/5/25.
//
//

#import <UIKit/UIKit.h>

@class MapModel;

@protocol ShowMapViewControllerDelegate <NSObject>

- (void)selectedAdderess:(NSString *)address latitude:(CGFloat)latitude longitude:(CGFloat)longitude city:(NSString *)city detailAddress:(NSString *)detailAddress;

@end

@interface ShowMapViewController : UIViewController
@property (nonatomic,assign) CGFloat latitude;
@property (nonatomic,assign) CGFloat longitude;
@property (nonatomic,copy) NSString *oldAddress;
@property (nonatomic,retain) id<ShowMapViewControllerDelegate> delegate;

//记录上次选择的地址
@property (nonatomic,strong) MapModel *selecteModel;

@end
