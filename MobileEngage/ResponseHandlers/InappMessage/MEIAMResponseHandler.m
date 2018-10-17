//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMResponseHandler.h"
#import "MEInAppMessage.h"
#import "MEInApp.h"

@interface MEIAMResponseHandler ()

@property(nonatomic, strong) MEInApp *inApp;

@end

@implementation MEIAMResponseHandler

- (instancetype)initWithInApp:(MEInApp *)inApp {
    NSParameterAssert(inApp);
    if (self = [super init]) {
        _inApp = inApp;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    id message = response.parsedBody[@"message"];
    return [message isKindOfClass:[NSDictionary class]] && message[@"html"] != nil;
}

- (void)handleResponse:(EMSResponseModel *)response {
    [self.inApp showMessage:[[MEInAppMessage alloc] initWithResponse:response]
          completionHandler:nil];
}

@end