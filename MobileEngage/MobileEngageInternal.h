//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEAppLoginParameters.h"
#import "EMSNotification.h"
#import "MEInAppTrackingProtocol.h"
#import "EMSResponseModel.h"
#import "EMSRequestManager.h"
#import "EMSPushNotificationProtocol.h"

@protocol MobileEngageStatusDelegate;
@class EMSConfig;
@class MENotificationCenterManager;
@class MERequestContext;
@class MEInApp;
@class MERequestModelRepositoryFactory;
@class MELogRepository;

NS_ASSUME_NONNULL_BEGIN

typedef void (^MESuccessBlock)(NSString *requestId, EMSResponseModel *);
typedef void (^MEErrorBlock)(NSString *requestId, NSError *error);
typedef void (^MESourceHandler)(NSString *source);


@interface MobileEngageInternal : NSObject <MEInAppTrackingProtocol, EMSPushNotificationProtocol>

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MESuccessBlock successBlock;
@property(nonatomic, strong) MEErrorBlock errorBlock;

@property(nonatomic, weak, nullable) id <MobileEngageStatusDelegate> statusDelegate;
@property(nonatomic, strong) NSData *pushToken;
@property(nonatomic, strong, nullable) MENotificationCenterManager *notificationCenterManager;
@property(nonatomic, strong) MERequestContext *requestContext;

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
             notificationCenterManager:(MENotificationCenterManager *)notificationCenterManager;

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable MESourceHandler)sourceHandler;

//- (void) setupWithConfig:(nonnull EMSConfig *)config
//           launchOptions:(NSDictionary *)launchOptions
//requestRepositoryFactory:(MERequestModelRepositoryFactory *)requestRepositoryFactory
//         shardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
//           logRepository:(MELogRepository *)logRepository
//          requestContext:(MERequestContext *)requestContext;

- (NSString *)appLogin;

- (NSString *)appLoginWithContactFieldValue:(NSString *)contactFieldValue;

- (NSString *)trackCustomEvent:(NSString *)eventName
               eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes;

- (NSString *)trackInternalCustomEvent:(NSString *)eventName
                       eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes;

- (NSString *)appLogout;

@end

NS_ASSUME_NONNULL_END
