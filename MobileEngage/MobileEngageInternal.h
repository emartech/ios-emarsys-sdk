//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSNotification.h"
#import "MEInAppTrackingProtocol.h"
#import "EMSResponseModel.h"
#import "EMSRequestManager.h"
#import "EMSPushNotificationProtocol.h"
#import "EMSMobileEngageProtocol.h"
#import "EMSDeepLinkProtocol.h"

@protocol MobileEngageStatusDelegate;
@class EMSConfig;
@class MENotificationCenterManager;
@class MERequestContext;
@class MEInApp;
@class MERequestModelRepositoryFactory;
@class MELogRepository;
@class EMSNotificationCache;

NS_ASSUME_NONNULL_BEGIN

typedef void (^MESuccessBlock)(NSString *requestId, EMSResponseModel *);

typedef void (^MEErrorBlock)(NSString *requestId, NSError *error);

typedef void (^MESourceHandler)(NSString *source);


@interface MobileEngageInternal : NSObject <EMSMobileEngageProtocol, MEInAppTrackingProtocol>

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MESuccessBlock successBlock;
@property(nonatomic, strong) MEErrorBlock errorBlock;

@property(nonatomic, weak, nullable) id <MobileEngageStatusDelegate> statusDelegate;
@property(nonatomic, strong) NSData *pushToken;
@property(nonatomic, strong, nullable) MENotificationCenterManager *notificationCenterManager;
@property(nonatomic, strong) MERequestContext *requestContext;

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                     notificationCache:(EMSNotificationCache *)notificationCache;

- (NSString *)trackInternalCustomEvent:(NSString *)eventName
                       eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                       completionBlock:(nullable EMSCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
