//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSConfigInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "MERequestContext.h"
#import "EMSPushV3Internal.h"
#import "PRERequestContext.h"
#import "EMSDeviceInfo.h"
#import "EMSRequestManager.h"
#import "EMSEmarsysRequestFactory.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSEndpoint.h"

@interface EMSConfigInternal ()

@property(nonatomic, strong) EMSMobileEngageV3Internal *mobileEngage;
@property(nonatomic, strong) MERequestContext *meRequestContext;
@property(nonatomic, strong) PRERequestContext *preRequestContext;
@property(nonatomic, strong) EMSPushV3Internal *pushInternal;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSEmarsysRequestFactory *emarsysRequestFactory;
@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) EMSRemoteConfigResponseMapper *remoteConfigResponseMapper;

@end

@implementation EMSConfigInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                      meRequestContext:(MERequestContext *)meRequestContext
                     preRequestContext:(PRERequestContext *)preRequestContext
                          mobileEngage:(EMSMobileEngageV3Internal *)mobileEngage
                          pushInternal:(EMSPushV3Internal *)pushInternal
                            deviceInfo:(EMSDeviceInfo *)deviceInfo
                 emarsysRequestFactory:(EMSEmarsysRequestFactory *)emarsysRequestFactory
            remoteConfigResponseMapper:(EMSRemoteConfigResponseMapper *)remoteConfigResponseMapper
                              endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(requestManager);
    NSParameterAssert(meRequestContext);
    NSParameterAssert(preRequestContext);
    NSParameterAssert(mobileEngage);
    NSParameterAssert(pushInternal);
    NSParameterAssert(deviceInfo);
    NSParameterAssert(emarsysRequestFactory);
    NSParameterAssert(remoteConfigResponseMapper);
    NSParameterAssert(endpoint);

    if (self = [super init]) {
        _requestManager = requestManager;
        _mobileEngage = mobileEngage;
        _meRequestContext = meRequestContext;
        _preRequestContext = preRequestContext;
        _pushInternal = pushInternal;
        _deviceInfo = deviceInfo;
        _emarsysRequestFactory = emarsysRequestFactory;
        _remoteConfigResponseMapper = remoteConfigResponseMapper;
        _endpoint = endpoint;
    }
    return self;
}

- (void)refreshConfigFromRemoteConfig {
    EMSRequestModel *requestModel = [self.emarsysRequestFactory createRemoteConfigRequestModel];
    [self.requestManager submitRequestModelNow:requestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      if (response) {
                                          EMSRemoteConfig *remoteConfig = [self.remoteConfigResponseMapper map:response];
                                          [self.endpoint updateUrlsWithRemoteConfig:remoteConfig];
                                      }
                                  }
                                    errorBlock:^(NSString *requestId, NSError *error) {
                                        if (error) {
                                            [self.endpoint reset];
                                        }
                                    }];
}

- (void)changeApplicationCode:(nullable NSString *)applicationCode
              completionBlock:(_Nullable EMSCompletionBlock)completionBlock; {
    _contactFieldValue = [self.meRequestContext contactFieldValue];

    __weak typeof(self) weakSelf = self;
    if (self.meRequestContext.applicationCode) {
        [self.mobileEngage clearContactWithCompletionBlock:^(NSError *error) {
            if (error) {
                [weakSelf callCompletionBlock:completionBlock
                                    withError:error];
            } else {
                [weakSelf callSetPushToken:applicationCode
                           completionBlock:completionBlock];
            }
        }];
    } else {
        [self callSetPushToken:applicationCode
               completionBlock:completionBlock];
    }
}

- (NSString *)applicationCode {
    return self.meRequestContext.applicationCode;
}

- (void)changeMerchantId:(nullable NSString *)merchantId {
    self.preRequestContext.merchantId = merchantId;
}

- (NSString *)merchantId {
    return self.preRequestContext.merchantId;
}

- (NSNumber *)contactFieldId {
    return self.meRequestContext.contactFieldId;
}

- (void)setContactFieldId:(NSNumber *)contactFieldId {
    NSParameterAssert(contactFieldId);
    self.meRequestContext.contactFieldId = contactFieldId;
}

- (void)setPushTokenWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    if (self.pushInternal.deviceToken) {
        [self.pushInternal setPushToken:self.pushInternal.deviceToken
                        completionBlock:^(NSError *error) {
                            if (error) {
                                [weakSelf callCompletionBlock:completionBlock
                                                    withError:error];
                            } else {
                                [weakSelf setContactWithCompletionBlock:completionBlock];
                            }
                        }];
    } else {
        [self setContactWithCompletionBlock:completionBlock];
    }
}

- (void)setContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.mobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                       completionBlock:^(NSError *error) {
                                           [weakSelf callCompletionBlock:completionBlock
                                                               withError:error];
                                       }];
}

- (NSString *)hardwareId {
    return [self.deviceInfo hardwareId];
}

- (NSString *)languageCode {
    return [self.deviceInfo languageCode];
}

- (NSDictionary *)pushSettings {
    return [self.deviceInfo pushSettings];
}

- (void)callSetPushToken:(NSString *)applicationCode
         completionBlock:(EMSCompletionBlock)completionBlock {
    self.meRequestContext.applicationCode = applicationCode;
    [self setPushTokenWithCompletionBlock:completionBlock];
}

- (void)callCompletionBlock:(EMSCompletionBlock)completionBlock
                  withError:(NSError *)error {
    if (error) {
        self.meRequestContext.applicationCode = nil;
    } else {
        ;
    }
    if (completionBlock) {
        completionBlock(error);
    }
}

@end
