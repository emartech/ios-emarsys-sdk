//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"

@interface FakeCompletionHandler : NSObject

@property(nonatomic, strong, readonly) CoreSuccessBlock successBlock;
@property(nonatomic, strong, readonly) CoreErrorBlock errorBlock;

@property(nonatomic, strong, readonly) NSNumber *successCount;
@property(nonatomic, strong, readonly) NSNumber *errorCount;

@end