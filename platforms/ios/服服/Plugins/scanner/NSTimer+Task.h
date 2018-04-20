//
//  NSTimer+Task.h
//  服服
//
//  Created by 宋宏康 on 2017/9/17.
//
//

#import <Foundation/Foundation.h>

@interface NSTimer (Task)

+ (NSTimer *)task_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)(__weak NSTimer *timer))block;

@end
