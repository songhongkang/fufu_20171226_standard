//
//  CDVDateTimePickerView.h
//  服服
//
//  Created by shangzh on 16/7/28.
//
//

#import <UIKit/UIKit.h>

@interface CDVDateTimePickerView : UIView

typedef void(^SelectCurrentTime)();

@property (nonatomic,strong) UIDatePicker *datePicker;

@property (nonatomic, copy) SelectCurrentTime selectedCurrentTime;

@property (nonatomic,copy) NSString *currentTime;

@end
