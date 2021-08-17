//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import "EMSSceneProvider.h"

@interface EMSSceneProvider ()

@property(nonatomic, strong) UIApplication *application;

@end

@implementation EMSSceneProvider

- (instancetype)initWithApplication:(UIApplication *)application {
    NSParameterAssert(application);
    if (self = [super init]) {
        _application = application;
    }
    return self;
}

- (UIScene *)provideScene {
    UIScene *result;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in self.application.connectedScenes) {
            UISceneActivationState activationState = [scene activationState];
            if (activationState == UISceneActivationStateForegroundActive
                    || activationState == UISceneActivationStateForegroundInactive) {
                result = scene;
                break;
            }
        }
    }

    return result;
}

@end