//
//  SearchMapViewController.h
//  服服
//
//  Created by shangzh on 16/6/15.
//
//

#import <UIKit/UIKit.h>
@class MapModel;

@protocol SearchMapViewControllerDelegate <NSObject>

- (void)selectedAddress:(MapModel *)model;

@end

@interface SearchMapViewController : UIViewController

//已经选择的地址
@property (nonatomic,strong) MapModel *oldAddress;

@property (nonatomic,assign) CGFloat latitude;
@property (nonatomic,assign) CGFloat longitude;

@property (nonatomic,retain) id<SearchMapViewControllerDelegate> delegate;

@end
