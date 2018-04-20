//
//  SingCountTitleView.h
//  服服
//
//  Created by shangzh on 16/7/25.
//

#import <UIKit/UIKit.h>

@interface SingCountTitleView : UIView

typedef void(^ChangeCurrenTime)(NSString *);

@property (nonatomic, copy) ChangeCurrenTime changeCurrentTime;

//时间标题
@property (nonatomic,strong) UIButton *titleBtn;

- (void)changeBtnStatus:(BOOL)status;

@end
