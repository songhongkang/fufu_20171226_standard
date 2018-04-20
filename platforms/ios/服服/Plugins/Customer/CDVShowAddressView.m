//
//  CDVShowAddressView.m
//  服服
//
//  Created by shangzh on 16/7/31.
//
//

#import "CDVShowAddressView.h"

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CDVShowAddressView()

@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) UILabel *addressLabel;

@end

@implementation CDVShowAddressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    
    UILabel *rect = [[UILabel alloc] initWithFrame:CGRectMake(20, 17, 16, 16)];
    rect.backgroundColor = kUIColorFromRGB(0x53afff);
    rect.layer.masksToBounds = YES;
    rect.layer.cornerRadius = 8;
    [self addSubview:rect];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 40, 50)];
    self.timeLabel.text = self.time;
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.timeLabel];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 1, 30)];
    line.backgroundColor = kUIColorFromRGB(0x53afff);
    [self addSubview:line];
    
    self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, self.bounds.size.width-130, 50)];

    self.addressLabel.text = self.address;
    self.addressLabel.textColor = [UIColor blackColor];
    self.addressLabel.font = [UIFont systemFontOfSize:14];
    self.addressLabel.numberOfLines = 2;
    [self addSubview:self.addressLabel];
    
}

- (void)setTime:(NSString *)time {
    self.timeLabel.text = time;
}

- (void)setAddress:(NSString *)address {
    self.addressLabel.text = address;
}

@end
