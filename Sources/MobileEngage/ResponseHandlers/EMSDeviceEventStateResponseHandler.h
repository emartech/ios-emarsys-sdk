//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

#define kDeviceEventStateKey @"DEVICE_EVENT_STATE_KEY"

@protocol EMSStorageProtocol;
@class EMSEndpoint;

NS_ASSUME_NONNULL_BEGIN

@interface EMSDeviceEventStateResponseHandler : EMSAbstractResponseHandler

- (instancetype)initWithStorage:(id<EMSStorageProtocol>)storage
                       endpoint:(EMSEndpoint *)endpoint;

@end

NS_ASSUME_NONNULL_END
