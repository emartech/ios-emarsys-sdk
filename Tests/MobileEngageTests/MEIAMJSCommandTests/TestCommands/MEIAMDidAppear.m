//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMDidAppear.h"

@interface MEIAMDidAppear ()

@property(nonatomic, strong) MEIAMJSResultBlock resultBlock;

@end

@implementation MEIAMDidAppear

+ (NSString *)commandName {
    return @"IAMDidAppear";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    _resultBlock = resultBlock;
}

- (void)triggerResultBlockWithDictionary:(NSDictionary *)dictionary {
    self.resultBlock(dictionary);
}

@end