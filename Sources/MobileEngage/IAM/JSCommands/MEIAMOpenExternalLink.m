//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMOpenExternalLink.h"
#import <UIKit/UIKit.h>
#import "EMSDictionaryValidator.h"
#import "MEIAMCommandResultUtils.h"

#define kExternalLink @"url"

@interface MEIAMOpenExternalLink ()

@property(nonatomic, strong) UIApplication *application;

@end

@implementation MEIAMOpenExternalLink

- (instancetype)initWithApplication:(UIApplication *)application {
    NSParameterAssert(application);
    if (self = [super init]) {
        _application = application;
    }
    return self;
}

+ (NSString *)commandName {
    return @"openExternalLink";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    NSString *eventId = message[@"id"];

    NSArray<NSString *> *errors = [message validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:kExternalLink
                           withType:[NSString class]];
    }];

    if ([errors count] > 0) {
        resultBlock([MEIAMCommandResultUtils createErrorResultWith:eventId
                                                        errorArray:errors]);
    } else {
        NSURL *url = [NSURL URLWithString:message[kExternalLink]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.application canOpenURL:url]) {
                [self.application openURL:url
                                  options:@{}
                        completionHandler:^(BOOL success) {
                            resultBlock([self createResultWithJSCommandId:eventId
                                                                  success:success]);
                        }];
            } else {
                resultBlock([MEIAMCommandResultUtils createErrorResultWith:eventId
                                                              errorMessage:@"Can't open url!"]);
            }
        });
    }
}

- (NSDictionary<NSString *, NSObject *> *)createResultWithJSCommandId:(NSString *)jsCommandId
                                                              success:(BOOL)success {
    NSDictionary<NSString *, NSObject *> *result;
    if (success) {
        result = [MEIAMCommandResultUtils createSuccessResultWith:jsCommandId];
    } else {
        result = [MEIAMCommandResultUtils createErrorResultWith:jsCommandId
                                                   errorMessage:@"Opening url failed!"];
    }
    return result;
}

@end
