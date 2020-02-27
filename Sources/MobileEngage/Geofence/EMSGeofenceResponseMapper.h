//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSResponseModel;
@class EMSGeofenceResponse;

NS_ASSUME_NONNULL_BEGIN

@interface EMSGeofenceResponseMapper : NSObject

- (nullable EMSGeofenceResponse *)mapFromResponseModel:(EMSResponseModel *)responseModel;

@end

NS_ASSUME_NONNULL_END