//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AdSupport/AdSupport.h>
#import "EMSDependencyContainer.h"
#import "MERequestContext.h"
#import "MEInApp.h"
#import "EMSShardRepository.h"
#import "EMSSQLiteHelper.h"
#import "MERequestModelRepositoryFactory.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSPredictInternal.h"
#import "PRERequestContext.h"
#import "EMSUUIDProvider.h"
#import "EMSSchemaContract.h"
#import "EMSPredictMapper.h"
#import "EMSAbstractResponseHandler.h"
#import "EMSVisitorIdResponseHandler.h"
#import "MEInbox.h"
#import "EMSNotificationCenterManager.h"
#import "EMSDefaultWorker.h"
#import "MEIAMResponseHandler.h"
#import "MEIAMCleanupResponseHandler.h"
#import "MEDefaultHeaders.h"
#import "EMSAppStartBlockProvider.h"
#import "EMSWindowProvider.h"
#import "EMSMainWindowProvider.h"
#import "EMSViewControllerProvider.h"
#import "MEUserNotificationDelegate.h"
#import "EMSLogger.h"
#import "EMSBatchingShardTrigger.h"
#import "EMSListChunker.h"
#import "EMSCountPredicate.h"
#import "EMSFilterByTypeSpecification.h"
#import "EMSLogMapper.h"
#import "EMSDeviceInfo.h"
#import "EmarsysSDKVersion.h"
#import "EMSOperationQueue.h"
#import "EMSRESTClientCompletionProxyFactory.h"
#import "EMSClientStateResponseHandler.h"
#import "EMSRequestFactory.h"
#import "EMSV3Mapper.h"
#import "EMSPushV3Internal.h"
#import "EMSContactTokenResponseHandler.h"
#import "EMSInAppInternal.h"
#import "EMSCompletionProxyFactory.h"
#import "EMSRefreshTokenResponseHandler.h"
#import "EMSContactTokenMapper.h"
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EMSDeepLinkInternal.h"
#import "EMSNotificationCache.h"
#import "EMSMobileEngageV3Internal.h"
#import "EMSCompletionMiddleware.h"
#import "EMSRequestManager.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EMSLoggingPredictInternal.h"
#import "EMSLoggingPushInternal.h"
#import "EMSLoggingInbox.h"
#import "EMSLoggingUserNotificationDelegate.h"
#import "EMSLoggingInApp.h"
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSLoggingDeepLinkInternal.h"
#import "EMSPredictRequestModelBuilderProvider.h"
#import "EMSProductMapper.h"
#import "EMSConfigProtocol.h"
#import "EMSConfigInternal.h"
#import "EMSXPResponseHandler.h"
#import "EMSEmarsysRequestFactory.h"
#import "EMSCompletionBlockProvider.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSValueProvider.h"
#import "EMSEndpoint.h"
#import "EMSStorage.h"
#import "EMSSceneProvider.h"
#import "EMSActionFactory.h"
#import "EMSGeofenceInternal.h"
#import "EMSGeofenceResponseMapper.h"
#import "EMSLoggingGeofenceInternal.h"
#import "EMSInboxV3.h"
#import "EMSInboxResultParser.h"
#import "EMSLoggingInboxV3.h"
#import "EMSRandomProvider.h"
#import "EMSCrypto.h"
#import "EMSQueueDelegator.h"
#import "EMSDispatchWaiter.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]

@interface EMSDependencyContainer ()

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) PRERequestContext *predictRequestContext;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) EMSNotificationCenterManager *notificationCenterManager;
@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) id <EMSMobileEngageProtocol> mobileEngage;
@property(nonatomic, strong) id <EMSMobileEngageProtocol> loggingMobileEngage;
@property(nonatomic, strong) id <EMSDeepLinkProtocol> deepLink;
@property(nonatomic, strong) id <EMSDeepLinkProtocol> loggingDeepLink;
@property(nonatomic, strong) id <EMSPushNotificationProtocol> push;
@property(nonatomic, strong) id <EMSPushNotificationProtocol> loggingPush;
@property(nonatomic, strong) id <EMSInboxProtocol> inbox;
@property(nonatomic, strong) id <EMSInboxProtocol> loggingInbox;
@property(nonatomic, strong) id <EMSInAppProtocol, MEIAMProtocol> iam;
@property(nonatomic, strong) id <EMSInAppProtocol, MEIAMProtocol> loggingIam;
@property(nonatomic, strong) id <EMSPredictProtocol, EMSPredictInternalProtocol> predict;
@property(nonatomic, strong) id <EMSPredictProtocol, EMSPredictInternalProtocol> loggingPredict;
@property(nonatomic, strong) id <EMSGeofenceProtocol> geofence;
@property(nonatomic, strong) id <EMSGeofenceProtocol> loggingGeofence;
@property(nonatomic, strong) id <EMSMessageInboxProtocol> messageInbox;
@property(nonatomic, strong) id <EMSMessageInboxProtocol> loggingMessageInbox;
@property(nonatomic, strong) id <EMSUserNotificationCenterDelegate> notificationCenterDelegate;
@property(nonatomic, strong) id <EMSUserNotificationCenterDelegate> loggingNotificationCenterDelegate;

@property(nonatomic, strong) id <EMSConfigProtocol> config;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, strong) EMSNotificationCache *notificationCache;
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSAppStartBlockProvider *appStartBlockProvider;
@property(nonatomic, strong) EMSLogger *logger;
@property(nonatomic, strong) id <EMSDBTriggerProtocol> predictTrigger;
@property(nonatomic, strong) id <EMSDBTriggerProtocol> loggerTrigger;
@property(nonatomic, strong) id <EMSDeviceInfoClientProtocol> deviceInfoClient;
@property(nonatomic, strong) NSArray <NSString *> *suiteNames;
@property(nonatomic, strong) EMSStorage *storage;
@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSQueueDelegator *predictDelegator;

@property(nonatomic, strong) EMSQueueDelegator *mobileEngageDelegator;
@property(nonatomic, strong) EMSQueueDelegator *deepLinkDelegator;
@property(nonatomic, strong) EMSQueueDelegator *pushDelegator;
@property(nonatomic, strong) EMSQueueDelegator *inboxDelegator;
@property(nonatomic, strong) EMSQueueDelegator *notificationCenterDelegateDelegator;
@property(nonatomic, strong) EMSQueueDelegator *messageInboxDelegator;
@property(nonatomic, strong) EMSQueueDelegator *configDelegator;
@property(nonatomic, strong) EMSQueueDelegator *geofenceDelegator;
@property(nonatomic, strong) EMSQueueDelegator *iamDelegator;
@property(nonatomic, strong) CLLocationManager *locationManager;

@property(nonatomic, strong) NSOperationQueue *publicApiOperationQueue;
@property(nonatomic, strong) NSOperationQueue *coreOperationQueue;

- (void)initializeDependenciesWithConfig:(EMSConfig *)config;

@end

@implementation EMSDependencyContainer

- (instancetype)initWithConfig:(EMSConfig *)config {
    if (self = [super init]) {
        _uuidProvider = [EMSUUIDProvider new];
        _publicApiOperationQueue = [EMSOperationQueue new];
        _publicApiOperationQueue.maxConcurrentOperationCount = 1;
        _publicApiOperationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        _publicApiOperationQueue.name = [NSString stringWithFormat:@"public_api_queue_%@",
                                                                   [self.uuidProvider provideUUIDString]];
        _coreOperationQueue = [EMSOperationQueue new];
        _coreOperationQueue.maxConcurrentOperationCount = 1;
        _coreOperationQueue.qualityOfService = NSQualityOfServiceUtility;
        _coreOperationQueue.name = [NSString stringWithFormat:@"core_sdk_queue_%@",
                                                              [self.uuidProvider provideUUIDString]];

        _predictDelegator = [EMSQueueDelegator alloc];
        [self.predictDelegator setupWithQueue:self.publicApiOperationQueue
                                  emptyTarget:[EMSPredictInternal new]];
        _predict = (id <EMSPredictProtocol, EMSPredictInternalProtocol>) self.predictDelegator;

        _mobileEngageDelegator = [EMSQueueDelegator alloc];
        [self.mobileEngageDelegator setupWithQueue:self.publicApiOperationQueue
                                       emptyTarget:[EMSMobileEngageV3Internal new]];
        _mobileEngage = (id <EMSMobileEngageProtocol>) self.mobileEngageDelegator;

        _deepLinkDelegator = [EMSQueueDelegator alloc];
        [self.deepLinkDelegator setupWithQueue:self.publicApiOperationQueue
                                   emptyTarget:[EMSDeepLinkInternal new]];
        _deepLink = (id <EMSDeepLinkProtocol>) self.deepLinkDelegator;

        _pushDelegator = [EMSQueueDelegator alloc];
        [self.pushDelegator setupWithQueue:self.publicApiOperationQueue
                               emptyTarget:[EMSPushV3Internal new]];
        _push = (id <EMSPushNotificationProtocol>) self.pushDelegator;

        _inboxDelegator = [EMSQueueDelegator alloc];
        [self.inboxDelegator setupWithQueue:self.publicApiOperationQueue
                                emptyTarget:[MEInbox new]];
        _inbox = (id <EMSInboxProtocol>) self.inboxDelegator;

        _notificationCenterDelegateDelegator = [EMSQueueDelegator alloc];
        [self.notificationCenterDelegateDelegator setupWithQueue:self.publicApiOperationQueue
                                                     emptyTarget:[MEUserNotificationDelegate new]];
        _notificationCenterDelegate = (id <EMSUserNotificationCenterDelegate>) self.notificationCenterDelegateDelegator;

        _messageInboxDelegator = [EMSQueueDelegator alloc];
        [self.messageInboxDelegator setupWithQueue:self.publicApiOperationQueue
                                       emptyTarget:[EMSInboxV3 new]];
        _messageInbox = (id <EMSMessageInboxProtocol>) self.messageInboxDelegator;

        _configDelegator = [EMSQueueDelegator alloc];
        [self.configDelegator setupWithQueue:self.publicApiOperationQueue
                                 emptyTarget:[EMSConfigInternal new]];
        _config = (id <EMSConfigProtocol>) self.configDelegator;

        _geofenceDelegator = [EMSQueueDelegator alloc];
        [self.geofenceDelegator setupWithQueue:self.publicApiOperationQueue
                                   emptyTarget:[EMSGeofenceInternal new]];
        _geofence = (id <EMSGeofenceProtocol>) self.geofenceDelegator;

        _iamDelegator = [EMSQueueDelegator alloc];
        [self.iamDelegator setupWithQueue:self.publicApiOperationQueue
                              emptyTarget:[MEInApp new]];
        _iam = (id <EMSInAppProtocol, MEIAMProtocol>) self.iamDelegator;

        _locationManager = [CLLocationManager new];

        NSBlockOperation *initOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self initializeDependenciesWithConfig:config];
        }];
        initOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
        [_publicApiOperationQueue addOperation:initOperation];
    }
    return self;
}

- (void)initializeDependenciesWithConfig:(EMSConfig *)config {
    EMSValueProvider *clientServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-client.eservice.emarsys.net"
                                                                                       valueKey:@"CLIENT_SERVICE_URL"];
    EMSValueProvider *eventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://mobile-events.eservice.emarsys.net"
                                                                                      valueKey:@"EVENT_SERVICE_URL"];
    EMSValueProvider *predictUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://recommender.scarabresearch.com"
                                                                                 valueKey:@"PREDICT_URL"];
    EMSValueProvider *deeplinkUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://deep-link.eservice.emarsys.net/api/clicks"
                                                                                  valueKey:@"DEEPLINK_URL"];
    EMSValueProvider *v2EventServiceUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"
                                                                                        valueKey:@"V2_EVENT_SERVICE_URL"];
    EMSValueProvider *inboxUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-inbox.eservice.emarsys.net/api/"
                                                                               valueKey:@"INBOX_URL"];
    EMSValueProvider *v3MessageInboxUrlProdider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-inbox.eservice.emarsys.net"
                                                                                        valueKey:@"V3_MESSAGE_INBOX_URL"];
    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                              eventServiceUrlProvider:eventServiceUrlProvider
                                                   predictUrlProvider:predictUrlProvider
                                                  deeplinkUrlProvider:deeplinkUrlProvider
                                            v2EventServiceUrlProvider:v2EventServiceUrlProvider
                                                     inboxUrlProvider:inboxUrlProvider
                                            v3MessageInboxUrlProvider:v3MessageInboxUrlProdider];

    EMSRandomProvider *randomProvider = [EMSRandomProvider new];
    EMSTimestampProvider *timestampProvider = [EMSTimestampProvider new];

    _suiteNames = @[@"com.emarsys.core", @"com.emarsys.predict", @"com.emarsys.mobileengage"];
    _storage = [[EMSStorage alloc] initWithOperationQueue:self.coreOperationQueue
                                               suiteNames:self.suiteNames];

    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:EMARSYS_SDK_VERSION
                                                       notificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                  storage:self.storage
                                                        identifierManager:[ASIdentifierManager sharedManager]];

    _requestContext = [[MERequestContext alloc] initWithApplicationCode:config.applicationCode
                                                         contactFieldId:config.contactFieldId
                                                           uuidProvider:self.uuidProvider
                                                      timestampProvider:timestampProvider
                                                             deviceInfo:deviceInfo];
    _predictRequestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                     uuidProvider:self.uuidProvider
                                                                       merchantId:config.merchantId
                                                                       deviceInfo:deviceInfo];

    _requestFactory = [[EMSRequestFactory alloc] initWithRequestContext:self.requestContext
                                                               endpoint:self.endpoint];
    _notificationCenterManager = [[EMSNotificationCenterManager alloc] initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                               schemaDelegate:[EMSSqliteSchemaHandler new]];
    MEDisplayedIAMRepository *displayedIAMRepository = [[MEDisplayedIAMRepository alloc] initWithDbHelper:self.dbHelper];
    MEButtonClickRepository *buttonClickRepository = [[MEButtonClickRepository alloc] initWithDbHelper:self.dbHelper];

    [self.iamDelegator proxyWithTargetObject:[[MEInApp alloc] initWithWindowProvider:[[EMSWindowProvider alloc] initWithViewControllerProvider:[EMSViewControllerProvider new]
                                                                                                                                 sceneProvider:[[EMSSceneProvider alloc] initWithApplication:[UIApplication sharedApplication]]]
                                                                  mainWindowProvider:[[EMSMainWindowProvider alloc] initWithApplication:[UIApplication sharedApplication]]
                                                                   timestampProvider:timestampProvider
                                                             completionBlockProvider:[[EMSCompletionBlockProvider alloc] initWithOperationQueue:self.coreOperationQueue]
                                                              displayedIamRepository:displayedIAMRepository
                                                               buttonClickRepository:buttonClickRepository]];
    _loggingIam = [EMSLoggingInApp new];
    [_dbHelper open];

    EMSShardRepository *shardRepository = [[EMSShardRepository alloc] initWithDbHelper:self.dbHelper];
    MERequestModelRepositoryFactory *requestRepositoryFactory = [[MERequestModelRepositoryFactory alloc] initWithInApp:self.iam
                                                                                                        requestContext:self.requestContext
                                                                                                              dbHelper:self.dbHelper
                                                                                                 buttonClickRepository:buttonClickRepository
                                                                                                displayedIAMRepository:displayedIAMRepository
                                                                                                              endpoint:self.endpoint];

    _requestRepository = [requestRepositoryFactory createWithBatchCustomEventProcessing:YES];

    _logger = [[EMSLogger alloc] initWithShardRepository:shardRepository
                                          opertaionQueue:self.coreOperationQueue
                                       timestampProvider:timestampProvider
                                            uuidProvider:self.uuidProvider
                                                 storage:self.storage];

    EMSCompletionMiddleware *middleware = [self createMiddleware];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:30.0];
    [sessionConfiguration setHTTPCookieStorage:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:nil
                                                     delegateQueue:self.coreOperationQueue];

    EMSContactTokenResponseHandler *contactTokenResponseHandler = [[EMSContactTokenResponseHandler alloc] initWithRequestContext:self.requestContext
                                                                                                                        endpoint:self.endpoint];
    NSMutableArray<EMSAbstractResponseHandler *> *responseHandlers = [NSMutableArray array];
    [self.dbHelper open];
    [responseHandlers addObjectsFromArray:@[
            [[MEIAMResponseHandler alloc] initWithInApp:self.iam],
            [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:buttonClickRepository
                                                          displayIamRepository:displayedIAMRepository
                                                                      endpoint:self.endpoint]]
    ];
    [responseHandlers addObject:[[EMSVisitorIdResponseHandler alloc] initWithRequestContext:self.predictRequestContext
                                                                                   endpoint:self.endpoint]];
    [responseHandlers addObject:[[EMSXPResponseHandler alloc] initWithRequestContext:self.predictRequestContext
                                                                            endpoint:self.endpoint]];
    [responseHandlers addObject:[[EMSClientStateResponseHandler alloc] initWithRequestContext:self.requestContext
                                                                                     endpoint:self.endpoint]];
    [responseHandlers addObject:[[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:self.requestContext
                                                                                      endpoint:self.endpoint]];
    [responseHandlers addObject:contactTokenResponseHandler];
    _responseHandlers = [NSArray arrayWithArray:responseHandlers];

    _restClient = [[EMSRESTClient alloc] initWithSession:session
                                                   queue:self.coreOperationQueue
                                       timestampProvider:timestampProvider
                                       additionalHeaders:[MEDefaultHeaders additionalHeaders]
                                     requestModelMappers:@[
                                             [[EMSContactTokenMapper alloc] initWithRequestContext:self.requestContext
                                                                                          endpoint:self.endpoint],
                                             [[EMSV3Mapper alloc] initWithRequestContext:self.requestContext
                                                                                endpoint:self.endpoint]]
                                        responseHandlers:self.responseHandlers];

    EMSRESTClientCompletionProxyFactory *proxyFactory = [[EMSCompletionProxyFactory alloc] initWithRequestRepository:self.requestRepository
                                                                                                      operationQueue:self.coreOperationQueue
                                                                                                 defaultSuccessBlock:middleware.successBlock
                                                                                                   defaultErrorBlock:middleware.errorBlock
                                                                                                          restClient:self.restClient
                                                                                                      requestFactory:self.requestFactory
                                                                                              contactResponseHandler:contactTokenResponseHandler
                                                                                                            endpoint:self.endpoint
                                                                                                             storage:self.storage];

    EMSReachability *reachability = [EMSReachability reachabilityForInternetConnectionWithOperationQueue:self.coreOperationQueue];

    EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithReachability:reachability
                                                                           operationQueue:self.coreOperationQueue];
    EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithOperationQueue:self.coreOperationQueue
                                                              requestRepository:self.requestRepository
                                                             connectionWatchdog:watchdog
                                                                     restClient:self.restClient
                                                                     errorBlock:middleware.errorBlock
                                                                   proxyFactory:proxyFactory];

    _requestManager = [[EMSRequestManager alloc] initWithCoreQueue:self.coreOperationQueue
                                              completionMiddleware:middleware
                                                        restClient:self.restClient
                                                            worker:worker
                                                 requestRepository:self.requestRepository
                                                   shardRepository:shardRepository
                                                      proxyFactory:proxyFactory];

    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.predict]) {
        _predictTrigger = [[EMSBatchingShardTrigger alloc] initWithRepository:shardRepository
                                                                specification:[[EMSFilterByTypeSpecification alloc] initWitType:@"predict_%%"
                                                                                                                         column:SHARD_COLUMN_NAME_TYPE]
                                                                       mapper:[[EMSPredictMapper alloc] initWithRequestContext:self.predictRequestContext
                                                                                                                      endpoint:self.endpoint]
                                                                      chunker:[[EMSListChunker alloc] initWithChunkSize:1]
                                                                    predicate:[[EMSCountPredicate alloc] initWithThreshold:1]
                                                               requestManager:self.requestManager
                                                                   persistent:YES];
        [_dbHelper registerTriggerWithTableName:SHARD_TABLE_NAME
                                    triggerType:EMSDBTriggerType.afterType
                                   triggerEvent:EMSDBTriggerEvent.insertEvent
                                        trigger:self.predictTrigger];
    }

    _loggerTrigger = [[EMSBatchingShardTrigger alloc] initWithRepository:shardRepository
                                                           specification:[[EMSFilterByTypeSpecification alloc] initWitType:@"log_%%"
                                                                                                                    column:SHARD_COLUMN_NAME_TYPE]
                                                                  mapper:[[EMSLogMapper alloc] initWithRequestContext:self.requestContext
                                                                                                      applicationCode:config.applicationCode
                                                                                                           merchantId:config.merchantId]
                                                                 chunker:[[EMSListChunker alloc] initWithChunkSize:10]
                                                               predicate:[[EMSCountPredicate alloc] initWithThreshold:10]
                                                          requestManager:self.requestManager
                                                              persistent:NO];
    [_dbHelper registerTriggerWithTableName:SHARD_TABLE_NAME
                                triggerType:EMSDBTriggerType.afterType
                               triggerEvent:EMSDBTriggerEvent.insertEvent
                                    trigger:self.loggerTrigger];

    _notificationCache = [[EMSNotificationCache alloc] init];

    _deviceInfoClient = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.requestManager
                                                                       requestFactory:self.requestFactory
                                                                           deviceInfo:deviceInfo
                                                                       requestContext:self.requestContext];

    UIApplication *application = [UIApplication sharedApplication];

    EMSPredictRequestModelBuilderProvider *builderProvider = [[EMSPredictRequestModelBuilderProvider alloc] initWithRequestContext:self.predictRequestContext
                                                                                                                          endpoint:self.endpoint];
    [self.predictDelegator proxyWithTargetObject:[[EMSPredictInternal alloc] initWithRequestContext:self.predictRequestContext
                                                                                     requestManager:self.requestManager
                                                                             requestBuilderProvider:builderProvider
                                                                                      productMapper:[EMSProductMapper new]]];
    _loggingPredict = [EMSLoggingPredictInternal new];

    [self.mobileEngageDelegator proxyWithTargetObject:[[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.requestFactory
                                                                                                 requestManager:self.requestManager
                                                                                                 requestContext:self.requestContext
                                                                                                        storage:self.storage]];

    EMSActionFactory *actionFactory = [[EMSActionFactory alloc] initWithApplication:application
                                                                       mobileEngage:self.mobileEngage];

    [self.deepLinkDelegator proxyWithTargetObject:[[EMSDeepLinkInternal alloc] initWithRequestManager:self.requestManager
                                                                                       requestFactory:self.requestFactory]];

    [self.pushDelegator proxyWithTargetObject:[[EMSPushV3Internal alloc] initWithRequestFactory:self.requestFactory
                                                                                 requestManager:self.requestManager
                                                                              notificationCache:self.notificationCache
                                                                              timestampProvider:timestampProvider
                                                                                  actionFactory:actionFactory
                                                                                        storage:self.storage]];

    [self.inboxDelegator proxyWithTargetObject:[[MEInbox alloc] initWithRequestContext:self.requestContext
                                                                     notificationCache:self.notificationCache
                                                                        requestManager:self.requestManager
                                                                        requestFactory:self.requestFactory
                                                                              endpoint:self.endpoint]];

    [self.notificationCenterDelegateDelegator proxyWithTargetObject:[[MEUserNotificationDelegate alloc] initWithActionFactory:actionFactory
                                                                                                                        inApp:self.iam
                                                                                                            timestampProvider:timestampProvider
                                                                                                                 uuidProvider:self.uuidProvider
                                                                                                                 pushInternal:self.push
                                                                                                               requestManager:self.requestManager
                                                                                                               requestFactory:self.requestFactory]];

    EMSGeofenceInternal *geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.requestFactory
                                                                                 requestManager:self.requestManager
                                                                                 responseMapper:[[EMSGeofenceResponseMapper alloc] init]
                                                                                locationManager:self.locationManager
                                                                                  actionFactory:actionFactory
                                                                                        storage:self.storage
                                                                                          queue:self.coreOperationQueue];

    [self.messageInboxDelegator proxyWithTargetObject:[[EMSInboxV3 alloc] initWithRequestFactory:self.requestFactory
                                                                                  requestManager:self.requestManager
                                                                               inboxResultParser:[[EMSInboxResultParser alloc] init]]];

    EMSEmarsysRequestFactory *emarsysRequestFactory = [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:timestampProvider
                                                                                                     uuidProvider:self.uuidProvider
                                                                                                         endpoint:self.endpoint
                                                                                                   requestContext:self.requestContext];
    [self.configDelegator proxyWithTargetObject:[[EMSConfigInternal alloc] initWithRequestManager:self.requestManager
                                                                                 meRequestContext:self.requestContext
                                                                                preRequestContext:self.predictRequestContext
                                                                                     mobileEngage:self.mobileEngage
                                                                                     pushInternal:self.push
                                                                                       deviceInfo:deviceInfo
                                                                            emarsysRequestFactory:emarsysRequestFactory
                                                                       remoteConfigResponseMapper:[[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:randomProvider]
                                                                                         endpoint:self.endpoint
                                                                                           logger:self.logger
                                                                                           crypto:[[EMSCrypto alloc] init]
                                                                                            queue:self.coreOperationQueue
                                                                                           waiter:[EMSDispatchWaiter new]]];

    [self.geofenceDelegator proxyWithTargetObject:geofenceInternal];

    _appStartBlockProvider = [[EMSAppStartBlockProvider alloc] initWithRequestManager:self.requestManager
                                                                       requestFactory:self.requestFactory
                                                                       requestContext:self.requestContext
                                                                     deviceInfoClient:self.deviceInfoClient
                                                                       configInternal:self.config
                                                                     geofenceInternal:(id) self.geofenceDelegator];

    _loggingMobileEngage = [EMSLoggingMobileEngageInternal new];
    _loggingDeepLink = [EMSLoggingDeepLinkInternal new];
    _loggingPush = [EMSLoggingPushInternal new];
    _loggingInbox = [EMSLoggingInbox new];
    _loggingNotificationCenterDelegate = [EMSLoggingUserNotificationDelegate new];
    _loggingGeofence = [EMSLoggingGeofenceInternal new];
    _loggingMessageInbox = [EMSLoggingInboxV3 new];

    [self.iam setInAppTracker:[[EMSInAppInternal alloc] initWithRequestManager:self.requestManager
                                                                requestFactory:self.requestFactory]];
}

- (EMSCompletionMiddleware *)createMiddleware {
    return [[EMSCompletionMiddleware alloc] initWithSuccessBlock:[self createSuccessBlock]
                                                      errorBlock:[self createErrorBlock]];
}

- (void (^)(NSString *, EMSResponseModel *))createSuccessBlock {
    return ^(NSString *requestId, EMSResponseModel *response) {
    };
}

- (void (^)(NSString *, NSError *))createErrorBlock {
    return ^(NSString *requestId, NSError *error) {
    };
}

@end
