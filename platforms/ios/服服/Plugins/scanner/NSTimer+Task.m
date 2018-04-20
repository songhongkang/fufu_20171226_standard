
//
//  NSTimer+Task.m
//  服服
//
//  Created by 宋宏康 on 2017/9/17.
//
//

#import "NSTimer+Task.h"

@implementation NSTimer (Task)

+ (NSTimer *)task_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)(__weak NSTimer *timer))block
{
    NSTimer *timer = [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(task_Selector:) userInfo:block repeats:repeats];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    return timer;
}

#pragma mark - Private
+ (void)task_Selector:(NSTimer *)timer {
    void (^block)(__weak NSTimer *) = timer.userInfo;
    if (block) {
        block(timer);
    }
}
@end
