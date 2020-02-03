//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "MEIAMJSCommandProtocol.h"

@class MEIAMJSCommandFactory;

@interface MEJSBridge : NSObject <WKScriptMessageHandler>

@property(nonatomic, strong) MEIAMJSResultBlock jsResultBlock;

- (instancetype)initWithJSCommandFactory:(MEIAMJSCommandFactory *)factory;

- (NSArray<NSString *> *)jsCommandNames;

- (WKUserContentController *)userContentController;

@end