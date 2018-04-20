//
//  CDVPlaySound.m
//  服服
//
//  Created by shangzh on 17/3/9.
//
//

#import "CDVPlaySound.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CDVPlaySound()

@property (nonatomic,copy) NSString *callID;

@property (nonatomic,strong) CDVPluginResult *result;

@end

@implementation CDVPlaySound

- (void)play:(CDVInvokedUrlCommand *)command {
    _callID = [command callbackId];
    
    NSString *sound = [command argumentAtIndex:0];

    if ([sound isEqualToString:@"default"]) {
        AudioServicesPlaySystemSound(1300);
        AudioServicesRemoveSystemSoundCompletion(1300);
    } else {
        NSString *urlPath = [[NSBundle mainBundle] pathForResource:sound ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:urlPath];
        // 声明需要播放的音频文件ID[unsigned long]
        SystemSoundID ID;
        // 创建系统声音，同时返回一个ID
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
        // 根据ID播放自定义系统声音
        AudioServicesPlaySystemSound(ID);
        AudioServicesRemoveSystemSoundCompletion(ID);
    }
    self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [self.commandDelegate sendPluginResult:self.result callbackId:self.callID];
}


@end
