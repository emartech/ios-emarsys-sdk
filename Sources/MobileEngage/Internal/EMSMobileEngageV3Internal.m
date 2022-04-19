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

#define kEMSPushTokenKey @"EMSPushTokenKey"

@interface EMSMobileEngageV3Internal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) id<EMSStorageProtocol> storage;
@property(nonatomic, strong) EMSSession *session;

@end

@implementation EMSMobileEngageV3Internal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                               storage:(id<EMSStorageProtocol>)storage
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

- (void)setAuthenticatedContactWithContactFieldId:(NSNumber *)contactFieldId
                                      openIdToken:(NSString *)openIdToken
                                  completionBlock:(EMSCompletionBlock)completionBlock {
    BOOL shouldRestartSession = ![openIdToken isEqualToString:self.requestContext.openIdToken];
    
    [self.requestContext setContactFieldValue:nil];
    [self.requestContext setContactFieldId:contactFieldId];
    [self.requestContext setOpenIdToken:openIdToken];
    
    [self sendContactRequestWithShouldRestartSession:shouldRestartSession
                                     completionBlock:completionBlock];
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
    
    [self sendContactRequestWithShouldRestartSession:shouldRestartSession
                                     completionBlock:completionBlock];
}

- (void)sendContactRequestWithShouldRestartSession:(BOOL)shouldRestartSession
                                   completionBlock:(EMSCompletionBlock)completionBlock {
    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];
    __weak typeof(self) weakSelf = self;
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:^(NSError * _Nullable error) {
        if (shouldRestartSession) {
            [weakSelf.session stopSessionWithCompletionBlock:^(NSError * _Nullable error) {
                [weakSelf.session startSessionWithCompletionBlock:completionBlock];
            }];
        } else {
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(error);
                });
            }
        }
    }];
}

- (void)clearContact {
    [self clearContactWithCompletionBlock:nil];
}

- (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.session stopSessionWithCompletionBlock:^(NSError * _Nullable error) {
        [weakSelf.storage setData:nil
                           forKey:kEMSPushTokenKey];
        [weakSelf.requestContext reset];
        [weakSelf setContactWithContactFieldId:nil
                             contactFieldValue:nil
                               completionBlock:^(NSError * _Nullable error) {
            [weakSelf.session startSessionWithCompletionBlock:completionBlock];
        }];
    }];
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
