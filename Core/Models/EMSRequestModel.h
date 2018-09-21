//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModelBuilder.h"

@class EMSRequestModelBuilder;
@class EMSTimestampProvider;
@class EMSUUIDProvider;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestModel : NSObject

@property(nonatomic, readonly) NSString *requestId;
@property(nonatomic, readonly) NSDate *timestamp;
@property(nonatomic, readonly) NSTimeInterval ttl;
@property(nonatomic, readonly) NSURL *url;
@property(nonatomic, readonly) NSString *method;
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, id> *payload;
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *headers;
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *extras;

typedef void(^EMSRequestBuilderBlock)(EMSRequestModelBuilder *builder);

+ (instancetype)makeWithBuilder:(EMSRequestBuilderBlock)builderBlock
              timestampProvider:(EMSTimestampProvider *)timestampProvider
                   uuidProvider:(EMSUUIDProvider *)uuidProvider;

- (instancetype)initWithRequestId:(NSString *)requestId
                        timestamp:(NSDate *)timestamp
                           expiry:(NSTimeInterval)expiry
                              url:(NSURL *)url
                           method:(NSString *)method
                          payload:(nullable NSDictionary<NSString *, id> *)payload
                          headers:(nullable NSDictionary<NSString *, NSString *> *)headers
                           extras:(nullable NSDictionary<NSString *, NSString *> *)extras;

@end

NS_ASSUME_NONNULL_END
