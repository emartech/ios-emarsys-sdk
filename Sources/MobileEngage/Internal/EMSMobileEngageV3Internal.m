//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMobileEngageV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSStorage.h"

#define kEMSPushTokenKey @"EMSPushTokenKey"

@interface EMSMobileEngageV3Internal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSStorage *storage;

@end

@implementation EMSMobileEngageV3Internal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                               storage:(EMSStorage *)storage {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(requestContext);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _requestContext = requestContext;
        _requestContext = requestContext;
        _storage = storage;
    }
    return self;
}

- (void)setContactWithContactFieldValue:(NSString *)contactFieldValue {
    [self setContactWithContactFieldValue:contactFieldValue
                          completionBlock:nil];
}

- (void)setContactWithContactFieldValue:(NSString *)contactFieldValue
                        completionBlock:(EMSCompletionBlock)completionBlock {
    [self.requestContext setContactFieldValue:contactFieldValue];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

- (void)clearContact {
    [self clearContactWithCompletionBlock:nil];
}

- (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    [self.storage setData:nil
                   forKey:kEMSPushTokenKey];
    [self.requestContext reset];
    [self setContactWithContactFieldValue:nil
                          completionBlock:completionBlock];
}

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    [self trackCustomEventWithName:eventName
                   eventAttributes:eventAttributes
                   completionBlock:nil];
}

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(eventName);
    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:eventName
                                                                              eventAttributes:eventAttributes
                                                                                    eventType:EventTypeCustom];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

@end
