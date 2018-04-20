//
//  CDVShake.m
//  服服
//
//  Created by shangzh on 16/5/12.
//
//

#import "CDVShake.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>


#define LocationTimeout 3  //   定位超时时间，可修改，最小2s
#define ReGeocodeTimeout 3 //   逆地理请求超时时间，可修改，最小2s

@interface CDVShake()

@property (strong,nonatomic) CMMotionManager *motionManager;

@property (nonatomic,assign) int currentTime;

@property (nonatomic,copy) NSString *callId;

@property (nonatomic,strong) CDVPluginResult *result;

@end

@implementation CDVShake

- (void)shake:(CDVInvokedUrlCommand *)command {
    self.callId = command.callbackId;
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];//一般在viewDidLoad中进行
        self.motionManager.accelerometerUpdateInterval = .1;//加速仪更新频率，以秒为单位
    }
    [self startAccelerometer];
    
}



#pragma mark - ShakeToEdit 摇动手机之后的回调方法

-(void)startAccelerometer
{
    //以push的方式更新并在block中接收加速度
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if (error) {
                                                     NSLog(@"motion error:%@",error);
                                                 }
                                             }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    
    //综合3个方向的加速度
    double accelerameter =sqrt( pow( acceleration.x , 2 ) + pow( acceleration.y , 2 )
                               + pow( acceleration.z , 2) );
    //当综合加速度大于2.3时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
    if (accelerameter>3.0f) {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        if ((a - self.currentTime) <= 2) {
            return;
        }
        self.currentTime = a;
        //立即停止更新加速仪（很重要！）
        [self.motionManager stopAccelerometerUpdates];
        
        [self playSound];
        if (!self.result) {
            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];

        }
        [self.commandDelegate sendPluginResult:self.result callbackId:self.callId];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //UI线程必须在此block内执行，例如摇一摇动画、UIAlertView之类
//        });
      
    }
}


- (void)playSound {
    NSString *urlPath = [[NSBundle mainBundle] pathForResource:@"shak" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:urlPath];
    // 声明需要播放的音频文件ID[unsigned long]
    SystemSoundID ID;
    // 创建系统声音，同时返回一个ID
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
    // 根据ID播放自定义系统声音
    AudioServicesPlaySystemSound(ID);
    AudioServicesRemoveSystemSoundCompletion(ID);
    
}

@end
