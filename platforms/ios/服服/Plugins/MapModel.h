//
//  MapModel.h
//  服服
//
//  Created by shangzh on 16/5/27.
//
//

#import <Foundation/Foundation.h>

@interface MapModel : NSObject
//搜索中的地址
@property (nonatomic,copy) NSString *searchAddress;

@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) CGFloat latitude;
@property (nonatomic,assign) CGFloat longitude;
@property (nonatomic,assign) BOOL selected;

//搜索地图中的别名
@property (nonatomic,copy) NSString *anotherName;

//showmap 中使用
@property (nonatomic,copy) NSString *detailAddress;

@end
