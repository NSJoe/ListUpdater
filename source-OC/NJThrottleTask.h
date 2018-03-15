//
//  NJThrottleTask.h
//  PM_ListUpdater_FuncCmp
//
//  Created by Joe on 2017/10/25.
//  Copyright © 2017年 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NJThrottleTask : NSObject

@property (nonatomic) CGFloat throttle;

- (void)commitTask:(dispatch_block_t)task;

@end
