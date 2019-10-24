#import "Kiwi.h"
#import "MEIAMButtonClicked.h"
#import "EMSWaiter.h"
#import "MEInAppMessage.h"

SPEC_BEGIN(MEIAMButtonClickedTests)

        __block MEInAppMessage *inAppMessage;
        __block MEButtonClickRepository *repositoryMock;
        __block id inAppTrackerMock;
        __block MEIAMButtonClicked *meiamButtonClicked;

        beforeEach(^{
            inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:@"123"
                                                                  sid:@"testSid"
                                                                  url:@"https://www.test.com"
                                                                 html:@"</HTML>"
                                                    responseTimestamp:[NSDate date]];
            repositoryMock = [MEButtonClickRepository mock];
            inAppTrackerMock = [KWMock nullMockForProtocol:@protocol(MEInAppTrackingProtocol)];
            meiamButtonClicked = [[MEIAMButtonClicked alloc] initWithInAppMessage:inAppMessage
                                                                       repository:repositoryMock
                                                                     inAppTracker:inAppTrackerMock];
        });

        describe(@"commandName", ^{

            it(@"should return 'buttonClicked'", ^{
                [[[MEIAMButtonClicked commandName] should] equal:@"buttonClicked"];
            });

        });

        describe(@"handleMessage:resultBlock:", ^{

            it(@"should not accept missing buttonId", ^{
                NSDictionary *dictionary = @{
                    @"id": @"messageId"
                };
                [[repositoryMock shouldNot] receive:@selector(add:)];

                [meiamButtonClicked handleMessage:dictionary
                                      resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                      }];
            });

            it(@"should not accept buttonId with invalid type", ^{
                NSDictionary *dictionary = @{
                    @"id": @"messageId",
                    @"buttonId": @{}
                };
                [[repositoryMock shouldNot] receive:@selector(add:)];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;
                [meiamButtonClicked handleMessage:dictionary
                                      resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                          returnedResult = result;
                                          [exp fulfill];
                                      }];
                [EMSWaiter waitForExpectations:@[exp] timeout:3];
                [[returnedResult[@"success"] should] beFalse];
            });

            it(@"should call track on trackInAppClick:buttonId:", ^{
                NSString *buttonId = @"789";

                NSDictionary *dictionary = @{
                    @"buttonId": buttonId,
                    @"id": @"messageId"
                };
                [[repositoryMock should] receive:@selector(add:)];
                [[inAppTrackerMock should] receive:@selector(trackInAppClick:buttonId:)
                                     withArguments:inAppMessage,
                                                   buttonId];

                [meiamButtonClicked handleMessage:dictionary
                                      resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {

                                      }];
            });

            it(@"should call add on repositoryMock", ^{
                NSString *buttonId = @"789";

                NSDictionary *dictionary = @{
                    @"buttonId": buttonId,
                    @"id": @"messageId"
                };
                KWCaptureSpy *buttonClickSpy = [repositoryMock captureArgument:@selector(add:)
                                                                       atIndex:0];

                NSDate *before = [NSDate date];
                [meiamButtonClicked handleMessage:dictionary
                                      resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {

                                      }];
                NSDate *after = [NSDate date];

                MEButtonClick *buttonClick = buttonClickSpy.argument;

                [[buttonClick.buttonId should] equal:buttonId];
                [[buttonClick.campaignId should] equal:inAppMessage.campaignId];
                [[buttonClick.timestamp should] beBetween:before and:after];
            });

            it(@"should receive success in resultBlock", ^{
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;
                [[repositoryMock should] receive:@selector(add:)];

                [meiamButtonClicked handleMessage:@{@"buttonId": @"123", @"id": @"999"}
                                      resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                          returnedResult = result;
                                          [exp fulfill];
                                      }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[returnedResult should] equal:@{@"success": @YES, @"id": @"999"}];
            });

            it(@"should receive failure in resultBlock when there is no buttonId", ^{
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                __block NSDictionary<NSString *, NSObject *> *returnedResult;

                [meiamButtonClicked handleMessage:@{@"id": @"999"}
                                      resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                                          returnedResult = result;
                                          [exp fulfill];
                                      }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[returnedResult should] equal:@{@"success": @NO, @"id": @"999", @"errors": @[@"Missing buttonId!"]}];
            });

        });

SPEC_END



