//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSEventHandler;

@protocol EMSGeofenceProtocol <NSObject>

@property(nonatomic, weak) id <EMSEventHandler> eventHandler;

- (void)requestAlwaysAuthorization;

- (void)enable;
- (void)enableWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;
- (void)disable;
- (BOOL)isEnabled;

@end

NS_ASSUME_NONNULL_END