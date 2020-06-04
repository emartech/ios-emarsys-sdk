//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSOpenExternalUrlAction.h"

@interface EMSOpenExternalUrlAction ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) NSDictionary *action;

@end

@implementation EMSOpenExternalUrlAction

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                             application:(UIApplication *)application {
    NSParameterAssert(action);
    NSParameterAssert(application);
    if (self = [super init]) {
        _action = action;
        _application = application;
    }
    return self;
}

- (void)execute {
    NSString *urlString = self.action[@"url"];
    if (urlString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.application openURL:[[NSURL alloc] initWithString:urlString]
                              options:@{}
                    completionHandler:nil];
        });
    }
}

@end