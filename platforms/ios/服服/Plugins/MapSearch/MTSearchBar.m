//
//  MTSearchBar.m
//  服服
//
//  Created by shangzh on 16/6/17.
//
//

#import "MTSearchBar.h"

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation MTSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.font = [UIFont systemFontOfSize:15];
        self.placeholder = @"请输入查询条件";
        self.layer.cornerRadius = 4;
        self.layer.borderWidth = 1;
        self.layer.borderColor = kUIColorFromRGB(0xf0f0f0).CGColor;
        self.textColor = [UIColor blackColor];
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.returnKeyType = UIReturnKeySearch;
        self.font = [UIFont systemFontOfSize:14];
        self.backgroundColor = [UIColor whiteColor];
    
        // 提前在Xcode上设置图片中间拉伸
//        self.background = [UIImage imageNamed:@"searchbar_textfield_background"];
        // 通过init初始化的控件大多都没有尺寸
        UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        searchIcon.image = [UIImage imageNamed:@"ion-search"];
        // contentMode：default is UIViewContentModeScaleToFill，要设置为UIViewContentModeCenter：使图片居中，防止图片填充整个imageView
        searchIcon.contentMode = UIViewContentModeCenter;
        searchIcon.frame = CGRectMake(0, 0, 20, 20);
        
        self.leftView = searchIcon;
        self.leftViewMode = UITextFieldViewModeAlways;
        
    }
    return self;
}

+(instancetype)searchBar
{
    return [[self alloc] init];
}


- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    [super leftViewRectForBounds:bounds];
    CGRect rect = CGRectMake(6, 6, 20,20);
    
    return rect;
}

@end
