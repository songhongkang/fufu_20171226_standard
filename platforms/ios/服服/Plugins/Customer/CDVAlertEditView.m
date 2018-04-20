//
//  CDVAlertView.m
//  服服
//
//  Created by shangzh on 17/2/28.
//
//

#import "CDVAlertEditView.h"
#import "Constan.h"

@interface CDVAlertEditView()

@property (nonatomic,strong) UIView *HUD;

@property (nonatomic,strong) UIView *containerView;

@property (nonatomic,strong) UIView *separatorView;

@property (nonatomic,strong) UIView *separatorViewTwo;

@property (nonatomic,strong) UIView *buttonView;

@property (nonatomic,strong) UIView *middleView;

@property (nonatomic,strong) UILabel *labTitle;

@property (nonatomic,strong) UILabel *labMessage;

@property (nonatomic,strong) UIButton *btnOk;

@property (nonatomic,strong) UIButton *btnCancel;

@property (nonatomic,strong) UIView *txtBackView;

@property (nonatomic,strong) UITextView *txtField;

@end

@implementation CDVAlertEditView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithTitle:(NSString *)title txtFiedl:(NSString *)txtfiedl  okButtonTitle:(NSString *)okBtnTil cancelButtonTItle:(NSString *)cancelBtnTil delegate:(id<CDVAlertEditViewDelegate>)delegate {
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (self) {
        
        self.delegate = delegate;
        
        CGSize size = [self boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 25) text:txtfiedl];
    
        self.backgroundColor = [kUIColorFromRGB(0x000000) colorWithAlphaComponent:0.55];
        
        self.HUD = [[UIView alloc] initWithFrame:self.bounds];
        self.HUD.backgroundColor = [UIColor whiteColor];
        self.HUD.alpha = 0;
        [self addSubview:self.HUD];
        
        CGFloat space = 0;
        CGFloat containWidth = [UIScreen mainScreen].bounds.size.width * 0.72;
        if (size.width > (containWidth - 30)) {
            space = 20;
        }
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containWidth, 160+space)];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.alpha = 1;
        self.containerView.layer.cornerRadius = 10;
        self.containerView.clipsToBounds = YES;
        
        CGRect cnvwFrame = self.containerView.bounds;
        cnvwFrame.origin.x = self.frame.size.width / 2 - (cnvwFrame.size.width/2);
        cnvwFrame.origin.y = self.frame.size.height / 2 - (cnvwFrame.size.height/2);
        self.containerView.frame = cnvwFrame;
        [self addSubview:self.containerView];
        
        CGRect cvFrame = self.containerView.bounds;
        

        //Title label
        self.labTitle = [[UILabel alloc] initWithFrame:CGRectMake(cvFrame.origin.x+20, cvFrame.origin.y+22, cvFrame.size.width - 40, 22)];
        self.labTitle.numberOfLines = 1;
        self.labTitle.text = title;
        self.labTitle.textColor = kUIColorFromRGB(0x000000);
        self.labTitle.textAlignment = NSTextAlignmentCenter;
    
        self.labTitle.font = [UIFont systemFontOfSize:17];
        
        [self.containerView addSubview:self.labTitle];
        
//        //TextViewBackGroundView
        self.txtBackView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x+20, cvFrame.origin.y+40+self.labTitle.bounds.size.height, cvFrame.size.width - 40, 34+space)];
        
        self.txtBackView.layer.cornerRadius = 4;
        self.txtBackView.clipsToBounds = YES;
        self.txtBackView.layer.borderWidth = 0.5;
        self.txtBackView.layer.borderColor = kUIColorFromRGB(0xf0f0f0).CGColor;
        [self.containerView addSubview:self.txtBackView];
//
//        //TextField
        self.txtField = [[UITextView alloc] initWithFrame:CGRectMake(cvFrame.origin.x+25, cvFrame.origin.y+41+self.labTitle.bounds.size.height, cvFrame.size.width - 50, 30+space)];
//  
//        self.txtField.backgroundColor = [UIColor blueColor];
//        self.txtField.layer.cornerRadius = 4;
//        self.txtField.clipsToBounds = YES;
//        self.txtField.layer.borderWidth = 0.5;
//        self.txtField.layer.borderColor = kUIColorFromRGB(0xf0f0f0).CGColor;
        self.txtField.textColor = kUIColorFromRGB(0x333333);
        self.txtField.font = [UIFont systemFontOfSize:14];
        self.txtField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.txtField.delegate = self;
        
        self.txtField.text = txtfiedl;
        [self.containerView addSubview:self.txtField];
        

//
//        //Button View create
//        self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y + 136, cvFrame.size.width, cvFrame.size.height - 136)];
//        [self.containerView addSubview:self.buttonView];
        
        //Action button create
        self.btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y + 116+space, cvFrame.size.width/2-0.5, 44)];
        [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"line"] forState:UIControlStateHighlighted];
        [self.btnCancel setTitle:cancelBtnTil forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:kUIColorFromRGB(0x53afff) forState:UIControlStateNormal];
        self.btnCancel.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.btnCancel.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.containerView addSubview:self.btnCancel];
        [self.btnCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //Separator View create
        self.separatorViewTwo = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x+self.btnCancel.frame.size.width, cvFrame.origin.y+116+space, 0.5, 44)];
        self.separatorViewTwo.backgroundColor = kUIColorFromRGB(0xf5f5f5);
        [self.containerView addSubview:self.separatorViewTwo];
        
        self.btnOk = [[UIButton alloc] initWithFrame:CGRectMake(self.btnCancel.frame.origin.x+self.btnCancel.frame.size.width+0.5, cvFrame.origin.y+116+space, cvFrame.size.width/2, 44)];
        [self.btnOk setBackgroundImage:[UIImage imageNamed:@"line"] forState:UIControlStateHighlighted];
        [self.btnOk setTitle:okBtnTil forState:UIControlStateNormal];
        [self.btnOk setTitleColor:kUIColorFromRGB(0x53afff) forState:UIControlStateNormal];
        self.btnOk.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.btnOk.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.containerView addSubview:self.btnOk];
        [self.btnOk addTarget:self action:@selector(acceptAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //Separator View create
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y+116+space, cvFrame.size.width, 0.5)];
        self.separatorView.backgroundColor = kUIColorFromRGB(0xf5f5f5);
        [self.containerView addSubview:self.separatorView];
        
//        self.middleView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x, self.separatorView.frame.origin.y+self.separatorView.frame.size.height, cvFrame.size.width, self.btnOk.frame.origin.y)];
//        self.middleView.backgroundColor = [UIColor whiteColor];
        [self.containerView insertSubview:self.middleView belowSubview:self.txtField];
    }
    
    return self;
}

- (void)setFieldText:(NSString *)fieldText{
    self.txtField.text = fieldText;
}

- (void)acceptAction:(UIButton *)btn {
    btn.backgroundColor = [UIColor redColor];
    [self hide];
    if ([self.delegate respondsToSelector:@selector(popUpView:accepted:inputText:)]) {
        [self.delegate popUpView:self accepted:YES inputText:self.txtField.text];
    }
    
}

- (void)cancelAction:(UIButton *)btn {
    btn.backgroundColor = [UIColor redColor];
    [self hide];
    if ([self.delegate respondsToSelector:@selector(popUpView:accepted:inputText:)]) {
        [self.delegate popUpView:self accepted:NO inputText:self.txtField.text];
    }
}

- (void)showInView:(UIView *)view {
    self.containerView.alpha = 1;
    [view addSubview:self];
}

- (void)hide {
//    if ([self.txtField isEditing]) {
        [self.txtField resignFirstResponder];
//    }
    
    self.containerView.alpha = 0;
    self.alpha = 0;
    self.hidden = YES;
//    [self removeFromSuperview];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if ([self.txtField isEditing]) {
        [self.txtField resignFirstResponder];
//    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *txt = [textView text];
    
    CGRect cvFrame = self.containerView.bounds;
    CGFloat containWidth = [UIScreen mainScreen].bounds.size.width * 0.72;
    
    CGSize size = [self boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 25) text:txt];
    if (size.width > (self.containerView.bounds.size.width - 30)) {
        if (self.txtField.bounds.size.height == 30) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, 190);
                [self.containerView setFrame:frame];
                
                [self.separatorView setFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y+116+29, cvFrame.size.width, 1)];
            
                [self.txtBackView setFrame:CGRectMake(cvFrame.origin.x+20, cvFrame.origin.y+40+self.labTitle.bounds.size.height, cvFrame.size.width - 40, 34+34)];
                
                [self.btnCancel setFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y + 116+30, cvFrame.size.width/2-0.5, 44)];
                
                [self.btnOk setFrame:CGRectMake(self.btnCancel.frame.origin.x+self.btnCancel.frame.size.width+0.5, cvFrame.origin.y+116+30, cvFrame.size.width/2, 44)];
                
                [self.separatorViewTwo setFrame:CGRectMake(cvFrame.origin.x+self.btnCancel.frame.size.width, cvFrame.origin.y+116+30, 0.5, 44)];
                
                [self.txtField setFrame:CGRectMake(cvFrame.origin.x+25, cvFrame.origin.y+46+self.labTitle.bounds.size.height, cvFrame.size.width - 50, 48)];
            }];
        }
    } else {
        if (self.txtField.bounds.size.height == 50) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, 160);
                [self.containerView setFrame:frame];
                
                [self.separatorView setFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y+116, cvFrame.size.width, 1)];
           
                [self.txtBackView setFrame:CGRectMake(cvFrame.origin.x+20, cvFrame.origin.y+40+self.labTitle.bounds.size.height, cvFrame.size.width - 40, 34)];
                
                [self.btnCancel setFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y + 116, cvFrame.size.width/2-0.5, 44)];
                
                [self.btnOk setFrame:CGRectMake(self.btnCancel.frame.origin.x+self.btnCancel.frame.size.width+0.5, cvFrame.origin.y+116, cvFrame.size.width/2, 44)];
                
                [self.separatorViewTwo setFrame:CGRectMake(cvFrame.origin.x+self.btnCancel.frame.size.width, cvFrame.origin.y+116, 0.5, 44)];
                
                [self.txtField setFrame:CGRectMake(cvFrame.origin.x+25, cvFrame.origin.y+41+self.labTitle.bounds.size.height, cvFrame.size.width - 50, 30)];
                
            }];
        }
    }
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
