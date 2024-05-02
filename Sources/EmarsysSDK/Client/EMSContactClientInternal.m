//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import "EMSContactClientInternal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "PRERequestContext.h"
#import "EMSStorage.h"
#import "EMSSession.h"
#import "EMSStorageProtocol.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

#define kEMSPushTokenKey @"EMSPushTokenKey"

@interface EMSContactClientInternal()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) PRERequestContext *predictRequestContext;
@property(nonatomic, strong) id<EMSStorageProtocol> storage;
@property(nonatomic, strong) EMSSession *session;

- (void)sendContactRequestWithShouldRestartSession:(BOOL)shouldRestartSession
                                   completionBlock:(EMSCompletionBlock)completionBlock;

@end

@implementation EMSContactClientInternal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                 predictRequestContext:(PRERequestContext *)predictRequestContext
                               storage:(id<EMSStorageProtocol>)storage
                               session:(EMSSession *)session {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(requestContext);
    NSParameterAssert(predictRequestContext);
    NSParameterAssert(storage);
    NSParameterAssert(session);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _requestContext = requestContext;
        _predictRequestContext = predictRequestContext;
        _storage = storage;
        _session = session;
    }
    return self;
}

- (void)setAuthenticatedContactWithContactFieldId:(nullable NSNumber *)contactFieldId 
                                      openIdToken:(nullable NSString *)openIdToken
                                  completionBlock:(EMSCompletionBlock _Nullable)completionBlock {
    BOOL shouldRestartSession = ![openIdToken isEqualToString:self.requestContext.openIdToken];
    
    [self.requestContext setContactFieldValue:nil];
    [self.predictRequestContext setContactFieldValue:nil];
    [self.requestContext setContactFieldId:contactFieldId];
    [self.requestContext setOpenIdToken:openIdToken];
    [self.predictRequestContext setContactFieldId:contactFieldId];
    
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
                     completionBlock:(EMSCompletionBlock _Nullable)completionBlock {
    BOOL shouldRestartSession = ![contactFieldValue isEqualToString:self.requestContext.contactFieldValue];
    
    [self.requestContext setOpenIdToken:nil];
    [self.requestContext setContactFieldId:contactFieldId];
    [self.requestContext setContactFieldValue:contactFieldValue];
    [self.predictRequestContext setContactFieldId:contactFieldId];
    [self.predictRequestContext setContactFieldValue:contactFieldValue];
    
    [self sendContactRequestWithShouldRestartSession:shouldRestartSession
                                     completionBlock:completionBlock];
}

- (void)clearContact {
    [self clearContactWithCompletionBlock:nil];
}

- (void)clearContactWithCompletionBlock:(EMSCompletionBlock _Nullable)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.session stopSessionWithCompletionBlock:^(NSError * _Nullable error) {
        [weakSelf.storage setData:nil
                           forKey:kEMSPushTokenKey];
        [weakSelf.requestContext reset];
        [weakSelf.predictRequestContext reset];
        
        if ([MEExperimental isFeatureEnabled:EMSInnerFeature.predict] && ![MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
            [weakSelf.requestManager submitRequestModel:[weakSelf.requestFactory createPredictOnlyClearContactRequestModel]
                                    withCompletionBlock:^(NSError * _Nullable error) {
                [weakSelf.session startSessionWithCompletionBlock:completionBlock];
            }];
        } else if ([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
            [weakSelf setContactWithContactFieldId:nil
                                         contactFieldValue:nil
                                           completionBlock:^(NSError * _Nullable error) {
                        [weakSelf.session startSessionWithCompletionBlock:completionBlock];
                    }];
        }
    }];
}

- (void)sendContactRequestWithShouldRestartSession:(BOOL)shouldRestartSession
                                   completionBlock:(EMSCompletionBlock)completionBlock {
    EMSRequestModel *requestModel;
    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.predict] && ![MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
        requestModel = [self.requestFactory createPredictOnlyContactRequestModelWithRefresh:NO];
    } else if ([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
        requestModel = [self.requestFactory createContactRequestModel];
    }
    
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

@end
