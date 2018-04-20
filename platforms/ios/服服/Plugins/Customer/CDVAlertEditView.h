//
//  CDVAlertView.h
//  服服
//
//  Created by shangzh on 17/2/28.
//
//

#import <UIKit/UIKit.h>

@class CDVAlertEditView;
@protocol CDVAlertEditViewDelegate <NSObject>

- (void) popUpView:(CDVAlertEditView *)view accepted:(BOOL)accept inputText:(NSString *)text;

@end

@interface CDVAlertEditView : UIView <UITextViewDelegate>

@property (nonatomic,strong) id<CDVAlertEditViewDelegate> delegate;

@property (nonatomic,copy) NSString *fieldText;

- (id)initWithTitle:(NSString *)title txtFiedl:(NSString *)txtfiedl  okButtonTitle:(NSString *)okBtnTil cancelButtonTItle:(NSString *)cancelBtnTil delegate:(id<CDVAlertEditViewDelegate>) delegate;

- (void)showInView:(UIView *)view;

@end
