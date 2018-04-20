//
//  CustomerImageView.h
//  服服
//
//  Created by shangzh on 16/6/18.
//
//

#import <UIKit/UIKit.h>

@interface CustomerImageView : UIView
@property (nonatomic, copy) NSString *addressTitle; //地址
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *imageView;
@end
