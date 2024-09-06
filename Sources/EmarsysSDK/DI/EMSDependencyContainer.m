//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
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
#import "EMSNotificationCenterManager.h"
#import "EMSDefaultWorker.h"
#import "MEIAMResponseHandler.h"
#import "MEIAMCleanupResponseHandlerV3.h"
#import "MEDefaultHeaders.h"
#import "EMSAppStartBlockProvider.h"
#import "EMSWindowProvider.h"
#import "EMSMainWindowProvider.h"
#import "EMSViewControllerProvider.h"
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
#import "EMSMobileEngageMapper.h"
#import "EMSPushV3Internal.h"
#import "EMSContactTokenResponseHandler.h"
#import "EMSInAppInternal.h"
#import "EMSCompletionProxyFactory.h"
#import "EMSRefreshTokenResponseHandler.h"
#import "EMSContactTokenMapper.h"
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EMSDeepLinkInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "EMSCompletionMiddleware.h"
#import "EMSRequestManager.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EMSLoggingPredictInternal.h"
#import "EMSLoggingPushInternal.h"
#import "EMSLoggingInApp.h"
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSLoggingOnEventActionInternal.h"
#import "EMSPredictRequestModelBuilderProvider.h"
#import "EMSProductMapper.h"
#import "EMSConfigProtocol.h"
#import "EMSConfigInternal.h"
#import "EMSXPResponseHandler.h"
#import "EMSEmarsysRequestFactory.h"
#import "EMSCompletionProvider.h"
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSValueProvider.h"
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
#import "EMSOnEventActionInternal.h"
#import "EMSOnEventResponseHandler.h"
#import "EMSSession.h"
#import "MEIAMCleanupResponseHandlerV4.h"
#import "EMSDeviceEventStateResponseHandler.h"
#import "EMSOpenIdTokenMapper.h"
#import "EMSMobileEngageNullSafeBodyParser.h"
#import "EMSWrapperChecker.h"
#import "EMSSdkStateLogger.h"
#import "EMSInMemoryStorage.h"
#import "EMSDeviceEventStateRequestMapper.h"
#import "EMSContactClientInternal.h"
#import "EMSLoggingContactClientInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "EMSCompletionBlockProvider.h"

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
@property(nonatomic, strong) id <EMSContactClientProtocol> contactClient;
@property(nonatomic, strong) id <EMSContactClientProtocol> loggingContactClient;
@property(nonatomic, strong) id <EMSDeepLinkProtocol> deepLink;
@property(nonatomic, strong) id <EMSPushNotificationProtocol> push;
@property(nonatomic, strong) id <EMSPushNotificationProtocol> loggingPush;
@property(nonatomic, strong) id <EMSInAppProtocol, MEIAMProtocol> iam;
@property(nonatomic, strong) id <EMSInAppProtocol, MEIAMProtocol> loggingIam;
@property(nonatomic, strong) id <EMSPredictProtocol, EMSPredictInternalProtocol> predict;
@property(nonatomic, strong) id <EMSPredictProtocol, EMSPredictInternalProtocol> loggingPredict;
@property(nonatomic, strong) id <EMSGeofenceProtocol> geofence;
@property(nonatomic, strong) id <EMSGeofenceProtocol> loggingGeofence;
@property(nonatomic, strong) id <EMSMessageInboxProtocol> messageInbox;
@property(nonatomic, strong) id <EMSMessageInboxProtocol> loggingMessageInbox;
@property(nonatomic, strong) id <EMSOnEventActionProtocol> onEventAction;
@property(nonatomic, strong) id <EMSOnEventActionProtocol> loggingOnEventAction;

@property(nonatomic, strong) id <EMSConfigProtocol> config;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, strong) NSMutableArray<EMSAbstractResponseHandler *> *responseHandlers;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSAppStartBlockProvider *appStartBlockProvider;
@property(nonatomic, strong) EMSLogger *logger;
@property(nonatomic, strong) id <EMSDBTriggerProtocol> predictTrigger;
@property(nonatomic, strong) id <EMSDBTriggerProtocol> loggerTrigger;
@property(nonatomic, strong) id <EMSDeviceInfoClientProtocol> deviceInfoClient;
@property(nonatomic, strong) NSArray <NSString *> *suiteNames;
@property(nonatomic, strong) id <EMSStorageProtocol> storage;
@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSQueueDelegator *predictDelegator;

@property(nonatomic, strong) EMSQueueDelegator *mobileEngageDelegator;
@property(nonatomic, strong) EMSQueueDelegator *contactClientDelegator;
@property(nonatomic, strong) EMSQueueDelegator *deepLinkDelegator;
@property(nonatomic, strong) EMSQueueDelegator *pushDelegator;
@property(nonatomic, strong) EMSQueueDelegator *notificationCenterDelegateDelegator;
@property(nonatomic, strong) EMSQueueDelegator *messageInboxDelegator;
@property(nonatomic, strong) EMSQueueDelegator *configDelegator;
@property(nonatomic, strong) EMSQueueDelegator *geofenceDelegator;
@property(nonatomic, strong) EMSQueueDelegator *iamDelegator;
@property(nonatomic, strong) EMSQueueDelegator *onEventActionDelegator;
@property(nonatomic, strong) CLLocationManager *locationManager;

@property(nonatomic, strong) NSOperationQueue *publicApiOperationQueue;
@property(nonatomic, strong) NSOperationQueue *coreOperationQueue;
@property(nonatomic, strong) NSOperationQueue *dbQueue;
@property(nonatomic, strong) NSOperationQueue *storageQueue;

@property(nonatomic, strong) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, copy) RouterLogicBlock mobileEngageRouterLogicBlock;
@property(nonatomic, copy) RouterLogicBlock predictRouterLogicBlock;
@property(nonatomic, copy) RouterLogicBlock contactRouterLogicBlock;
@property(nonatomic, strong) EMSSession *session;
@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) EMSWrapperChecker *wrapperChecker;
@property(nonatomic, strong) EMSCompletionBlockProvider *completionBlockProvider;

- (void)initializeDependenciesWithConfig:(EMSConfig *)config;

@end

@implementation EMSDependencyContainer

- (instancetype)initWithConfig:(EMSConfig *)config {
    if (self = [super init]) {
        _uuidProvider = [EMSUUIDProvider new];
        _publicApiOperationQueue = [self createQueueWithName:@"public_api_queue"
                                            qualityOfService:NSQualityOfServiceUserInitiated];
        _coreOperationQueue = [self createQueueWithName:@"core_sdk_queue"
                                       qualityOfService:NSQualityOfServiceUtility];
        _dbQueue = [self createQueueWithName:@"emarsys_sdk_db_queue"
                            qualityOfService:NSQualityOfServiceUtility];
        _storageQueue = [self createQueueWithName:@"emarsys_sdk_storage_queue"
                                 qualityOfService:NSQualityOfServiceUtility];

        _predictDelegator = [EMSQueueDelegator alloc];
        [self.predictDelegator setupWithQueue:self.publicApiOperationQueue
                                  emptyTarget:[EMSPredictInternal new]];
        _predict = (id <EMSPredictProtocol, EMSPredictInternalProtocol>) self.predictDelegator;

        _mobileEngageDelegator = [EMSQueueDelegator alloc];
        [self.mobileEngageDelegator setupWithQueue:self.publicApiOperationQueue
                                       emptyTarget:[EMSMobileEngageV3Internal new]];
        _mobileEngage = (id <EMSMobileEngageProtocol>) self.mobileEngageDelegator;

        _contactClientDelegator = [EMSQueueDelegator alloc];
        [self.contactClientDelegator setupWithQueue:self.publicApiOperationQueue
                                        emptyTarget:[EMSContactClientInternal new]];
        _contactClient = (id <EMSContactClientProtocol>) self.contactClientDelegator;

        _deepLinkDelegator = [EMSQueueDelegator alloc];
        [self.deepLinkDelegator setupWithQueue:self.publicApiOperationQueue
                                   emptyTarget:[EMSDeepLinkInternal new]];
        _deepLink = (id <EMSDeepLinkProtocol>) self.deepLinkDelegator;

        _pushDelegator = [EMSQueueDelegator alloc];
        [self.pushDelegator setupWithQueue:self.publicApiOperationQueue
                               emptyTarget:[EMSPushV3Internal new]];
        _push = (id <EMSPushNotificationProtocol>) self.pushDelegator;

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

        _onEventActionDelegator = [EMSQueueDelegator alloc];
        [self.onEventActionDelegator setupWithQueue:self.publicApiOperationQueue
                                        emptyTarget:[EMSOnEventActionInternal new]];
        _onEventAction = (id <EMSOnEventActionProtocol>) self.onEventActionDelegator;

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
    EMSValueProvider *v3MessageInboxUrlProdider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://me-inbox.eservice.emarsys.net"
                                                                                        valueKey:@"V3_MESSAGE_INBOX_URL"];

    UIApplication *application = [UIApplication sharedApplication];

    _mobileEngageRouterLogicBlock = ^BOOL {
        return [MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]];
    };

    _predictRouterLogicBlock = ^BOOL {
        return [MEExperimental isFeatureEnabled:[EMSInnerFeature predict]];
    };

    _contactRouterLogicBlock = ^BOOL {
        return [MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]] || [MEExperimental isFeatureEnabled:[EMSInnerFeature predict]];
    };

    _endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:clientServiceUrlProvider
                                              eventServiceUrlProvider:eventServiceUrlProvider
                                                   predictUrlProvider:predictUrlProvider
                                                  deeplinkUrlProvider:deeplinkUrlProvider
                                            v3MessageInboxUrlProvider:v3MessageInboxUrlProdider];

    EMSRandomProvider *randomProvider = [EMSRandomProvider new];
    EMSTimestampProvider *timestampProvider = [EMSTimestampProvider new];

    _completionBlockProvider = [[EMSCompletionBlockProvider alloc] initWithOperationQueue:self.publicApiOperationQueue];

    _suiteNames = @[@"com.emarsys.core", @"com.emarsys.predict", @"com.emarsys.mobileengage", @"com.emarsys.sdk"];
    EMSStorage *storage = [[EMSStorage alloc] initWithSuiteNames:self.suiteNames
                                                     accessGroup:config.sharedKeychainAccessGroup
                                                  operationQueue:self.storageQueue];
    _storage = [[EMSInMemoryStorage alloc] initWithStorage:storage];

    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:EMARSYS_SDK_VERSION
                                                       notificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                  storage:storage
                                                             uuidProvider:self.uuidProvider];

    _requestContext = [[MERequestContext alloc] initWithApplicationCode:config.applicationCode
                                                           uuidProvider:self.uuidProvider
                                                      timestampProvider:timestampProvider
                                                             deviceInfo:deviceInfo
                                                                storage:self.storage];
    _predictRequestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                     uuidProvider:self.uuidProvider
                                                                       merchantId:config.merchantId
                                                                       deviceInfo:deviceInfo];
    _notificationCenterManager = [[EMSNotificationCenterManager alloc] initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                               schemaDelegate:[EMSSqliteSchemaHandler new]
                                               operationQueue:self.dbQueue];
    [_dbHelper open];
    MEDisplayedIAMRepository *displayedIAMRepository = [[MEDisplayedIAMRepository alloc] initWithDbHelper:self.dbHelper];
    _buttonClickRepository = [[MEButtonClickRepository alloc] initWithDbHelper:self.dbHelper];

    EMSSessionIdHolder *sessionIdHolder = [EMSSessionIdHolder new];
    _requestFactory = [[EMSRequestFactory alloc] initWithRequestContext:self.requestContext
                                                  predictRequestContext:self.predictRequestContext
                                                               endpoint:self.endpoint
                                                  buttonClickRepository:self.buttonClickRepository
                                                        sessionIdHolder:sessionIdHolder
                                                                storage:self.storage];

    _loggingIam = [EMSLoggingInApp new];
    MEInApp *meInApp = [[MEInApp alloc] initWithWindowProvider:[[EMSWindowProvider alloc] initWithViewControllerProvider:[EMSViewControllerProvider new]
                                                                                                           sceneProvider:[[EMSSceneProvider alloc] initWithApplication:[UIApplication sharedApplication]]]
                                            mainWindowProvider:[[EMSMainWindowProvider alloc] initWithApplication:[UIApplication sharedApplication]]
                                             timestampProvider:timestampProvider
                                       completionBlockProvider:[[EMSCompletionProvider alloc] initWithOperationQueue:self.coreOperationQueue]
                                        displayedIamRepository:displayedIAMRepository
                                         buttonClickRepository:self.buttonClickRepository
                                                operationQueue:self.coreOperationQueue];
    EMSInstanceRouter *iamInstanceRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:meInApp
                                                                              loggingInstance:self.loggingIam
                                                                                  routerLogic:self.mobileEngageRouterLogicBlock];

    [self.iamDelegator proxyWithInstanceRouter:iamInstanceRouter];

    EMSShardRepository *shardRepository = [[EMSShardRepository alloc] initWithDbHelper:self.dbHelper];
    MERequestModelRepositoryFactory *requestRepositoryFactory = [[MERequestModelRepositoryFactory alloc] initWithInApp:self.iam
                                                                                                        requestContext:self.requestContext
                                                                                                              dbHelper:self.dbHelper
                                                                                                 buttonClickRepository:self.buttonClickRepository
                                                                                                displayedIAMRepository:displayedIAMRepository
                                                                                                              endpoint:self.endpoint
                                                                                                        operationQueue:self.coreOperationQueue
                                                                                                               storage:self.storage];

    _requestRepository = [requestRepositoryFactory createWithBatchCustomEventProcessing:YES];

    _wrapperChecker = [[EMSWrapperChecker alloc] initWithOperationQueue:self.coreOperationQueue
                                                                 waiter:[EMSDispatchWaiter new]
                                                                storage:self.storage];

    _logger = [[EMSLogger alloc] initWithShardRepository:shardRepository
                                          opertaionQueue:self.coreOperationQueue
                                       timestampProvider:timestampProvider
                                            uuidProvider:self.uuidProvider
                                                 storage:self.storage
                                          wrapperChecker:self.wrapperChecker];
    [self.logger setConsoleLogLevels:config.enabledConsoleLogLevels];

    EMSCompletionMiddleware *middleware = [self createMiddleware];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:30.0];
    [sessionConfiguration setHTTPCookieStorage:nil];
    _urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                delegate:nil
                                           delegateQueue:self.coreOperationQueue];

    EMSActionFactory *onEventActionFactory = [[EMSActionFactory alloc] initWithApplication:application
                                                                              mobileEngage:self.mobileEngage
                                                                    userNotificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                            operationQueue:self.coreOperationQueue];

    EMSInstanceRouter *onEventActionRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:[[EMSOnEventActionInternal alloc] initWithActionFactory:onEventActionFactory]
                                                                                loggingInstance:[EMSLoggingOnEventActionInternal new]
                                                                                    routerLogic:^BOOL {
        return [MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]];
    }];
    [self.onEventActionDelegator proxyWithInstanceRouter:onEventActionRouter];

    EMSContactTokenResponseHandler *contactTokenResponseHandler = [[EMSContactTokenResponseHandler alloc] initWithRequestContext:self.requestContext
                                                                                                                        endpoint:self.endpoint];
    _responseHandlers = [NSMutableArray array];
    [self.responseHandlers addObject:[[MEIAMResponseHandler alloc] initWithInApp:self.iam]];
    [self.responseHandlers addObject:[[MEIAMCleanupResponseHandlerV3 alloc] initWithButtonClickRepository:self.buttonClickRepository
                                                                                     displayIamRepository:displayedIAMRepository
                                                                                                 endpoint:self.endpoint]];
    [self.responseHandlers addObject:[[MEIAMCleanupResponseHandlerV4 alloc] initWithButtonClickRepository:self.buttonClickRepository
                                                                                     displayIamRepository:displayedIAMRepository
                                                                                                 endpoint:self.endpoint]];
    [self.responseHandlers addObject:[[EMSDeviceEventStateResponseHandler alloc] initWithStorage:self.storage
                                                                                        endpoint:self.endpoint]];
    [self.responseHandlers addObject:[[EMSVisitorIdResponseHandler alloc] initWithRequestContext:self.predictRequestContext
                                                                                        endpoint:self.endpoint]];
    [self.responseHandlers addObject:[[EMSXPResponseHandler alloc] initWithRequestContext:self.predictRequestContext
                                                                                 endpoint:self.endpoint]];
    [self.responseHandlers addObject:[[EMSClientStateResponseHandler alloc] initWithRequestContext:self.requestContext
                                                                                          endpoint:self.endpoint]];
    [self.responseHandlers addObject:[[EMSRefreshTokenResponseHandler alloc] initWithRequestContext:self.requestContext
                                                                                           endpoint:self.endpoint]];
    [self.responseHandlers addObject:contactTokenResponseHandler];

    _restClient = [[EMSRESTClient alloc] initWithSession:self.urlSession
                                                   queue:self.coreOperationQueue
                                       timestampProvider:timestampProvider
                                       additionalHeaders:[MEDefaultHeaders additionalHeaders]
                                     requestModelMappers:@[
        [[EMSContactTokenMapper alloc] initWithRequestContext:self.requestContext
                                                     endpoint:self.endpoint],
        [[EMSMobileEngageMapper alloc] initWithRequestContext:self.requestContext
                                                     endpoint:self.endpoint],
        [[EMSOpenIdTokenMapper alloc] initWithRequestContext:self.requestContext
                                                    endpoint:self.endpoint],
        [[EMSDeviceEventStateRequestMapper alloc] initWithEndpoint:self.endpoint
                                                           storage:self.storage]
    ]
                                        responseHandlers:self.responseHandlers
                                  mobileEngageBodyParser:[[EMSMobileEngageNullSafeBodyParser alloc] initWithEndpoint:self.endpoint]];

    EMSRESTClientCompletionProxyFactory *proxyFactory = [[EMSCompletionProxyFactory alloc] initWithRequestRepository:self.requestRepository
                                                                                                      operationQueue:self.coreOperationQueue
                                                                                                 defaultSuccessBlock:middleware.successBlock
                                                                                                   defaultErrorBlock:middleware.errorBlock
                                                                                                          restClient:self.restClient
                                                                                                      requestFactory:self.requestFactory
                                                                                              contactResponseHandler:contactTokenResponseHandler
                                                                                                            endpoint:self.endpoint
                                                                                                             storage:self.storage];

    EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithOperationQueue:self.coreOperationQueue];
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

    _session = [[EMSSession alloc] initWithSessionIdHolder:sessionIdHolder
                                            requestManager:self.requestManager
                                            requestFactory:self.requestFactory
                                            operationQueue:self.coreOperationQueue
                                         timestampProvider:timestampProvider];

    [self.responseHandlers addObject:[[EMSOnEventResponseHandler alloc] initWithRequestManager:self.requestManager
                                                                                requestFactory:self.requestFactory
                                                                        displayedIAMRepository:displayedIAMRepository
                                                                                 actionFactory:onEventActionFactory
                                                                             timestampProvider:timestampProvider]];

    _predictTrigger = [[EMSBatchingShardTrigger alloc] initWithRepository:shardRepository
                                                            specification:[[EMSFilterByTypeSpecification alloc] initWitType:@"predict_%%"
                                                                                                                     column:SHARD_COLUMN_NAME_TYPE]
                                                                   mapper:[[EMSPredictMapper alloc] initWithRequestContext:self.predictRequestContext
                                                                                                                  endpoint:self.endpoint]
                                                                  chunker:[[EMSListChunker alloc] initWithChunkSize:1]
                                                                predicate:[[EMSCountPredicate alloc] initWithThreshold:1]
                                                           requestManager:self.requestManager
                                                               persistent:YES
                                                       connectionWatchdog:watchdog];
    [_dbHelper registerTriggerWithTableName:SHARD_TABLE_NAME
                                triggerType:EMSDBTriggerType.afterType
                               triggerEvent:EMSDBTriggerEvent.insertEvent
                                    trigger:self.predictTrigger];

    _loggerTrigger = [[EMSBatchingShardTrigger alloc] initWithRepository:shardRepository
                                                           specification:[[EMSFilterByTypeSpecification alloc] initWitType:@"log_%%"
                                                                                                                    column:SHARD_COLUMN_NAME_TYPE]
                                                                  mapper:[[EMSLogMapper alloc] initWithRequestContext:self.requestContext
                                                                                                      applicationCode:config.applicationCode
                                                                                                           merchantId:config.merchantId]
                                                                 chunker:[[EMSListChunker alloc] initWithChunkSize:10]
                                                               predicate:[[EMSCountPredicate alloc] initWithThreshold:10]
                                                          requestManager:self.requestManager
                                                              persistent:NO
                                                      connectionWatchdog:watchdog];
    [_dbHelper registerTriggerWithTableName:SHARD_TABLE_NAME
                                triggerType:EMSDBTriggerType.afterType
                               triggerEvent:EMSDBTriggerEvent.insertEvent
                                    trigger:self.loggerTrigger];

    _deviceInfoClient = [[EMSDeviceInfoV3ClientInternal alloc] initWithRequestManager:self.requestManager
                                                                       requestFactory:self.requestFactory
                                                                           deviceInfo:deviceInfo
                                                                       requestContext:self.requestContext];

    EMSPredictRequestModelBuilderProvider *builderProvider = [[EMSPredictRequestModelBuilderProvider alloc] initWithRequestContext:self.predictRequestContext
                                                                                                                          endpoint:self.endpoint];
    _loggingPredict = [EMSLoggingPredictInternal new];
    EMSInstanceRouter *predictRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:[[EMSPredictInternal alloc] initWithRequestContext:self.predictRequestContext
                                                                                                                              requestManager:self.requestManager
                                                                                                                      requestBuilderProvider:builderProvider
                                                                                                                               productMapper:[EMSProductMapper new]]
                                                                          loggingInstance:self.loggingPredict
                                                                              routerLogic:self.predictRouterLogicBlock];
    [self.predictDelegator proxyWithInstanceRouter:predictRouter];

    _loggingMobileEngage = [EMSLoggingMobileEngageInternal new];
    EMSInstanceRouter *mobileEngageRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:[[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.requestFactory
                                                                                                                                          requestManager:self.requestManager
                                                                                                                                          requestContext:self.requestContext
                                                                                                                                                 storage:self.storage
                                                                                                                                                 session:self.session
                                                                                               completionBlockProvider:self.completionBlockProvider]
                                                                               loggingInstance:self.loggingMobileEngage
                                                                                   routerLogic:self.mobileEngageRouterLogicBlock];
    [self.mobileEngageDelegator proxyWithInstanceRouter:mobileEngageRouter];

    _loggingContactClient = [EMSLoggingContactClientInternal new];
    EMSInstanceRouter *contactClientRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:[[EMSContactClientInternal alloc] initWithRequestFactory:self.requestFactory
                                                                                                                                          requestManager:self.requestManager requestContext:self.requestContext predictRequestContext:self.predictRequestContext storage:self.storage session:self.session]  loggingInstance:self.loggingContactClient routerLogic:self.contactRouterLogicBlock];
    [self.contactClientDelegator proxyWithInstanceRouter:contactClientRouter];

    EMSActionFactory *actionFactory = [[EMSActionFactory alloc] initWithApplication:application
                                                                       mobileEngage:self.mobileEngage
                                                             userNotificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                     operationQueue:self.coreOperationQueue];

    EMSDeepLinkInternal *deepLinkInternal = [[EMSDeepLinkInternal alloc] initWithRequestManager:self.requestManager
                                                                                 requestFactory:self.requestFactory];
    EMSInstanceRouter *deepLinkRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:deepLinkInternal
                                                                           loggingInstance:deepLinkInternal
                                                                               routerLogic:^BOOL{
        return YES;
    }];

    [self.deepLinkDelegator proxyWithInstanceRouter:deepLinkRouter];

    EMSInAppInternal *inAppInternal = [[EMSInAppInternal alloc] initWithRequestManager:self.requestManager
                                                                        requestFactory:self.requestFactory
                                                                               meInApp:meInApp
                                                                     timestampProvider:timestampProvider
                                                                          uuidProvider:self.uuidProvider];

    _loggingPush = [EMSLoggingPushInternal new];
    EMSInstanceRouter *pushRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:[[EMSPushV3Internal alloc] initWithRequestFactory:self.requestFactory
                                                                                                                          requestManager:self.requestManager
                                                                                                                           actionFactory:actionFactory
                                                                                                                                 storage:self.storage
                                                                                                                           inAppInternal:inAppInternal
                                                                                                                          operationQueue:self.coreOperationQueue]
                                                                       loggingInstance:self.loggingPush
                                                                           routerLogic:self.mobileEngageRouterLogicBlock];
    [self.pushDelegator proxyWithInstanceRouter:pushRouter];

    _loggingGeofence = [EMSLoggingGeofenceInternal new];

    EMSGeofenceInternal *geofenceInternal = [[EMSGeofenceInternal alloc] initWithRequestFactory:self.requestFactory
                                                                                 requestManager:self.requestManager
                                                                                 responseMapper:[[EMSGeofenceResponseMapper alloc] init]
                                                                                locationManager:self.locationManager
                                                                                  actionFactory:actionFactory
                                                                                        storage:self.storage
                                                                                          queue:self.coreOperationQueue];

    EMSInstanceRouter *geofenceRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:geofenceInternal
                                                                           loggingInstance:self.loggingGeofence
                                                                               routerLogic:self.mobileEngageRouterLogicBlock];

    _loggingMessageInbox = [EMSLoggingInboxV3 new];
    EMSInstanceRouter *messageInboxRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:[[EMSInboxV3 alloc] initWithRequestFactory:self.requestFactory
                                                                                                                           requestManager:self.requestManager
                                                                                                                        inboxResultParser:[[EMSInboxResultParser alloc] init]]
                                                                               loggingInstance:self.loggingMessageInbox
                                                                                   routerLogic:^BOOL {
        return [MEExperimental isFeatureEnabled:[EMSInnerFeature mobileEngage]];
    }];

    [self.messageInboxDelegator proxyWithInstanceRouter:messageInboxRouter];

    EMSEmarsysRequestFactory *emarsysRequestFactory = [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:timestampProvider
                                                                                                     uuidProvider:self.uuidProvider
                                                                                                         endpoint:self.endpoint
                                                                                                   requestContext:self.requestContext];

    EMSConfigInternal *configInternal = [[EMSConfigInternal alloc] initWithRequestManager:self.requestManager
                                                                         meRequestContext:self.requestContext
                                                                        preRequestContext:self.predictRequestContext
                                                                            contactClient:self.contactClient
                                                                             pushInternal:self.push
                                                                               deviceInfo:deviceInfo
                                                                    emarsysRequestFactory:emarsysRequestFactory
                                                               remoteConfigResponseMapper:[[EMSRemoteConfigResponseMapper alloc] initWithRandomProvider:randomProvider
                                                                                                                                             deviceInfo:deviceInfo]
                                                                                 endpoint:self.endpoint
                                                                                   logger:self.logger
                                                                                   crypto:[[EMSCrypto alloc] init]
                                                                                    coreQueue:self.coreOperationQueue
                                                                                   waiter:[EMSDispatchWaiter new]
                                                                         deviceInfoClient:self.deviceInfoClient];

    EMSInstanceRouter *configRouter = [[EMSInstanceRouter alloc] initWithDefaultInstance:configInternal
                                                                         loggingInstance:configInternal
                                                                             routerLogic:^BOOL {
        return YES;
    }];

    [self.configDelegator proxyWithInstanceRouter:configRouter];

    [self.geofenceDelegator proxyWithInstanceRouter:geofenceRouter];

    _appStartBlockProvider = [[EMSAppStartBlockProvider alloc] initWithRequestManager:self.requestManager
                                                                       requestFactory:self.requestFactory
                                                                       requestContext:self.requestContext
                                                                     deviceInfoClient:self.deviceInfoClient
                                                                       configInternal:self.config
                                                                     geofenceInternal:(id) self.geofenceDelegator
                                                                       sdkStateLogger:[[EMSSdkStateLogger alloc] initWithEndpoint:self.endpoint
                                                                                                                 meRequestContext:self.requestContext
                                                                                                                           config:config
                                                                                                                          storage:self.storage]
                                                                               logger:self.logger
                                                                             dbHelper:self.dbHelper
                                                              completionBlockProvider:self.completionBlockProvider];

    [self.iam setInAppTracker:inAppInternal];
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

- (NSOperationQueue *)createQueueWithName:(NSString *)queueName
                         qualityOfService:(NSQualityOfService)qualityOfService {
    NSOperationQueue *operationQueue = [EMSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = 1;
    operationQueue.qualityOfService = qualityOfService;
    operationQueue.name = [NSString stringWithFormat:@"%@_%@", queueName, [self.uuidProvider provideUUIDString]];
    return operationQueue;
}

@end
