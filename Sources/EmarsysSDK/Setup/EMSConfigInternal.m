//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSConfigInternal.h"
#import "MERequestContext.h"
#import "EMSPushV3Internal.h"
#import "PRERequestContext.h"
#import "EMSDeviceInfo.h"
#import "EMSRequestManager.h"
#import "EMSEmarsysRequestFactory.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSEndpoint.h"
#import "EMSLogger.h"
#import "EMSCrypto.h"
#import "EMSDispatchWaiter.h"
#import "NSError+EMSCore.h"
#import "EMSDeviceInfoV3ClientInternal.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EMSRemoteConfig.h"
#import "EmarsysSDKVersion.h"
#import "EMSContactClientInternal.h"
#import "EMSMacros.h"
#import "EMSStatusLog.h"

#define METHOD_TIMEOUT 60

@interface EMSConfigInternal ()

@property(nonatomic, strong) EMSContactClientInternal *contactClient;
@property(nonatomic, strong) MERequestContext *meRequestContext;
@property(nonatomic, strong) PRERequestContext *preRequestContext;
@property(nonatomic, strong) EMSPushV3Internal *pushInternal;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSEmarsysRequestFactory *emarsysRequestFactory;
@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) EMSLogger *logger;
@property(nonatomic, strong) EMSRemoteConfigResponseMapper *remoteConfigResponseMapper;
@property(nonatomic, strong) EMSCrypto *crypto;
@property(nonatomic, strong) NSOperationQueue *coreQueue;
@property(nonatomic, strong) EMSDispatchWaiter *waiter;
@property(nonatomic, strong) EMSDeviceInfoV3ClientInternal *deviceInfoClient;

- (void)handleErrorWithLabel:(NSString *)label
             applicationCode:(NSString *)applicationCode
                       error:(NSError *)error
             completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

@end

@implementation EMSConfigInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                      meRequestContext:(MERequestContext *)meRequestContext
                     preRequestContext:(PRERequestContext *)preRequestContext
                         contactClient:(id <EMSContactClientProtocol>)contactClient
                          pushInternal:(id <EMSPushNotificationProtocol>)pushInternal
                            deviceInfo:(EMSDeviceInfo *)deviceInfo
                 emarsysRequestFactory:(EMSEmarsysRequestFactory *)emarsysRequestFactory
            remoteConfigResponseMapper:(EMSRemoteConfigResponseMapper *)remoteConfigResponseMapper
                              endpoint:(EMSEndpoint *)endpoint
                                logger:(EMSLogger *)logger
                                crypto:(EMSCrypto *)crypto
                             coreQueue:(NSOperationQueue *)coreQueue
                                waiter:(EMSDispatchWaiter *)waiter
                      deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient {
    NSParameterAssert(requestManager);
    NSParameterAssert(meRequestContext);
    NSParameterAssert(preRequestContext);
    NSParameterAssert(contactClient);
    NSParameterAssert(pushInternal);
    NSParameterAssert(deviceInfo);
    NSParameterAssert(emarsysRequestFactory);
    NSParameterAssert(remoteConfigResponseMapper);
    NSParameterAssert(endpoint);
    NSParameterAssert(logger);
    NSParameterAssert(crypto);
    NSParameterAssert(coreQueue);
    NSParameterAssert(waiter);
    NSParameterAssert(deviceInfoClient);
    if (self = [super init]) {
        _requestManager = requestManager;
        _contactClient = contactClient;
        _meRequestContext = meRequestContext;
        _preRequestContext = preRequestContext;
        _pushInternal = pushInternal;
        _deviceInfo = deviceInfo;
        _emarsysRequestFactory = emarsysRequestFactory;
        _remoteConfigResponseMapper = remoteConfigResponseMapper;
        _endpoint = endpoint;
        _logger = logger;
        _crypto = crypto;
        _coreQueue = coreQueue;
        _waiter = waiter;
        _deviceInfoClient = deviceInfoClient;
    }
    return self;
}

- (void)refreshConfigFromRemoteConfigWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    if (self.meRequestContext.applicationCode) {
        EMSRequestModel *signatureRequestModel = [self.emarsysRequestFactory createRemoteConfigSignatureRequestModel];
        __weak typeof(self) weakSelf = self;
        [self.requestManager submitRequestModelNow:signatureRequestModel
                                      successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                          [weakSelf fetchRemoteConfigWithSignatureData:response.body
                                                                       completionBlock:completionBlock];
                                      }
                                        errorBlock:^(NSString *requestId, NSError *error) {
                                            [weakSelf handleErrorWithLabel:@"remoteConfigSignatureFetchingFailed"
                                                           applicationCode:self.meRequestContext.applicationCode
                                                                     error:error
                                                           completionBlock:completionBlock];
                                        }];
    } else {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
}

- (void)fetchRemoteConfigWithSignatureData:(NSData *)signatureData
                           completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    EMSRequestModel *requestModel = [self.emarsysRequestFactory createRemoteConfigRequestModel];
    __weak typeof(self) weakSelf = self;
    [self.requestManager submitRequestModelNow:requestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      if ([self.crypto verifyContent:response.body
                                                       withSignature:signatureData]) {
                                          if (response) {
                                              EMSRemoteConfig *remoteConfig = [self.remoteConfigResponseMapper map:response];
                                              [self.endpoint updateUrlsWithRemoteConfig:remoteConfig];
                                              [self.logger updateWithRemoteConfig:remoteConfig];
                                              [self overrideFeatureFlippers:remoteConfig];
                                              if (completionBlock) {
                                                  completionBlock(nil);
                                              }
                                          } else {
                                              [weakSelf handleErrorWithLabel:@"noResponse"
                                                             applicationCode:self.meRequestContext.applicationCode
                                                                       error:[NSError errorWithCode:400
                                                                               localizedDescription:@"No response"]
                                                             completionBlock:completionBlock];
                                          }
                                      } else {
                                          [weakSelf handleErrorWithLabel:@"signatureVerificationFailed"
                                                         applicationCode:self.meRequestContext.applicationCode
                                                                   error:[NSError errorWithCode:500
                                                                           localizedDescription:@"Crypto error"]
                                                         completionBlock:completionBlock];
                                      }
                                  }
                                    errorBlock:^(NSString *requestId, NSError *error) {
                                        [weakSelf handleErrorWithLabel:@"remoteConfigFetchingFailed"
                                                       applicationCode:self.meRequestContext.applicationCode
                                                                 error:error
                                                       completionBlock:completionBlock];
                                    }];
}

- (void)overrideFeatureFlippers:(EMSRemoteConfig *)remoteConfig {
    NSDictionary *featureMatrix = [remoteConfig features];
    [self handleFeature:featureMatrix[@"mobile_engage"]
       withInnerFeature:EMSInnerFeature.mobileEngage];
    [self handleFeature:featureMatrix[@"predict"]
       withInnerFeature:EMSInnerFeature.predict];
    [self handleFeature:featureMatrix[@"event_service_v4"]
       withInnerFeature:EMSInnerFeature.eventServiceV4];
}

- (void)handleFeature:(NSNumber *)feature
     withInnerFeature:(EMSInnerFeature *)innerFeature {
    if (feature) {
        if (feature.boolValue) {
            [MEExperimental enableFeature:innerFeature];
        } else {
            [MEExperimental disableFeature:innerFeature];
        }
    }
}

- (void)changeApplicationCode:(nullable NSString *)applicationCode
              completionBlock:(_Nullable EMSCompletionBlock)completionHandler; {
    NSData *pushToken = self.pushInternal.deviceToken;
    BOOL hasContactIdentification = self.meRequestContext.hasContactIdentification;
    __block NSError *error = nil;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (weakSelf.meRequestContext.applicationCode && pushToken) {
            error = [weakSelf clearPushToken];
        }
        if (!error && weakSelf.meRequestContext.applicationCode && [weakSelf.meRequestContext hasContactIdentification]) {
            error = [weakSelf clearContact];
        }
        if (!error) {
            weakSelf.meRequestContext.applicationCode = applicationCode;
            if (applicationCode) {
                error = [weakSelf sendDeviceInfo];
                if (pushToken) {
                    error = [weakSelf sendPushToken:pushToken];
                }
                if (!error && !hasContactIdentification) {
                    error = [weakSelf clearContact];
                }
            }
        }
        if (error) {
            weakSelf.meRequestContext.applicationCode = nil;
        }
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(error);
            });
        }
    });
}

- (NSError *)clearContact {
    __weak typeof(self) weakSelf = self;
    return [self synchronizeMethodWithRunnerBlock:^(EMSCompletionBlock completion) {
        [weakSelf.contactClient clearContactWithCompletionBlock:completion];
    }];
}

- (NSError *)clearPushToken {
    __weak typeof(self) weakSelf = self;
    return [self synchronizeMethodWithRunnerBlock:^(EMSCompletionBlock completion) {
        [weakSelf.pushInternal clearPushTokenWithCompletionBlock:completion];
    }];
}

- (NSError *)sendDeviceInfo {
    __weak typeof(self) weakSelf = self;
    return [self synchronizeMethodWithRunnerBlock:^(EMSCompletionBlock completion) {
        [weakSelf.deviceInfoClient sendDeviceInfoWithCompletionBlock:completion];
    }];
}

- (NSError *)sendPushToken:(NSData *)pushToken {
    __weak typeof(self) weakSelf = self;
    return [self synchronizeMethodWithRunnerBlock:^(EMSCompletionBlock completion) {
        [weakSelf.pushInternal setPushToken:pushToken
                            completionBlock:completion];
    }];
}

- (NSError *)synchronizeMethodWithRunnerBlock:(void (^)(EMSCompletionBlock completion))runnerBlock {
    __block NSError *result = [NSError errorWithCode:-1408
                                localizedDescription:@"SDK method timeout error"];
    [self.waiter enter];
    if (runnerBlock) {
        __weak typeof(self) weakSelf = self;
        EMSCompletionBlock completionBlock = ^(NSError *error) {
            result = error;
            [weakSelf.waiter exit];
        };
        [self.coreQueue addOperationWithBlock:^{
            runnerBlock(completionBlock);
        }];
    }
    [self.waiter waitWithInterval:METHOD_TIMEOUT];
    return result;
}

- (void)changeMerchantId:(nullable NSString *)merchantId {
    [self changeMerchantId:merchantId
           completionBlock:nil];
}

- (void)changeMerchantId:(NSString *)merchantId
         completionBlock:(EMSCompletionBlock)completionHandler {
    [self.waiter enter];
    __weak typeof(self) weakSelf = self;
    [self.coreQueue addOperationWithBlock:^{
        [self.contactClient clearContact];
        self.preRequestContext.merchantId = merchantId;
        [weakSelf.waiter exit];
    }];
    [self.waiter waitWithInterval:5];
    if (completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil);
        });
    }
}

- (NSString *)applicationCode {
    return self.meRequestContext.applicationCode;
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (NSString *)hardwareId {
    return [self.deviceInfo clientId];
}
#pragma clang diagnostic pop

- (NSString *)clientId {
    return [self.deviceInfo clientId];
}

- (NSString *)languageCode {
    return [self.deviceInfo languageCode];
}

- (NSDictionary *)pushSettings {
    return [self.deviceInfo pushSettings];
}

- (NSString *)sdkVersion {
    return EMARSYS_SDK_VERSION;
}

- (void)handleErrorWithLabel:(NSString *)label
    applicationCode:(NSString *)applicationCode
              error:(NSError *)error
    completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"source"] = label;
    parameters[@"message"] = error.description;

    EMSLog([[EMSStatusLog alloc] initWithClass:[self class]
                                           sel:@selector(handleErrorWithLabel:applicationCode:error:completionBlock:)
                                    parameters:parameters
                                        status:nil], LogLevelError);
    [self.endpoint reset];
    [self.logger reset];
    NSLog(@"EmarsysSDK - ApplicationCode(%@) not found. Consult with your Implementation Consultant", applicationCode);
    if (completionBlock) {
        completionBlock(error);
    }
}

@end
