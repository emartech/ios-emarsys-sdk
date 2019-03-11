//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSTimestampProvider;
@class EMSUUIDProvider;

typedef enum {
    HTTPMethodPOST,
    HTTPMethodPUT,
    HTTPMethodGET,
    HTTPMethodDELETE
} HTTPMethod;

#define DEFAULT_REQUESTMODEL_EXPIRY FLT_MAX

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestModelBuilder : NSObject

@property(nonatomic, readonly) NSString *requestId;
@property(nonatomic, readonly) NSDate *timestamp;
@property(nonatomic, readonly) NSTimeInterval expiry;
@property(nonatomic, readonly) NSURL *requestUrl;
@property(nonatomic, readonly) NSString *requestMethod;
@property(nonatomic, readonly) NSDictionary<NSString *, id> *payload;
@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;
@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *extras;

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider;

- (EMSRequestModelBuilder *)setMethod:(HTTPMethod)method;

- (EMSRequestModelBuilder *)setUrl:(NSString *)url;

- (EMSRequestModelBuilder *)setUrl:(NSString *)url
                   queryParameters:(NSDictionary<NSString *, NSString *> *)queryParameters;

- (EMSRequestModelBuilder *)setExpiry:(NSTimeInterval)expiry;

- (EMSRequestModelBuilder *)setPayload:(NSDictionary<NSString *, id> *)payload;

- (EMSRequestModelBuilder *)setHeaders:(NSDictionary<NSString *, NSString *> *)headers;

- (EMSRequestModelBuilder *)setExtras:(NSDictionary<NSString *, NSString *> *)extras;

@end

NS_ASSUME_NONNULL_END