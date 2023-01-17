//
// Copyright (c) 2023 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@class UIPasteboard;

@interface MEIAMCopyToClipboard: NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithPasteboard:(UIPasteboard *)pasteboard;

@end