//
//  CDVDateTimePickerView.m
//  服服
//
//  Created by shangzh on 16/7/28.
//
//

#import "CDVDateTimePickerView.h"

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CDVDateTimePickerView()

//选择的时间
@property (nonatomic,copy) NSString *selectedTime;

@end

@implementation CDVDateTimePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initWithSubView];
    }
    return self;
}

- (void)initWithSubView {
    self.backgroundColor = [UIColor whiteColor];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 16, self.bounds.size.width, self.bounds.size.height-16)];
    self.datePicker.backgroundColor = [UIColor grayColor];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GTM+8"]; // 设置时区
    [self addSubview:self.datePicker];
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-42, 5, 40, 30)];
    sureBtn.tag = 1;
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sureBtn setTitleColor:kUIColorFromRGB(0x53afff) forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(selectDateTime:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureBtn];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(12, 5, 40, 30)];
    cancel.tag = 2;
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancel setTitleColor:kUIColorFromRGB(0x53afff) forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(selectDateTime:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancel];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, self.bounds.size.width, 1)];
    line.backgroundColor = kUIColorFromRGB(0xf5f5f5);
    [self addSubview:line];
    [line bringSubviewToFront:self];
    
    [self getCurrentTime];
}

- (void)selectDateTime:(UIButton *)btn {
    [self getCurrentTime];
    if (btn.tag == 1) {
        self.selectedCurrentTime(self.selectedTime);
    } else {
        self.selectedCurrentTime(@"");
    }
}
- (void)getCurrentTime {
    NSDate *select = [self.datePicker date]; // 获取被选中的时间
    NSDateFormatter *selectDateFormatter = [[NSDateFormatter alloc] init];
    selectDateFormatter.dateFormat = @"yyyy/MM/dd"; // 设置时间和日期的格式
    self.selectedTime = [selectDateFormatter stringFromDate:select];
}
@end
