//
// Copyright (c) 2023 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEIAMCopyToClipboard.h"
#import "EMSDictionaryValidator.h"
#import "MEIAMCommandResultUtils.h"

@interface MEIAMCopyToClipboard ()

@property(nonatomic, strong) UIPasteboard *pasteboard;

@end

@implementation MEIAMCopyToClipboard

- (instancetype)initWithPasteboard:(UIPasteboard *)pasteboard {
    if (self = [super init]) {
        _pasteboard = pasteboard;
    }
    return self;
}


+ (NSString *)commandName {
    return @"copyToClipboard";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    NSString *eventId = message[@"id"];

    NSArray<NSString *> *errors = [message validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"text" withType:[NSString class]];
    }];

    if ([errors count] > 0) {
        resultBlock([MEIAMCommandResultUtils createErrorResultWith:eventId
                                                        errorArray:errors]);
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.pasteboard setString:message[@"text"]];
        });

        NSDictionary *result = [MEIAMCommandResultUtils createSuccessResultWith:eventId];
        resultBlock(result);
    }

}

@end