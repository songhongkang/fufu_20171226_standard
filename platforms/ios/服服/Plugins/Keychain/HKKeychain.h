//
//  HKKeychain.h
//  Keychain
//
//  Created by 宋宏康 on 2017/10/30.
//  Copyright © 2017年 中施科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>


@interface HKKeychain : NSObject

/**
 添加数据

 @param data data description
 @param key key description
 */
+ (void)addKeychainData:(id)data forKey:(NSString *)key;

/**
 根据key获取相应的数据

 @param key key description
 */
+ (id)getKeychainDataForKey:(NSString *)key;

/**
 删除数据

 @param key key description
 */
+ (void)deleteKeychainDataForKey:(NSString *)key;

@end
