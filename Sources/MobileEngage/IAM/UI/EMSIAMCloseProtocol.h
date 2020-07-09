//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSIAMCloseProtocol <NSObject>
- (void)closeInAppWithCompletionHandler:(_Nullable EMSCompletion)completionHandler;
@end