//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMobileEngageV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSStorage.h"
#import "EMSSession.h"
#import "EMSStorageProtocol.h"
#import "EMSCompletionBlockProvider.h"
#import "EMSStatusLog.h"
#import "EMSLogLevel.h"
#import "EMSMacros.h"

#define kEMSPushTokenKey @"EMSPushTokenKey"

@interface EMSMobileEngageV3Internal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) id<EMSStorageProtocol> storage;
@property(nonatomic, strong) EMSSession *session;
@property(nonatomic, strong) EMSCompletionBlockProvider *completionBlockProvider;

@end

@implementation EMSMobileEngageV3Internal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                               storage:(id<EMSStorageProtocol>)storage
                               session:(EMSSession *)session
               completionBlockProvider:(EMSCompletionBlockProvider *)completionBlockProvider {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(requestContext);
    NSParameterAssert(storage);
    NSParameterAssert(session);
    NSParameterAssert(completionBlockProvider);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _requestContext = requestContext;
        _requestContext = requestContext;
        _storage = storage;
        _session = session;
        _completionBlockProvider = completionBlockProvider;
    }
    return self;
}

- (void)callCompletionWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock
                                    error:(nullable NSError *)error {
    if (completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(error);
        });
    }
}

- (void)setAuthenticatedContactWithContactFieldId:(NSNumber *)contactFieldId
                                      openIdToken:(NSString *)openIdToken
                                  completionBlock:(EMSCompletionBlock)completionBlock {
    BOOL shouldRestartSession = ![openIdToken isEqualToString:self.requestContext.openIdToken];
    if (shouldRestartSession) {
        [self sendContactRequestWithContactFieldId:contactFieldId
                                 contactFieldValue:nil
                                       openIdToken:openIdToken
                                   completionBlock:completionBlock];
    } else {
        [self callCompletionWithCompletionBlock:completionBlock error:nil];
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
    if (shouldRestartSession) {
        [self sendContactRequestWithContactFieldId:contactFieldId
                                 contactFieldValue:contactFieldValue
                                       openIdToken:nil
                                   completionBlock:completionBlock];
    } else {
        [self callCompletionWithCompletionBlock:completionBlock error:nil];
    }
}

- (void)sendContactRequestWithContactFieldId:(nullable NSNumber *)contactFieldId
                           contactFieldValue:(nullable NSString *)contactFieldValue
                                 openIdToken:(nullable NSString *)openIdToken
                             completionBlock:(EMSCompletionBlock)completionBlock {
    [self.requestContext setOpenIdToken:openIdToken];
    [self.requestContext setContactFieldId:contactFieldId];
    [self.requestContext setContactFieldValue:contactFieldValue];
    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];
    __weak typeof(self) weakSelf = self;
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:[self.completionBlockProvider provideCompletionBlock:^(NSError * _Nullable error) {
        if (!error) {
            [weakSelf.session stopSessionWithCompletionBlock:[weakSelf.completionBlockProvider provideCompletionBlock:^(NSError * _Nullable error) {
                [weakSelf.session startSessionWithCompletionBlock:completionBlock];
            }]];
        } else {
            [weakSelf.requestContext resetPreviousContactValues];
            EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                   sel:_cmd
                                            parameters:nil
                                                status:nil], LogLevelError);
            [weakSelf callCompletionWithCompletionBlock:completionBlock error:error];
        }
    }]];
}

- (void)clearContact {
    [self clearContactWithCompletionBlock:nil];
}

- (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    BOOL shouldClearContact = !self.requestContext.contactToken || [self.requestContext hasContactIdentification];
    if (shouldClearContact) {
        [weakSelf sendContactRequestWithContactFieldId:nil
                                     contactFieldValue:nil
                                           openIdToken:nil
                                       completionBlock:[weakSelf.completionBlockProvider provideCompletionBlock:^(NSError * _Nullable error) {
            if(!error) {
                [weakSelf.storage setData:nil
                                   forKey:kEMSPushTokenKey];
                [weakSelf callCompletionWithCompletionBlock:completionBlock error:nil];
            } else {
                [weakSelf callCompletionWithCompletionBlock:completionBlock error:error];
            }
        }]];
    } else {
        [weakSelf callCompletionWithCompletionBlock:completionBlock error:nil];
    }

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
