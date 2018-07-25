//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeJSBridge.h"

@interface FakeJSBridge ()

@property(nonatomic, strong) FakeMessageBlock messageBlock;

@end

@implementation FakeJSBridge


- (instancetype)initWithMessageBlock:(FakeMessageBlock)messageBlock {
    if (self = [super init]) {
        _messageBlock = messageBlock;
    }
    return self;
}


- (NSArray<NSString *> *)jsCommandNames {
    return @[@"IAMDidAppear"];
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {

    self.messageBlock(message);

}


@end