//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMobileEngageV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSStorage.h"
#import "EMSSession.h"

#define kEMSPushTokenKey @"EMSPushTokenKey"

@interface EMSMobileEngageV3Internal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSStorage *storage;
@property(nonatomic, strong) EMSSession *session;

@end

@implementation EMSMobileEngageV3Internal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                               storage:(EMSStorage *)storage
                               session:(EMSSession *)session {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(requestContext);
    NSParameterAssert(storage);
    NSParameterAssert(session);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _requestContext = requestContext;
        _requestContext = requestContext;
        _storage = storage;
        _session = session;
    }
    return self;
}

- (void)setAuthenticatedContactWithOpenIdToken:(nullable NSString *)openIdToken
                               completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    BOOL shouldRestartSession = ![openIdToken isEqualToString:self.requestContext.openIdToken];

    [self.requestContext setContactFieldValue:nil];
    [self.requestContext setOpenIdToken:openIdToken];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];

    if (shouldRestartSession) {
        [self.session stopSession];
        [self.session startSession];
    }
}

- (void)setContactWithContactFieldId:(nullable NSNumber *)contactFieldId
                   contactFieldValue:(nullable NSString *)contactFieldValue {
    [self setContactWithContactFieldId:contactFieldId
                     contactFieldValue:contactFieldValue
                       completionBlock:nil];
}

- (void)setContactWithContactFieldId:(nullable NSNumber *)contactFieldId
                   contactFieldValue:(nullable NSString *)contactFieldValue
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    BOOL shouldRestartSession = ![contactFieldValue isEqualToString:self.requestContext.contactFieldValue];

    [self.requestContext setOpenIdToken:nil];
    [self.requestContext setContactFieldId:contactFieldId];
    [self.requestContext setContactFieldValue:contactFieldValue];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];

    if (shouldRestartSession) {
        [self.session stopSession];
        [self.session startSession];
    }
}

- (void)clearContact {
    [self clearContactWithCompletionBlock:nil];
}

- (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    [self.storage setData:nil
                   forKey:kEMSPushTokenKey];
    [self.requestContext reset];
    [self.session stopSession];
    [self setContactWithContactFieldId:nil
                     contactFieldValue:nil
                       completionBlock:completionBlock];
    [self.session startSession];
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
