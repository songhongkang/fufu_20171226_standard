//
//  CustomeNaigationViewController.m
//  服服
//
//  Created by shangzh on 16/6/18.
//
//

#import "CustomeNaigationViewController.h"

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CustomeNaigationViewController ()

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIButton *backBtn;

//无效变量
@property (nonatomic,copy) NSString *test;

@end

@implementation CustomeNaigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.barTintColor = kUIColorFromRGB(0x53afff);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:YES];

        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        leftBarBtn.width = 16;
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    
    negativeSpacer.width = -10;
    UIButton *backBtnTwo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    UIBarButtonItem *leftBarBtnTwo = [[UIBarButtonItem alloc] initWithCustomView:backBtnTwo];
    
    viewController.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBarBtn,leftBarBtnTwo];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:@"地图"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:17]];
    [titleLabel sizeToFit];
    
    viewController.navigationItem.titleView = titleLabel;
    
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
