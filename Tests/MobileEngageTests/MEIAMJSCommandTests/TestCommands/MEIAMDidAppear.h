//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@interface MEIAMDidAppear : NSObject <MEIAMJSCommandProtocol>

- (void)triggerResultBlockWithDictionary:(NSDictionary *)dictionary;

@end