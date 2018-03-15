//
//  NJThrottleTask.m
//  PM_ListUpdater_FuncCmp
//
//  Created by Joe on 2017/10/25.
//  Copyright © 2017年 Joe. All rights reserved.
//

#import "NJThrottleTask.h"
#import <libkern/OSAtomic.h>

@interface NJThrottleTask ()

@property (nonatomic) NSMutableArray<dispatch_block_t> *tasks;
@property (nonatomic) dispatch_queue_t work_queue;

@end

@implementation NJThrottleTask {
    int32_t volatile _isExecuting;
}

-(instancetype)init {
    if (self = [super init]) {
        _isExecuting = 0;
        self.tasks = [NSMutableArray array];
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
        self.work_queue = dispatch_queue_create("PM_ListUpdater_FuncCmp.throttle.serial.task", attr);
    }
    return self;
}

-(void)commitTask:(dispatch_block_t)task{
    dispatch_async(self.work_queue, ^{
        BOOL firstAdd = OSAtomicCompareAndSwap32Barrier(0, 1, &_isExecuting);
        if (firstAdd) {
            task();
            [self flushDelayTasks];
        } else {
            [self.tasks addObject:[task copy]];
        }
    });
}

// 最后一个任务执行完成之后，再过throttle时间才能执行新任务
- (void)flushDelayTasks {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.throttle * NSEC_PER_SEC)), self.work_queue, ^{
        dispatch_block_t latest = self.tasks.lastObject;
        [self.tasks removeAllObjects];
        if (latest) {
            latest();
            [self flushDelayTasks];
        } else {
            OSAtomicCompareAndSwap32Barrier(1, 0, &_isExecuting);
        }
    });
}

@end
