//
//  SingCountTitleView.m
//  服服
//
//  Created by shangzh on 16/7/25.
//
//

#import "SingCountTitleView.h"
#import "CDVDateTimePickerView.h"
#import "UIView+UIViewAnimation.h"

@interface SingCountTitleView()
//左边菜单
@property (nonatomic,strong) UIButton *leftBtn;
//右边菜单
@property (nonatomic,strong) UIButton *rightBtn;

@property (nonatomic,assign) NSInteger year;

@property (nonatomic,assign) NSInteger month;
//选择的日期
@property (nonatomic,assign) NSInteger day;
//当前月份的天数
@property (nonatomic,assign) NSInteger monthDay;
//更改后的时间
@property (nonatomic,copy) NSString *changeTime;

@end

@implementation SingCountTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addLeftBtn];
        [self addRight];
       
        self.titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 0, self.bounds.size.width-60, self.bounds.size.height)];
        self.titleBtn.tag = 3;
        [self.titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [self.titleBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.titleBtn];
        
    }
    return self;
}

- (void)getCurrentYearMontyDayWithTime:(NSString *)time {
    self.year = [[time substringWithRange:NSMakeRange(0, 4)] integerValue];
    self.month = [[time substringWithRange:NSMakeRange(5, 2)] integerValue];
    self.day = [[time substringWithRange:NSMakeRange(8, 2)] integerValue];
    
    [self getMonthDayWithMonth:self.month];
}

- (void)getMonthDayWithMonth:(int)month {
    switch (month) {
        case 2: //29
            if (self.year%4 == 0) {
                self.monthDay = 29;
            } else {
                self.monthDay = 28;
            }
            break;
        case 4:
            self.monthDay = 30;
            break;
        case 6:
            self.monthDay = 30;
            break;
        case 9:
            self.monthDay = 30;
            break;
        case 11:
            self.monthDay = 30;
            break;
        default:
            self.monthDay = 31;
            break;
    }

}

- (void)addLeftBtn {
    self.leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, self.bounds.size.height)];
    self.leftBtn.tag = 1;
    [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [self.leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftBtn];
}

- (void)addRight {
    self.rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-30, 0, 30, self.bounds.size.height)];
    self.rightBtn.tag = 2;
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightBtn];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 1:
        [self dataTimeChangeWithType:@"left"];
            break;
        case 2:
        [self dataTimeChangeWithType:@"right"];
            break;
        default:
        self.changeCurrentTime(@"normal");
            break;
    }
}

- (void)dataTimeChangeWithType:(NSString *)type {

    [self getCurrentYearMontyDayWithTime:self.titleBtn.titleLabel.text];
    
    if ([type isEqualToString:@"right"]) {
        if (self.day+1 <= self.monthDay) {
            self.day++;
            if (self.day >= 10) {
                if (self.month < 10) {
                    self.changeTime = [NSString stringWithFormat:@"%ld/0%ld/%ld",(long)self.year,(long)self.month,(long)self.day];
                } else {
                    self.changeTime = [NSString stringWithFormat:@"%ld/%ld/%ld",(long)self.year,(long)self.month,(long)self.day];
                }
            } else {
                if (self.month < 10) {
                    self.changeTime = [NSString stringWithFormat:@"%ld/0%ld/0%ld",(long)self.year,(long)self.month,(long)self.day];
                } else {
                    self.changeTime = [NSString stringWithFormat:@"%ld/%ld/0%ld",(long)self.year,(long)self.month,(long)self.day];
                }
            }
            
        } else {
            self.month++;
            self.day = 1;
            if (self.month > 12) {
                self.year++;
                self.month = 1;
            }
            
            if (self.month < 10) {
                self.changeTime = [NSString stringWithFormat:@"%ld/0%ld/0%ld",(long)self.year,(long)self.month,(long)self.day];
            } else {
                self.changeTime = [NSString stringWithFormat:@"%ld/%ld/0%ld",(long)self.year,(long)self.month,(long)self.day];
            }
        }
    } else {  //left 减
        if (self.day-1 > 0) {
            self.day--;
            
            if (self.day -1 >= 9) {
                if (self.month >= 10) {
                    self.changeTime = [NSString stringWithFormat:@"%ld/%ld/%ld",(long)self.year,(long)self.month,(long)self.day];
                } else {
                    self.changeTime = [NSString stringWithFormat:@"%ld/0%ld/%ld",(long)self.year,(long)self.month,(long)self.day];
                }
            } else {
                if (self.month >= 10) {
                    self.changeTime = [NSString stringWithFormat:@"%ld/%ld/0%ld",(long)self.year,(long)self.month,(long)self.day];
                } else {
                    self.changeTime = [NSString stringWithFormat:@"%ld/0%ld/0%ld",(long)self.year,(long)self.month,(long)self.day];

                }
            }
        } else {
            self.month--;
            if (self.month < 1) {
                self.year--;
                self.month = 12;
            }
            
            [self getMonthDayWithMonth:self.month];
             self.day = self.monthDay;
            
            if (self.month < 10) {
                self.changeTime = [NSString stringWithFormat:@"%ld/0%ld/%ld",(long)self.year,(long)self.month,(long)self.day];
            } else {
                self.changeTime = [NSString stringWithFormat:@"%ld/%ld/%ld",(long)self.year,(long)self.month,(long)self.day];
            }
        }
    }
    
    [self.titleBtn setTitle:self.changeTime forState:UIControlStateNormal];
   
    self.changeCurrentTime(self.changeTime);
}


- (void)changeBtnStatus:(BOOL)status {
    self.leftBtn.enabled = status;
    self.rightBtn.enabled = status;
    self.titleBtn.enabled = status;
}
@end
