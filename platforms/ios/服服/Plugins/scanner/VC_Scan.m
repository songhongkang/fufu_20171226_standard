//
//  VC_Scan.m
//  服服
//
//  Created by 宋宏康 on 2017/8/25.
//
//

#import "VC_Scan.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "UIView+Positioning.h"
#import "HK_BlueTooth.h"
#import "CDVAutosignIn.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CDVAlertMessageView.h"
#import "Constan.h"
#import<AVFoundation/AVCaptureDevice.h>
#import<AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVFoundation.h>
#import "JPushPlugin.h"
#import "Constan.h"

/** 二维码扫描关闭 */

@interface VC_Scan () <AVCaptureMetadataOutputObjectsDelegate,CDVAlertMessageViewDelegate>
/** 二维码扫描相关的类   参考:http://www.jianshu.com/p/d6663245d3fa */
@property (nonatomic,strong)  AVCaptureSession *session;
/** 中心的边框图片 */
@property (nonatomic, strong) UIImageView *borderImgView;
/** 中心移动的图片*/
@property (nonatomic, strong) UIImageView *moveImgView;
/** 底部的label控件*/
@property (nonatomic, strong) UILabel *bottomLabel;
/** 扫描成功的字符串*/
@property (nonatomic, strong) NSString *reultString;

@end

@implementation VC_Scan

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 设置导航栏左边的按钮
    [self createLeftNavigationItem];
    // 设置导航栏的title
    [self createTitleNavigationItem];
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied ||
        authStatus == AVAuthorizationStatusRestricted) {
        [self setupUI];
        CDVAlertMessageView *message = [[CDVAlertMessageView alloc] initWithTitle:@"允许访问照片" message:@"进入系统【设置】>【隐私】>【照片】中打开开关，并允许服服访问照片" okButtonTitle:@"立即开启" textType:TextLeft delegate:self];
        [message showInView:self.view];
    }else{
        [self scan];
    }
}

- (void)createTitleNavigationItem
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UILabel *label = [UILabel new];
    label.text = @"扫描设备";
    label.textColor  = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:17];
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

- (void)createLeftNavigationItem
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc ] initWithCustomView:button];
    [button addTarget:self action:@selector(cancleBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
}

-(void)scan
{
    // 1. 实例化拍摄设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2. 设置输入设备
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3. 设置元数据输出
    // 3.1 实例化拍摄元数据输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置扫描区域
    //        output.rectOfInterest = CGRectMake(CGRectGetMinX(BOX_FRAME)/CGRectGetWidth(frame), CGRectGetMinY(BOX_FRAME)/CGRectGetHeight(frame), CGRectGetMaxX(BOX_FRAME)/CGRectGetWidth(frame),CGRectGetMaxY(BOX_FRAME)/CGRectGetHeight(frame));
    // 3.3 设置输出数据代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 4. 添加拍摄会话
    // 4.1 实例化拍摄会话
    _session = [[AVCaptureSession alloc] init];
    
    // 4.2 添加会话输入
    [_session addInput:input];
    
    // 4.3 添加会话输出
    [_session addOutput:output];
    // 4.3 设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    // 5. 视频预览图层
    // 5.1 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.bounds;
    // 5.2 将图层插入当前视图
    [self.view.layer addSublayer:preview];
    // 6. 启动会话
    [_session startRunning];
    
    [self setupUI];
}

- (void)setupUI
{
    // 1 扫描二维码的边框
    _borderImgView = [[UIImageView alloc]init];
    _borderImgView.image = [UIImage imageNamed:@"扫一扫描边"];
    _borderImgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_borderImgView];
    [_borderImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    [self.view layoutIfNeeded];
    
    // 2 移动的网格图片
    _moveImgView = [[UIImageView alloc] init];
    _moveImgView.image = [UIImage imageNamed:@"scanningProcess"];
    _moveImgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_moveImgView];
    [_moveImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_borderImgView.mas_top);
        make.left.equalTo(_borderImgView.mas_left);
        make.width.equalTo(@217);
        make.height.equalTo(@1);
    }];
    [self.view layoutIfNeeded];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scanAnimation];
    });
    
    //4.阴影
    // *******************阴影***********************//
    UIBezierPath *path3 =  [[UIBezierPath alloc] init];
    // 起点
    [path3 moveToPoint:CGPointMake(0, 0)];
    [path3 addLineToPoint:CGPointMake(0, CGRectGetHeight(self.view.frame))];
    [path3 addLineToPoint:CGPointMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [path3 addLineToPoint:CGPointMake(CGRectGetWidth(self.view.frame), 0)];
    [path3 addLineToPoint:CGPointMake(0, 0)];
    
    
    [path3 moveToPoint:CGPointMake(_borderImgView.x, _borderImgView.y)];
    [path3 addLineToPoint:CGPointMake(_borderImgView.x,_borderImgView.bottom)];
    [path3 addLineToPoint:CGPointMake(CGRectGetWidth(self.view.frame)-(_borderImgView.x ),_borderImgView.bottom)];
    [path3 addLineToPoint:CGPointMake(CGRectGetWidth(self.view.frame)-_borderImgView.x, _borderImgView.y)];
    [path3 addLineToPoint:CGPointMake(_borderImgView.x, _borderImgView.y)];
    
    CAShapeLayer *shapeLayer3 = [CAShapeLayer layer];
    shapeLayer3.strokeColor = [UIColor clearColor].CGColor;
    shapeLayer3.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    //    shapeLayer3.fillColor = [UIColor redColor].CGColor;
    shapeLayer3.fillRule = kCAFillRuleEvenOdd;
    shapeLayer3.path = path3.CGPath;
    [self.view.layer addSublayer:shapeLayer3];
    // ******************阴影***********************//
    
    // 3.底部的label
    _bottomLabel = [[UILabel alloc] init];
    _bottomLabel.textColor = [UIColor whiteColor];
    _bottomLabel.font = [UIFont systemFontOfSize:12];
    _bottomLabel.text =  @"将二维码/条形码放入框内，即可自动扫描";
    [self.view addSubview:_bottomLabel];
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_borderImgView.mas_bottom).offset(8);
    }];
}

// 扫描动画
- (void)scanAnimation
{
    [_moveImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@215);
    }];
    [UIView animateWithDuration:2.0f animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark delegateMethod

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 1. 如果扫描完成，停止会话
    [_session stopRunning];
    if (metadataObjects.count > 0)
    {
        // 2.扫描成功
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSLog(@"%@",obj.stringValue);
        self.reultString = obj.stringValue;
        [[CDVAutosignIn sharedInstance].centralManager stopScan];
        if ([CDVAutosignIn sharedInstance].timer) {
            dispatch_source_cancel([CDVAutosignIn sharedInstance].timer);
        }
        
        if ([self.delegate respondsToSelector:@selector(hk_ScanSuccess:)]) {
            [self.delegate hk_ScanSuccess:self.reultString];
        }
    }else{
        // 3.扫描失败
        if ([self.delegate respondsToSelector:@selector(hk_ScanFaild)]) {
            [self.delegate hk_ScanFaild];
        }
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - btnClick
- (void)cancleBtn:(UIButton *)sender
{
    NSLog(@"cancleBtn");
//    [self.navigationController popViewControllerAnimated:YES];
//    [JPushPlugin hk_monitorBlueToothStates:QR_SCAN_CLOSE withSn:@""];
    if ([self.delegate respondsToSelector:@selector(hk_ScanFaild)]) {
        [self.delegate hk_ScanFaild];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -  CDVAlertMessageViewDelegate

- (void)popUpView:(CDVAlertMessageView *)view accepted:(BOOL)accept {
    if (Version >= 8.0f) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else {
        NSString *destPath = [NSString stringWithFormat:@"prefs:root=Privacy"];
        NSURL*url2=[NSURL URLWithString:destPath];
        [[UIApplication sharedApplication] openURL:url2];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
