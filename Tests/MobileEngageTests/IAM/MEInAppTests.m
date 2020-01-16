#import "Kiwi.h"
#import "MEInApp.h"

#import "FakeInAppHandler.h"
#import "EMSTimestampProvider.h"
#import "FakeTimeStampProvider.h"
#import "EMSWaiter.h"
#import "EMSWindowProvider.h"
#import "EMSMainWindowProvider.h"
#import "EMSIAMViewControllerProvider.h"
#import "MEDisplayedIAMRepository.h"
#import "FakeInAppTracker.h"
#import "EMSViewControllerProvider.h"
#import "EMSCompletionBlockProvider.h"
#import "EMSSceneProvider.h"

SPEC_BEGIN(MEInAppTests)

        __block MEInApp *inApp;
        __block FakeInAppTracker *inAppTracker;
        __block XCTestExpectation *displayExpectation;
        __block XCTestExpectation *clickExpectation;
        __block FakeTimeStampProvider *timestampProvider;
        __block EMSWindowProvider *windowProvider;
        __block NSDate *firstTimestamp;
        __block NSDate *secondTimestamp;
        __block NSDate *thirdTimestamp;
        __block MEDisplayedIAMRepository *displayedIAMRepository;
        __block NSOperationQueue *operationQueue;

        beforeEach(^{
            NSDate *renderEndTime = [NSDate dateWithTimeIntervalSince1970:103];
            EMSTimestampProvider *mockTimeStampProvider = [EMSTimestampProvider mock];
            [mockTimeStampProvider stub:@selector(provideTimestamp) andReturn:renderEndTime];

            displayExpectation = [[XCTestExpectation alloc] initWithDescription:@"displayExpectation"];
            clickExpectation = [[XCTestExpectation alloc] initWithDescription:@"clickExpectation"];
            inAppTracker = [[FakeInAppTracker alloc] initWithDisplayExpectation:displayExpectation
                                                               clickExpectation:clickExpectation];

            firstTimestamp = [NSDate dateWithTimeIntervalSince1970:103];
            secondTimestamp = [firstTimestamp dateByAddingTimeInterval:6];
            thirdTimestamp = [firstTimestamp dateByAddingTimeInterval:12];
            timestampProvider = [[FakeTimeStampProvider alloc] initWithTimestamps:@[firstTimestamp, secondTimestamp, thirdTimestamp]];
            windowProvider = [EMSWindowProvider nullMock];
            EMSViewControllerProvider *viewControllerProvider = [EMSViewControllerProvider mock];
            [viewControllerProvider stub:@selector(provideViewController)
                               andReturn:[[[EMSViewControllerProvider alloc] init] provideViewController]];
            [windowProvider stub:@selector(provideWindow)
                       andReturn:[[[EMSWindowProvider alloc] initWithViewControllerProvider:viewControllerProvider
                                                                              sceneProvider:[[EMSSceneProvider alloc] initWithApplication:[UIApplication sharedApplication]]] provideWindow]];
            displayedIAMRepository = [MEDisplayedIAMRepository nullMock];

            operationQueue = [NSOperationQueue new];
            operationQueue.name = @"operationQueueForTest";

            inApp = [[MEInApp alloc] initWithWindowProvider:windowProvider
                                         mainWindowProvider:[EMSMainWindowProvider nullMock]
                                          timestampProvider:timestampProvider
                                    completionBlockProvider:[[EMSCompletionBlockProvider alloc] initWithOperationQueue:operationQueue]
                                     displayedIamRepository:displayedIAMRepository
                                      buttonClickRepository:[MEDisplayedIAMRepository mock]];
            [inApp setInAppTracker:inAppTracker];
        });


        describe(@"initWithWindowProvider:mainWindowProvider:iamViewControllerProvider:iamViewControllerProvider:timestampProvider:logRepository:displayedIamRepository:inAppTracker:", ^{
            it(@"should throw exception when windowProvider is nil", ^{
                @try {
                    [[MEInApp alloc] initWithWindowProvider:nil
                                         mainWindowProvider:[EMSMainWindowProvider mock]
                                          timestampProvider:[EMSTimestampProvider mock]
                                    completionBlockProvider:[EMSCompletionBlockProvider mock]
                                     displayedIamRepository:[MEDisplayedIAMRepository mock]
                                      buttonClickRepository:[MEDisplayedIAMRepository mock]];
                    fail(@"Expected Exception when windowProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: windowProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when mainWindowProvider is nil", ^{
                @try {
                    [[MEInApp alloc] initWithWindowProvider:[EMSWindowProvider mock]
                                         mainWindowProvider:nil
                                          timestampProvider:[EMSTimestampProvider mock]
                                    completionBlockProvider:[EMSCompletionBlockProvider mock]
                                     displayedIamRepository:[MEDisplayedIAMRepository mock]
                                      buttonClickRepository:[MEDisplayedIAMRepository mock]];
                    fail(@"Expected Exception when mainWindowProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: mainWindowProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when timestampProvider is nil", ^{
                @try {
                    [[MEInApp alloc] initWithWindowProvider:[EMSWindowProvider mock]
                                         mainWindowProvider:[EMSMainWindowProvider mock]
                                          timestampProvider:nil
                                    completionBlockProvider:[EMSCompletionBlockProvider mock]
                                     displayedIamRepository:[MEDisplayedIAMRepository mock]
                                      buttonClickRepository:[MEDisplayedIAMRepository mock]];
                    fail(@"Expected Exception when timestampProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: timestampProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when completionBlockProvider is nil", ^{
                @try {
                    [[MEInApp alloc] initWithWindowProvider:[EMSWindowProvider mock]
                                         mainWindowProvider:[EMSMainWindowProvider mock]
                                          timestampProvider:[EMSCompletionBlockProvider mock]
                                    completionBlockProvider:nil
                                     displayedIamRepository:[MEDisplayedIAMRepository mock]
                                      buttonClickRepository:[MEDisplayedIAMRepository mock]];
                    fail(@"Expected Exception when completionBlockProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: completionBlockProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when displayedIamRepository is nil", ^{
                @try {
                    [[MEInApp alloc] initWithWindowProvider:[EMSWindowProvider mock]
                                         mainWindowProvider:[EMSMainWindowProvider mock]
                                          timestampProvider:[EMSTimestampProvider mock]
                                    completionBlockProvider:[EMSCompletionBlockProvider mock]
                                     displayedIamRepository:nil
                                      buttonClickRepository:[MEDisplayedIAMRepository mock]];
                    fail(@"Expected Exception when displayedIamRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: displayedIamRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when buttonClickRepository is nil", ^{
                @try {
                    [[MEInApp alloc] initWithWindowProvider:[EMSWindowProvider mock]
                                         mainWindowProvider:[EMSMainWindowProvider mock]
                                          timestampProvider:[EMSTimestampProvider mock]
                                    completionBlockProvider:[EMSCompletionBlockProvider mock]
                                     displayedIamRepository:[MEDisplayedIAMRepository mock]
                                      buttonClickRepository:nil];
                    fail(@"Expected Exception when buttonClickRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: buttonClickRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"showMessage:completionHandler:", ^{

            it(@"it should set currentInAppMessage", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"testIdForCurrentCampaignId", @"html": @"<html></html>"}}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                MEInAppMessage *message = [[MEInAppMessage alloc] initWithResponse:response];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [inApp showMessage:message
                 completionHandler:^{
                     [exp fulfill];
                 }];
                [EMSWaiter waitForExpectations:@[exp] timeout:10];
                [[[((id <MEIAMProtocol>) inApp) currentInAppMessage] should] equal:message];
            });

            it(@"should call trackInAppDisplay: on inAppTracker", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"testIdForInAppTracker", @"html": @"<html></html>"}}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                MEInAppMessage *message = [[MEInAppMessage alloc] initWithResponse:response];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [inApp showMessage:message
                 completionHandler:^{
                     [exp fulfill];
                 }];

                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[exp, displayExpectation]
                                                                      timeout:10
                                                                 enforceOrder:YES];

                [[theValue(waiterResult) should] equal:theValue(XCTWaiterResultCompleted)];
                [[inAppTracker.inAppMessage should] equal:message];
            });

            it(@"should call add on displayedInAppRepository", ^{
                [[displayedIAMRepository should] receive:@selector(add:)
                                           withArguments:[[MEDisplayedIAM alloc] initWithCampaignId:@"testIdForInAppTracker"
                                                                                          timestamp:thirdTimestamp]];

                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"testIdForInAppTracker", @"html": @"<html></html>"}}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [inApp showMessage:[[MEInAppMessage alloc] initWithResponse:response]
                 completionHandler:^{
                     [exp fulfill];
                 }];

                [EMSWaiter waitForExpectations:@[exp, displayExpectation]
                                       timeout:10];

                [[inAppTracker.displayOperationQueue should] equal:operationQueue];
            });

            it(@"should use windowProvider to create iamWindow", ^{
                [[windowProvider should] receive:@selector(provideWindow)];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [inApp showMessage:[[MEInAppMessage alloc] initWithCampaignId:@"testCampaignId"
                                                                          sid:nil
                                                                          url:nil
                                                                         html:@"<html></html>"
                                                            responseTimestamp:[NSDate date]]
                 completionHandler:^{
                     [exp fulfill];
                 }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:10];
            });

        });

        describe(@"eventHandler", ^{
            it(@"should pass the eventName and payload to the given eventHandler's handleEvent:payload: method", ^{
                NSString *expectedName = @"nameOfTheEvent";
                NSDictionary <NSString *, NSObject *> *expectedPayload = @{
                    @"payloadKey1": @{
                        @"payloadKey2": @"payloadValue"
                    }
                };

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
                __block NSString *returnedEventName;
                __block NSDictionary<NSString *, NSObject *> *returnedPayload;

                FakeInAppHandler *inAppHandler = [[FakeInAppHandler alloc] initWithHandlerBlock:^(NSString *eventName, NSDictionary<NSString *, NSObject *> *payload) {
                    returnedEventName = eventName;
                    returnedPayload = payload;
                    [expectation fulfill];
                }];
                [inApp setEventHandler:inAppHandler];

                NSString *message = @"<!DOCTYPE html>\n"
                                    "<html lang=\"en\">\n"
                                    "  <head>\n"
                                    "    <script>\n"
                                    "      window.onload = function() {\n"
                                    "        window.webkit.messageHandlers.triggerAppEvent.postMessage({id: '1', name: 'nameOfTheEvent', payload:{payloadKey1:{payloadKey2: 'payloadValue'}}});\n"
                                    "      };\n"
                                    "    </script>\n"
                                    "  </head>\n"
                                    "  <body style=\"background: transparent;\">\n"
                                    "  </body>\n"
                                    "</html>";
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"campaignId", @"html": message}}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                [inApp showMessage:[[MEInAppMessage alloc] initWithResponse:response]
                 completionHandler:^{
                 }];

                [XCTWaiter waitForExpectations:@[expectation] timeout:2];

                [[returnedEventName should] equal:expectedName];
                [[returnedPayload should] equal:expectedPayload];
            });

            it(@"should not try to display inapp in case if there is already one being displayed", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"campaignId", @"html": @"<html></html>"}}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                XCTestExpectation *fulfilledExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForFulfill"];
                XCTestExpectation *timeoutExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForTimeout"];
                [inApp showMessage:[[MEInAppMessage alloc] initWithResponse:response]
                 completionHandler:^{
                     [fulfilledExpectation fulfill];
                     [inApp showMessage:[[MEInAppMessage alloc] initWithResponse:response]
                      completionHandler:^{
                          [timeoutExpectation fulfill];
                      }];
                 }];
                [EMSWaiter waitForExpectations:@[fulfilledExpectation]];
                [EMSWaiter waitForTimeout:@[timeoutExpectation]
                                  timeout:5];
            });

        });

        describe(@"campaignId", ^{
            it(@"should not update currentInAppMessage when trying to show another inAppMessage", ^{
                NSData *body1 = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"campaignId1", @"html": @"<html></html>"}}
                                                                options:0
                                                                  error:nil];
                NSData *body2 = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"campaignId2", @"html": @"<html></html>"}}
                                                                options:0
                                                                  error:nil];
                EMSResponseModel *response1 = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                   headers:@{}
                                                                                      body:body1
                                                                              requestModel:[EMSRequestModel nullMock]
                                                                                 timestamp:[NSDate date]];
                EMSResponseModel *response2 = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                   headers:@{}
                                                                                      body:body2
                                                                              requestModel:[EMSRequestModel nullMock]
                                                                                 timestamp:[NSDate date]];
                MEInAppMessage *message = [[MEInAppMessage alloc] initWithResponse:response1];

                XCTestExpectation *fulfilledExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForFulfill"];
                [inApp showMessage:message
                 completionHandler:^{
                     [inApp showMessage:[[MEInAppMessage alloc] initWithResponse:response2]
                      completionHandler:^{
                      }];
                     [fulfilledExpectation fulfill];
                 }];
                [EMSWaiter waitForExpectations:@[fulfilledExpectation]];

                [[inApp.currentInAppMessage should] equal:message];
            });
        });

        describe(@"closeInAppMessageWithCompletionBlock:", ^{

            it(@"should close the inapp message", ^{
                UIViewController *rootViewControllerMock = [UIViewController nullMock];
                [[rootViewControllerMock should] receive:@selector(dismissViewControllerAnimated:completion:)];
                KWCaptureSpy *spy = [rootViewControllerMock captureArgument:@selector(dismissViewControllerAnimated:completion:)
                                                                    atIndex:1];

                UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                window.rootViewController = rootViewControllerMock;

                inApp.iamWindow = window;

                [((id <MEIAMProtocol>) inApp) closeInAppMessageWithCompletionBlock:nil];

                void (^completionBlock)(void) = spy.argument;
                completionBlock();
                [[inApp.iamWindow should] beNil];
            });

        });

SPEC_END
