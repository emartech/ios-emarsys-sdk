//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSTrigger.h"

@interface EMSAgenda : NSObject

@property(nonatomic, strong) NSString *tag;
@property(nonatomic, assign) NSTimeInterval delay;
@property(nonatomic, strong) NSNumber *interval;
@property(nonatomic, strong) EMSTriggerBlock triggerBlock;
@property(nonatomic, assign) dispatch_source_t dispatchTimer;

- (instancetype)initWithTag:(NSString *)tag
                      delay:(NSTimeInterval)delay
                   interval:(NSNumber *)interval
              dispatchTimer:(dispatch_source_t)dispatchTimer
               triggerBlock:(EMSTriggerBlock)triggerBlock;
@end