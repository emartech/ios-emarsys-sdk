//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSGeofenceProtocol <NSObject>

@property(nonatomic, strong) EMSEventHandlerBlock eventHandler;
@property(nonatomic, assign) BOOL initialEnterTriggerEnabled;

- (void)requestAlwaysAuthorization;

- (void)enable;
- (void)enableWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(enable(completionBlock:));
- (void)disable;
- (BOOL)isEnabled;

@end

NS_ASSUME_NONNULL_END
