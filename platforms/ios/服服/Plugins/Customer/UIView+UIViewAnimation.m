//
//  UIView+UIViewAnimation.m
//  服服
//
//  Created by shangzh on 16/7/28.
//
//

#import "UIView+UIViewAnimation.h"

@implementation UIView (UIViewAnimation)

- (void)MoveToUpWith:(CGRect)rect {
    [UIView animateWithDuration:0.5 animations:^{
        [self setFrame:rect];
    }];
}

- (void)MoveToDownWith:(CGRect)rect {    
    [UIView animateWithDuration:0.5 animations:^{
        [self setFrame:rect];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)ViewZoomWith {
    // 设定为缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // 动画选项设定
    animation.duration = 0.2; // 动画持续时间
    animation.repeatCount = 1; // 重复次数
    animation.autoreverses = NO; // 动画结束时执行逆动画
    
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.1]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:1.0]; // 结束时的倍率
    
    // 添加动画
    [self.layer addAnimation:animation forKey:@"scale-layer"];
}

@end
