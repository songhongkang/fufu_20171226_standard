//
//  CDVAlertMessageView.h
//  Test
//
//  Created by shangzh on 17/3/1.
//  Copyright © 2017年 shangzh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TextLeft,
    TextCenter,
} TextType;

@class CDVAlertMessageView;
@protocol CDVAlertMessageViewDelegate <NSObject>

- (void) popUpView:(CDVAlertMessageView *)view accepted:(BOOL)accept;

@end

@interface CDVAlertMessageView : UIView

@property (nonatomic,strong) id<CDVAlertMessageViewDelegate> delegate;

@property (nonatomic,copy) NSString *fieldText;

- (id)initWithTitle:(NSString *)title message:(NSString *)message  okButtonTitle:(NSString *)okBtnTil textType:(TextType)textType delegate:(id<CDVAlertMessageViewDelegate>) delegate;

- (void)showInView:(UIView *)view;



@end
