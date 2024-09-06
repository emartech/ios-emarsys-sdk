//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEJSBridge.h"
#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"
#import "MEIAMClose.h"
#import "MEIAMTriggerAppEvent.h"
#import "MEIAMButtonClicked.h"
#import "MEIAMTriggerMEEvent.h"
#import "MEIAMCopyToClipboard.h"

@interface MEJSBridge ()

@property(nonatomic, strong) MEIAMJSCommandFactory *factory;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation MEJSBridge

- (instancetype)initWithJSCommandFactory:(MEIAMJSCommandFactory *)factory
                          operationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(factory);
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _factory = factory;
        _operationQueue = operationQueue;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *commandName = message.name;
    NSDictionary *arguments = message.body;
    id <MEIAMJSCommandProtocol> command = [self.factory commandByName:commandName];
    __weak typeof(self) weakSelf = self;

    [self.operationQueue addOperationWithBlock:^{
        [command handleMessage:arguments
                   resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                       if (weakSelf.jsResultBlock) {
                           weakSelf.jsResultBlock(result);
                       }
                   }];
    }];
}

- (NSArray<NSString *> *)jsCommandNames {
    return @[MEIAMRequestPushPermission.commandName,
        MEIAMOpenExternalLink.commandName,
        MEIAMClose.commandName,
        MEIAMTriggerAppEvent.commandName,
        MEIAMButtonClicked.commandName,
        MEIAMTriggerMEEvent.commandName,
        MEIAMCopyToClipboard.commandName
    ];
}

- (WKUserContentController *)userContentController {
    WKUserContentController *userContentController = [WKUserContentController new];
    for (NSString *jsCommandName in self.jsCommandNames) {
        [userContentController addScriptMessageHandler:self
                                                  name:jsCommandName];
    }
    return userContentController;
}

@end
