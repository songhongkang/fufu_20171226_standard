//
//  CustomAnnotationView.h
//  服服
//
//  Created by shangzh on 16/6/18.
//
//

#import <MAMapKit/MAMapKit.h>
#import "CustomCalloutView.h"

@interface CustomAnnotationView : MAAnnotationView

@property (nonatomic,copy) NSString *title;

@property (nonatomic, strong) CustomCalloutView *calloutView;

@property (nonatomic,assign) BOOL isShowCallout;

//自定义标注是否可以修改（放大）
@property (nonatomic,assign) BOOL markCanScal;

@end
