//
//  ImageUploadBottomView.m
//  服服
//
//  Created by shangzh on 16/10/28.
//
//

#import "ImageUploadBottomView.h"
#import "Constan.h"

@implementation ImageUploadBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [kUIColorFromRGB(0xffffff) colorWithAlphaComponent:0.9];
        self.rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 95, 7.5, 90, 30)];
        [self.rightBtn setBackgroundColor:kUIColorFromRGB(0x53afff)];
        [self.rightBtn setTitle:@"完成(0/0)" forState:UIControlStateNormal];
        [self.rightBtn setTitleColor:kUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [self.rightBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        self.rightBtn.layer.cornerRadius = 4;
//        [self.rightBtn addTarget:self action:@selector(uploadImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightBtn];
    }
    
    return self;
}

////返回选择的图片
//- (void)uploadImage {
//    NSLog(@"uplpad image==");
//}

@end
