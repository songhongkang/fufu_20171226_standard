//
//  CDVAlertMessageView.m
//  Test
//
//  Created by shangzh on 17/3/1.
//  Copyright © 2017年 shangzh. All rights reserved.
//

#import "CDVAlertMessageView.h"
#import "Constan.h"

@interface CDVAlertMessageView()

@property (nonatomic,strong) UIView *HUD;

@property (nonatomic,strong) UIView *containerView;

@property (nonatomic,strong) UIView *separatorView;

@property (nonatomic,strong) UIView *separatorViewTwo;

@property (nonatomic,strong) UIView *buttonView;

@property (nonatomic,strong) UIView *middleView;

@property (nonatomic,strong) UILabel *labTitle;

@property (nonatomic,strong) UILabel *labMessage;

@property (nonatomic,strong) UIButton *btnOk;

@end

@implementation CDVAlertMessageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message  okButtonTitle:(NSString *)okBtnTil textType:(TextType)textType delegate:(id<CDVAlertMessageViewDelegate>) delegate {
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (self) {
        
        CGFloat containWidth = [UIScreen mainScreen].bounds.size.width * 0.72;
        
        CGSize size = [self boundingRectWithSize:CGSizeMake(containWidth - 40, MAXFLOAT) text:message];
        CGFloat space = 0;
        
        self.backgroundColor = [kUIColorFromRGB(0x000000) colorWithAlphaComponent:0.55];
        
        space = size.height-10;
        
        self.delegate = delegate;
        
        self.HUD = [[UIView alloc] initWithFrame:self.bounds];
        self.HUD.backgroundColor = [UIColor whiteColor];
        self.HUD.alpha = 0;
        [self addSubview:self.HUD];
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containWidth, 139+space)];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.cornerRadius = 10;
        self.containerView.clipsToBounds = YES;
        
        CGRect cnvwFrame = self.containerView.bounds;
        cnvwFrame.origin.x = self.frame.size.width / 2 - (cnvwFrame.size.width/2);
        cnvwFrame.origin.y = self.frame.size.height / 2 - (cnvwFrame.size.height/2);
        self.containerView.frame = cnvwFrame;
        [self addSubview:self.containerView];
        
        CGRect cvFrame = self.containerView.bounds;
        
        //Separator View create
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y+94+space, cvFrame.size.width, 0.5)];
        self.separatorView.backgroundColor = kUIColorFromRGB(0xf5f5f5);
        [self.containerView addSubview:self.separatorView];
        
        //Title label
        self.labTitle = [[UILabel alloc] initWithFrame:CGRectMake(cvFrame.origin.x+20, cvFrame.origin.y+20, cvFrame.size.width - 40, 22)];
        self.labTitle.numberOfLines = 1;
        self.labTitle.text = title;
        self.labTitle.textColor = kUIColorFromRGB(0x000000);
        self.labTitle.textAlignment = NSTextAlignmentCenter;
        
        self.labTitle.font = [UIFont systemFontOfSize:17];
        
        [self.containerView addSubview:self.labTitle];
        
        self.labMessage = [[UILabel alloc] initWithFrame:CGRectMake(cvFrame.origin.x+20, cvFrame.origin.y+35+self.labTitle.bounds.size.height, cvFrame.size.width - 40, 20+space)];
        self.labMessage.textColor = kUIColorFromRGB(0x333333);
        self.labMessage.font = [UIFont systemFontOfSize:15];
        if (textType == TextCenter) {
            self.labMessage.textAlignment = NSTextAlignmentCenter;
        } else {
            self.labMessage.textAlignment = NSTextAlignmentLeft;
        }
        
        self.labMessage.numberOfLines = 0;
        
        self.labMessage.text = message;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:6.0f];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];
        
        self.labMessage.attributedText = attributedString;
        
        [self.labMessage sizeToFit];
        
//        self.labMessage.lineBreakMode = UILineBreakModeWordWrap;
        
        [self.containerView addSubview:self.labMessage];
        
            self.btnOk = [[UIButton alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y + 95 + space, cvFrame.size.width, 44)];
            [self.btnOk setTitle:okBtnTil forState:UIControlStateNormal];
            [self.btnOk setBackgroundImage:[UIImage imageNamed:@"line"] forState:UIControlStateHighlighted];
            [self.btnOk setTitleColor:kUIColorFromRGB(0x53afff) forState:UIControlStateNormal];
            self.btnOk.titleLabel.font = [UIFont systemFontOfSize:16];
            [self.btnOk.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [self.containerView addSubview:self.btnOk];
            [self.btnOk addTarget:self action:@selector(messageAcceptAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
    }
    
    return self;
}

- (void)messageAcceptAction:(UIButton *)btn {
//    btn.backgroundColor = [UIColor redColor];
    if ([self.delegate respondsToSelector:@selector(popUpView:accepted:)]) {
        [self.delegate popUpView:self accepted:YES];
    }
    [self hide];
    
}

- (void)showInView:(UIView *)view {
    self.containerView.alpha = 1;
    [view addSubview:self];
}

- (void)hide {
    self.containerView.alpha = 0;
    self.alpha = 0;
    [self removeFromSuperview];
}

- (CGSize)boundingRectWithSize:(CGSize)size text:(NSString *)text
{
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    CGSize retSize = [text boundingRectWithSize:size
                                        options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
    return retSize;
}

@end
