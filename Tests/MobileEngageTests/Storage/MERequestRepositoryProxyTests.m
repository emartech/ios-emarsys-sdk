//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "Kiwi.h"
#import "MEDisplayedIAMRepository.h"
#import "MEButtonClickRepository.h"
#import "EMSRequestModelRepository.h"
#import "MERequestRepositoryProxy.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSCompositeRequestModel.h"
#import "EMSQueryOldestRowSpecification.h"
#import "FakeRequestRepository.h"
#import "EMSFilterByTypeSpecification.h"
#import "EMSSchemaContract.h"
#import "EMSRequestModelMatcher.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo.h"
#import "EmarsysSDKVersion.h"
#import "MEInApp.h"
#import "NSDate+EMSCore.h"
#import "MERequestContext.h"
#import "EMSEndpoint.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestMEDB.db"]


SPEC_BEGIN(MERequestRepositoryProxyTests)

        __block MEDisplayedIAMRepository *displayedRepository;
        __block MEButtonClickRepository *buttonClickRepository;
        __block EMSRequestModelRepository *requestModelRepository;
        __block MERequestRepositoryProxy *compositeRequestModelRepository;
        __block EMSTimestampProvider *timestampProvider;
        __block EMSUUIDProvider *uuidProvider;
        __block EMSDeviceInfo *deviceInfo;
        __block MERequestContext *requestContext;
        __block NSString *applicationCode;
        __block NSNumber *contactFieldId;
        __block EMSEndpoint *mockEndpoint;

        registerMatchers(@"EMS");

        id (^customEventRequestModel)(NSString *eventName, NSDictionary *eventAttributes, MERequestContext *requestContext) = ^id(NSString *eventName, NSDictionary *eventAttributes, MERequestContext *requestContext) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                                @"type": @"custom",
                                @"name": eventName,
                                @"timestamp": [[timestampProvider provideTimestamp] numberValueInMillis]}];

                        if (eventAttributes) {
                            event[@"attributes"] = eventAttributes;
                        }

                        [builder setUrl:@"https://mobile-events.eservice.emarsys.net/v3/apps/testAppplicationCode/client/events"];
                        [builder setMethod:HTTPMethodPOST];
                        [builder setPayload:@{@"events": @[event]}];
                    }
                                  timestampProvider:timestampProvider
                                       uuidProvider:uuidProvider];
        };

        id (^normalRequestModel)(NSString *url, MERequestContext *requestContext) = ^id(NSString *url, MERequestContext *requestContext) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:url];
                        [builder setMethod:HTTPMethodGET];
                    }
                                  timestampProvider:timestampProvider
                                       uuidProvider:uuidProvider];
        };

        id (^createFakeRequestRepository)(NSArray *nextRequest, NSArray *allCustomEvents, NSArray *AllRequests, MEInApp *inApp, MERequestContext *requestContext) = ^id(NSArray *nextRequest, NSArray *allCustomEvents, NSArray *AllRequests, MEInApp *inApp, MERequestContext *requestContext) {
            EMSQueryOldestRowSpecification *selectFirstSpecification = [EMSQueryOldestRowSpecification new];
            EMSFilterByTypeSpecification *filterCustomEventsSpecification = [[EMSFilterByTypeSpecification alloc] initWitType:[NSString stringWithFormat:@"%%%@%%/events",
                                                                                                                                                         @"testEventServiceUrl"]
                                                                                                                       column:REQUEST_COLUMN_NAME_URL];

            EMSFilterByNothingSpecification *selectAllRequestsSpecification = [EMSFilterByNothingSpecification new];

            FakeRequestRepository *fakeRequestRepository = [FakeRequestRepository new];
            fakeRequestRepository.queryResponseMapping = @{
                    NSStringFromClass([selectFirstSpecification class]): nextRequest,
                    NSStringFromClass([filterCustomEventsSpecification class]): allCustomEvents,
                    NSStringFromClass([selectAllRequestsSpecification class]): AllRequests};

            compositeRequestModelRepository = [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:fakeRequestRepository
                                                                                         buttonClickRepository:buttonClickRepository
                                                                                        displayedIAMRepository:displayedRepository
                                                                                                         inApp:inApp
                                                                                                requestContext:requestContext
                                                                                                      endpoint:mockEndpoint];
            return compositeRequestModelRepository;
        };

        beforeEach(^{
            mockEndpoint = [EMSEndpoint mock];
            [mockEndpoint stub:@selector(eventServiceUrl) andReturn:@"testEventServiceUrl"];

            timestampProvider = [EMSTimestampProvider new];
            uuidProvider = [EMSUUIDProvider new];
            deviceInfo = [EMSDeviceInfo new];

            displayedRepository = [MEDisplayedIAMRepository nullMock];
            buttonClickRepository = [MEButtonClickRepository nullMock];
            requestModelRepository = [EMSRequestModelRepository mock];
            applicationCode = @"testApplicationCode";
            contactFieldId = @3;
            requestContext = [[MERequestContext alloc] initWithApplicationCode:applicationCode
                                                                contactFieldId:contactFieldId
                                                                  uuidProvider:uuidProvider
                                                             timestampProvider:timestampProvider
                                                                    deviceInfo:deviceInfo];
            compositeRequestModelRepository = [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:requestModelRepository
                                                                                         buttonClickRepository:buttonClickRepository
                                                                                        displayedIAMRepository:displayedRepository
                                                                                                         inApp:[MEInApp mock]
                                                                                                requestContext:requestContext
                                                                                                      endpoint:mockEndpoint];
        });

        afterEach(^{
        });

        describe(@"initWithRequestModelRepository:buttonClickRepository:displayedIAMRepository:inApp:requestContext:deviceInfo:", ^{

            it(@"should set inApp after init", ^{
                MEInApp *inApp = [MEInApp mock];
                MERequestRepositoryProxy *factory = [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[EMSRequestModelRepository mock]
                                                                                               buttonClickRepository:[MEButtonClickRepository mock]
                                                                                              displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                               inApp:inApp
                                                                                                      requestContext:[MERequestContext nullMock]
                                                                                                            endpoint:mockEndpoint];
                [[factory.inApp shouldNot] beNil];
            });

            it(@"should set requestContext after init", ^{
                MERequestRepositoryProxy *factory = [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[EMSRequestModelRepository mock]
                                                                                               buttonClickRepository:[MEButtonClickRepository mock]
                                                                                              displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                                               inApp:[MEInApp mock]
                                                                                                      requestContext:requestContext
                                                                                                            endpoint:mockEndpoint];
                [[factory.requestContext should] equal:requestContext];
            });

            it(@"should throw an exception when there is no inApp", ^{
                @try {
                    [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[EMSRequestModelRepository mock]
                                                               buttonClickRepository:[MEButtonClickRepository mock]
                                                              displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                               inApp:nil
                                                                      requestContext:[MERequestContext mock]
                                                                            endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when inApp is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: inApp"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no requestModelRepository", ^{
                @try {
                    [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:nil
                                                               buttonClickRepository:[MEButtonClickRepository mock]
                                                              displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                               inApp:[MEInApp mock]
                                                                      requestContext:[MERequestContext mock]
                                                                            endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when requestModelRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestModelRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no clickRepository", ^{
                @try {
                    [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[EMSRequestModelRepository mock]
                                                               buttonClickRepository:nil
                                                              displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                               inApp:[MEInApp mock]
                                                                      requestContext:[MERequestContext mock]
                                                                            endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when clickRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: buttonClickRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no displayedIAMRepository", ^{
                @try {
                    (void) [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[EMSRequestModelRepository mock]
                                                                      buttonClickRepository:[MEButtonClickRepository mock]
                                                                     displayedIAMRepository:nil
                                                                                      inApp:[MEInApp mock]
                                                                             requestContext:[MERequestContext mock]
                                                                                   endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when displayedIAMRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: displayedIAMRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no requestContext", ^{
                @try {
                    (void) [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[EMSRequestModelRepository mock]
                                                                      buttonClickRepository:[MEButtonClickRepository mock]
                                                                     displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                      inApp:[MEInApp mock]
                                                                             requestContext:nil
                                                                                   endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception when there is no endpoint", ^{
                @try {
                    (void) [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[EMSRequestModelRepository mock]
                                                                      buttonClickRepository:[MEButtonClickRepository mock]
                                                                     displayedIAMRepository:[MEDisplayedIAMRepository mock]
                                                                                      inApp:[MEInApp mock]
                                                                             requestContext:[MERequestContext mock]
                                                                                   endpoint:nil];
                    fail(@"Expected Exception when endpoint is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: endpoint"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"MERequestRepositoryProxy", ^{

            it(@"should add buttonClicks on the custom event requests", ^{
                NSArray<MEButtonClick *> *clicks = @[
                        [[MEButtonClick alloc] initWithCampaignId:@"campaignID"
                                                         buttonId:@"buttonID"
                                                        timestamp:[NSDate date]],
                        [[MEButtonClick alloc] initWithCampaignId:@"campaignID2"
                                                         buttonId:@"buttonID2"
                                                        timestamp:[NSDate date]]
                ];

                [[buttonClickRepository should] receive:@selector(query:) andReturn:clicks];

                EMSRequestModel *modelCustomEvent1 = customEventRequestModel(@"event1", nil, requestContext);

                createFakeRequestRepository(@[modelCustomEvent1], @[modelCustomEvent1], @[modelCustomEvent1], [MEInApp new], requestContext);

                NSArray<EMSRequestModel *> *result = [compositeRequestModelRepository query:[EMSFilterByNothingSpecification new]];
                [[[result[0] payload][@"clicks"] should] equal:@[
                        @{@"campaignId": [clicks[0] campaignId], @"buttonId": [clicks[0] buttonId], @"timestamp": [clicks[0] timestamp].stringValueInUTC},
                        @{@"campaignId": [clicks[1] campaignId], @"buttonId": [clicks[1] buttonId], @"timestamp": [clicks[1] timestamp].stringValueInUTC}
                ]];
            });

            it(@"should add viewedMessages on the custom event requests", ^{
                NSArray<MEDisplayedIAM *> *viewedMessages = @[
                        [[MEDisplayedIAM alloc] initWithCampaignId:@"123" timestamp:[NSDate date]],
                        [[MEDisplayedIAM alloc] initWithCampaignId:@"42" timestamp:[NSDate date]]
                ];

                [[displayedRepository should] receive:@selector(query:) andReturn:viewedMessages];

                EMSRequestModel *modelCustomEvent1 = customEventRequestModel(@"event1", nil, requestContext);

                createFakeRequestRepository(@[modelCustomEvent1], @[modelCustomEvent1], @[modelCustomEvent1], [MEInApp new], requestContext);

                NSArray<EMSRequestModel *> *result = [compositeRequestModelRepository query:[EMSFilterByNothingSpecification new]];
                [[[result[0] payload][@"viewedMessages"] should] equal:@[
                        @{@"campaignId": [viewedMessages[0] campaignId], @"timestamp": [viewedMessages[0] timestamp].stringValueInUTC},
                        @{@"campaignId": [viewedMessages[1] campaignId], @"timestamp": [viewedMessages[1] timestamp].stringValueInUTC}
                ]];
            });

            it(@"should add the element to the requestModelRepository", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                            [builder setUrl:@"https://www.url.com"];
                            [builder setMethod:HTTPMethodGET];
                        }
                                                        timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];
                [[requestModelRepository should] receive:@selector(add:) withArguments:model];

                [compositeRequestModelRepository add:model];
            });

            it(@"should remove the element from the requestModelRepository", ^{
                id spec = [KWMock mockForProtocol:@protocol(EMSSQLSpecificationProtocol)];

                [[requestModelRepository should] receive:@selector(remove:) withArguments:spec];
                [compositeRequestModelRepository remove:spec];
            });

            it(@"should query normal RequestModels from RequestRepository", ^{
                EMSFilterByNothingSpecification *specification = [EMSFilterByNothingSpecification new];

                NSArray *const requests = @[[EMSRequestModel nullMock], [EMSRequestModel nullMock], [EMSRequestModel nullMock]];
                [[requestModelRepository should] receive:@selector(query:)
                                               andReturn:requests
                                           withArguments:specification];

                NSArray<EMSRequestModel *> *result = [compositeRequestModelRepository query:specification];
                [[result should] equal:requests];
            });

            it(@"should return empty array if no elements were found", ^{
                EMSFilterByNothingSpecification *specification = [EMSFilterByNothingSpecification new];

                NSArray *const requests = @[];
                [[requestModelRepository should] receive:@selector(query:)
                                               andReturn:requests
                                           withArguments:specification];

                NSArray<EMSRequestModel *> *result = [compositeRequestModelRepository query:specification];
                [[result should] equal:requests];
            });

            it(@"should query composite RequestModel from RequestRepository when select first", ^{
                EMSRequestModel *modelCustomEvent1 = customEventRequestModel(@"event1", nil, requestContext);
                EMSRequestModel *model1 = normalRequestModel(@"https://www.google.com", requestContext);
                EMSRequestModel *modelCustomEvent2 = customEventRequestModel(@"event2", @{@"key1": @"value1", @"key2": @"value2"}, requestContext);
                EMSRequestModel *model2 = normalRequestModel(@"https://www.google.com", requestContext);
                EMSRequestModel *modelCustomEvent3 = customEventRequestModel(@"event3", @{@"star": @"wars"}, requestContext);

                EMSCompositeRequestModel *compositeModel = [EMSCompositeRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                            [builder setUrl:@"https://mobile-events.eservice.emarsys.net/v3/apps/testAppplicationCode/client/events"];
                            [builder setMethod:HTTPMethodPOST];
                            [builder setPayload:@{
                                    @"hardware_id": deviceInfo.hardwareId,
                                    @"viewedMessages": @[],
                                    @"clicks": @[],
                                    @"events": @[
                                            [modelCustomEvent1.payload[@"events"] firstObject],
                                            [modelCustomEvent2.payload[@"events"] firstObject],
                                            [modelCustomEvent3.payload[@"events"] firstObject]
                                    ],
                                    @"language": deviceInfo.languageCode,
                                    @"ems_sdk": EMARSYS_SDK_VERSION,
                                    @"application_version": deviceInfo.applicationVersion
                            }];
                        }
                                                                                   timestampProvider:requestContext.timestampProvider
                                                                                        uuidProvider:requestContext.uuidProvider];
                compositeModel.originalRequests = @[modelCustomEvent1, modelCustomEvent2, modelCustomEvent3];

                createFakeRequestRepository(@[modelCustomEvent1], @[modelCustomEvent1, modelCustomEvent2, modelCustomEvent3], @[modelCustomEvent1, model1, modelCustomEvent2, model2, modelCustomEvent3], [MEInApp new], requestContext);

                NSArray<EMSRequestModel *> *result = [compositeRequestModelRepository query:[EMSQueryOldestRowSpecification new]];
                [[theValue([result count]) should] equal:theValue(1)];
                [[[result firstObject] should] beSimilarWithRequest:compositeModel];
            });

            it(@"should query composite RequestModels from RequestRepository when select all", ^{
                EMSRequestModel *model1 = normalRequestModel(@"https://www.google.com", requestContext);
                EMSRequestModel *modelCustomEvent1 = customEventRequestModel(@"event1", nil, requestContext);
                EMSRequestModel *modelCustomEvent2 = customEventRequestModel(@"event2", @{@"key1": @"value1", @"key2": @"value2"}, requestContext);
                EMSRequestModel *model2 = normalRequestModel(@"https://mobile-events.eservice.emarsys.net/v3/apps/testAppplicationCode/client/events456", requestContext);
                EMSRequestModel *modelCustomEvent3 = customEventRequestModel(@"event3", @{@"star": @"wars"}, requestContext);

                EMSCompositeRequestModel *compositeModel = [EMSCompositeRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                            [builder setUrl:@"https://mobile-events.eservice.emarsys.net/v3/apps/testAppplicationCode/client/events"];
                            [builder setMethod:HTTPMethodPOST];
                            [builder setPayload:@{
                                    @"hardware_id": deviceInfo.hardwareId,
                                    @"viewedMessages": @[],
                                    @"clicks": @[],
                                    @"events": @[
                                            [modelCustomEvent1.payload[@"events"] firstObject],
                                            [modelCustomEvent2.payload[@"events"] firstObject],
                                            [modelCustomEvent3.payload[@"events"] firstObject]
                                    ],
                                    @"language": deviceInfo.languageCode,
                                    @"ems_sdk": EMARSYS_SDK_VERSION,
                                    @"application_version": deviceInfo.applicationVersion
                            }];
                        }
                                                                                   timestampProvider:requestContext.timestampProvider
                                                                                        uuidProvider:requestContext.uuidProvider];
                compositeModel.originalRequests = @[modelCustomEvent1, modelCustomEvent2, modelCustomEvent3];


                createFakeRequestRepository(@[modelCustomEvent1], @[modelCustomEvent1, modelCustomEvent2, modelCustomEvent3], @[model1, modelCustomEvent1, modelCustomEvent2, model2, modelCustomEvent3], [MEInApp new], requestContext);

                NSArray<EMSRequestModel *> *result = [compositeRequestModelRepository query:[EMSFilterByNothingSpecification new]];
                [[theValue([result count]) should] equal:theValue(3)];
                [[result[0] should] beSimilarWithRequest:model1];
                [[result[1] should] beSimilarWithRequest:compositeModel];
                [[result[2] should] beSimilarWithRequest:model2];
            });

            it(@"should return NO if request requestModelRepository is NOT empty", ^{
                [[requestModelRepository should] receive:@selector(isEmpty) andReturn:theValue(NO)];
                [[theValue([compositeRequestModelRepository isEmpty]) should] beNo];
            });

            it(@"should return YES if request requestModelRepository is empty", ^{
                [[requestModelRepository should] receive:@selector(isEmpty) andReturn:theValue(YES)];
                [[theValue([compositeRequestModelRepository isEmpty]) should] beYes];
            });

            it(@"should add dnd on the custom event requests with 'YES' value when inApp is paused", ^{
                EMSRequestModel *modelCustomEvent1 = customEventRequestModel(@"event1", nil, requestContext);

                MEInApp *meInApp = [MEInApp new];
                [meInApp pause];

                createFakeRequestRepository(@[modelCustomEvent1], @[modelCustomEvent1], @[modelCustomEvent1], meInApp, requestContext);
                NSArray<EMSRequestModel *> *result = [compositeRequestModelRepository query:[EMSFilterByNothingSpecification new]];
                [[[result[0] payload][@"dnd"] should] equal:@(YES)];
            });

            it(@"should not add dnd on the custom event requests when inApp is resumed", ^{
                EMSRequestModel *modelCustomEvent1 = customEventRequestModel(@"event1", nil, requestContext);

                MEInApp *meInApp = [MEInApp new];

                createFakeRequestRepository(@[modelCustomEvent1], @[modelCustomEvent1], @[modelCustomEvent1], meInApp, requestContext);
                NSArray<EMSRequestModel *> *result = [compositeRequestModelRepository query:[EMSFilterByNothingSpecification new]];
                [[theValue([[[result[0] payload] allKeys] containsObject:@"dnd"]) should] beNo];
            });

        });


SPEC_END
