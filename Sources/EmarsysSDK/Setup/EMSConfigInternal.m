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
#import "EMSLogger.h"
#import "EMSResponseModel.h"
#import "EMSCrypto.h"

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
@property(nonatomic, strong) EMSLogger *logger;
@property(nonatomic, strong) EMSRemoteConfigResponseMapper *remoteConfigResponseMapper;
@property(nonatomic, strong) NSNumber *updatedContactFieldId;
@property(nonatomic, assign) BOOL contactFieldIdHasBeenChanged;
@property(nonatomic, strong) EMSCrypto *crypto;

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
                              endpoint:(EMSEndpoint *)endpoint
                                logger:(EMSLogger *)logger
                                crypto:(EMSCrypto *)crypto {
    NSParameterAssert(requestManager);
    NSParameterAssert(meRequestContext);
    NSParameterAssert(preRequestContext);
    NSParameterAssert(mobileEngage);
    NSParameterAssert(pushInternal);
    NSParameterAssert(deviceInfo);
    NSParameterAssert(emarsysRequestFactory);
    NSParameterAssert(remoteConfigResponseMapper);
    NSParameterAssert(endpoint);
    NSParameterAssert(logger);
    NSParameterAssert(crypto);
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
        _logger = logger;
        _crypto = crypto;
    }
    return self;
}

- (void)refreshConfigFromRemoteConfig {
    EMSRequestModel *signatureRequestModel = [self.emarsysRequestFactory createRemoteConfigSignatureRequestModel];
    [self.requestManager submitRequestModelNow:signatureRequestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      [self fetchRemoteConfigWithSignatureData:response.body];
                                  }
                                    errorBlock:^(NSString *requestId, NSError *error) {
                                        if (error) {
                                            [self.endpoint reset];
                                            [self.logger reset];
                                        }
                                    }];


}

- (void)fetchRemoteConfigWithSignatureData:(NSData *)signatureData {
    EMSRequestModel *requestModel = [self.emarsysRequestFactory createRemoteConfigRequestModel];
    [self.requestManager submitRequestModelNow:requestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      if ([self.crypto verifyContent:response.body
                                                       withSignature:signatureData]) {
                                          if (response) {
                                              EMSRemoteConfig *remoteConfig = [self.remoteConfigResponseMapper map:response];
                                              [self.endpoint updateUrlsWithRemoteConfig:remoteConfig];
                                              [self.logger updateWithRemoteConfig:remoteConfig];
                                          } else {
                                              [self.endpoint reset];
                                              [self.logger reset];
                                          }
                                      } else {
                                          [self.endpoint reset];
                                          [self.logger reset];
                                      }
                                  }
                                    errorBlock:^(NSString *requestId, NSError *error) {
                                        if (error) {
                                            [self.endpoint reset];
                                            [self.logger reset];
                                        }
                                    }];
}

- (void)changeApplicationCode:(nullable NSString *)applicationCode
              completionBlock:(_Nullable EMSCompletionBlock)completionHandler; {
    [self changeApplicationCode:applicationCode
                 contactFieldId:[self.meRequestContext contactFieldId]
                completionBlock:completionHandler];
}

- (void)changeApplicationCode:(nullable NSString *)applicationCode
               contactFieldId:(NSNumber *)contactFieldId
              completionBlock:(_Nullable EMSCompletionBlock)completionHandler {
    _contactFieldValue = [self.meRequestContext contactFieldValue];

    if (![contactFieldId isEqualToNumber:self.meRequestContext.contactFieldId]) {
        _contactFieldIdHasBeenChanged = YES;
        _updatedContactFieldId = self.meRequestContext.contactFieldId;
        [self.meRequestContext setContactFieldId:contactFieldId];
    }

    __weak typeof(self) weakSelf = self;
    if (self.meRequestContext.applicationCode) {
        [self.mobileEngage clearContactWithCompletionBlock:^(NSError *error) {
            if (error) {
                [weakSelf callCompletionBlock:completionHandler
                                    withError:error];
            } else {
                [weakSelf callSetPushToken:applicationCode
                           completionBlock:completionHandler];
            }
        }];
    } else {
        [self callSetPushToken:applicationCode
               completionBlock:completionHandler];
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
    if (!self.contactFieldIdHasBeenChanged) {
        [self.mobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                           completionBlock:^(NSError *error) {
                                               [weakSelf callCompletionBlock:completionBlock
                                                                   withError:error];
                                           }];
    } else {
        [self callCompletionBlock:completionBlock
                        withError:nil];
    }
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
        self.meRequestContext.contactFieldId = self.updatedContactFieldId;
    }
    self.updatedContactFieldId = nil;
    self.contactFieldIdHasBeenChanged = NO;
    [self refreshConfigFromRemoteConfig];
    if (completionBlock) {
        completionBlock(error);
    }
}

@end
