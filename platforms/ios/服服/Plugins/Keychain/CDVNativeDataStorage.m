//
//  CDVNativeDataStorage.m
//  服服
//
//  Created by 宋宏康 on 2017/10/30.
//

#import "CDVNativeDataStorage.h"
#import "Constan.h"

@interface CDVNativeDataStorage()

@property (nonatomic, strong) NSUserDefaults *userDefault;

@property (nonatomic, strong) NSString *getLocalStorageValID;

@property (nonatomic, strong)CDVPluginResult *getLocalStorageValPluginResult;

@end


@implementation CDVNativeDataStorage

- (void)getLocalStorageVal:(CDVInvokedUrlCommand *)command
{
    _getLocalStorageValID =  command.callbackId;
    
  if (_userDefault == nil ) {
        _userDefault = [NSUserDefaults standardUserDefaults];
  }
    NSDictionary *dict = [_userDefault objectForKey:@"hk_fufu_config"];
    
    _getLocalStorageValPluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    [self.commandDelegate sendPluginResult:_getLocalStorageValPluginResult callbackId:_getLocalStorageValID];
}

- (void)setLocalStorageVal:(CDVInvokedUrlCommand *)command
{
//    NSLog(@"执行次数：%d",i++);
    NSString *dict1 = [command argumentAtIndex:0];
    id dict2 = [command argumentAtIndex:1];
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict2];
    if([dict1 isEqualToString:@"menu_home"]){
        NSLog(@"========start======");
        NSLog(@"key:%@\nval:%@",dict1,dict2);
        NSLog(@"========end=======");
    }
    NSLog(@"key:%@\nval:%@",dict1,dict2);
    [self depositKey:dict1 val:dict2];
//    [self shk:dict1 val:dict2];
}

- (void)depositKey:(NSString *)key val:(id)val
{
    if (_userDefault == nil ) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    NSDictionary *dict = [_userDefault objectForKey:@"hk_fufu_config"];
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (mutDict ) {
        // 字典包含key
        [mutDict setValue:val forKey:key];
    }
    
    if([key isEqualToString:@"menu_home"]){
        NSLog(@"%@",mutDict);
    }
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mutDict];
    [_userDefault setObject:mutDict forKey:@"hk_fufu_config"];
    [_userDefault synchronize];
}

@end
