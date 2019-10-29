//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSNotificationService.h"
#import "EMSNotificationService+Attachment.h"
#import "EMSNotificationService+Actions.h"
#import "EMSNotificationService+PushToInApp.h"
#import "EMSWaiter.h"

SPEC_BEGIN(EMSNotificationServiceTests)


        describe(@"createAttachmentForContent:withDownloader:completionHandler:", ^{

            __block MEDownloader *downloader;

            beforeEach(^{
                downloader = [MEDownloader new];
            });

            void (^waitUntilNextResult)(EMSNotificationService *service, UNMutableNotificationContent *content) = ^(EMSNotificationService *service, UNMutableNotificationContent *content) {
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [service createAttachmentForContent:content
                                     withDownloader:downloader
                                  completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                      [exp fulfill];
                                  }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];
            };

            it(@"should return with nil when content doesn't contain image url", ^{
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{};

                EMSNotificationService *service = [[EMSNotificationService alloc] init];

                __block NSArray<UNNotificationAttachment *> *result = [NSArray array];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [service createAttachmentForContent:content
                                     withDownloader:downloader
                                  completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                      result = attachments;
                                      [exp fulfill];
                                  }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[result should] beNil];
            });

            it(@"should not crash when content doesn't contain image url and completionHandler is nil", ^{
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{};

                EMSNotificationService *service = [[EMSNotificationService alloc] init];

                [service createAttachmentForContent:content
                                     withDownloader:downloader
                                  completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return with array of attachments when content contains image url", ^{
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"image_url": @"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png"};

                EMSNotificationService *service = [[EMSNotificationService alloc] init];

                __block NSArray<UNNotificationAttachment *> *result = [NSArray array];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [service createAttachmentForContent:content
                                     withDownloader:downloader
                                  completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                      result = attachments;
                                      [exp fulfill];
                                  }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[result shouldNot] beNil];
                [[theValue([[[result firstObject] identifier] hasSuffix:@".png"]) should] beYes];
            });

            it(@"should not crash when content contains image url and completionHandler is nil", ^{
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"image_url": @"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png"};

                EMSNotificationService *service = [[EMSNotificationService alloc] init];

                [service createAttachmentForContent:content
                                     withDownloader:downloader
                                  completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should throw exception when downloader is nil", ^{
                @try {
                    [[[EMSNotificationService alloc] init] createAttachmentForContent:[UNMutableNotificationContent mock]
                                                                       withDownloader:nil
                                                                    completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                                                    }];
                    fail(@"Expected exception when downloader is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"createCategoryForContent:completionHandler:", ^{

            UNNotificationCategory *(^waitUntilNextResult)(EMSNotificationService *service, UNMutableNotificationContent *content) = (UNNotificationCategory *(^)(EMSNotificationService *, UNMutableNotificationContent *)) (UNNotificationCategory *) ^(EMSNotificationService *service, UNMutableNotificationContent *content) {
                __block UNNotificationCategory *result = [UNNotificationCategory new];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [service createCategoryForContent:content
                                completionHandler:^(UNNotificationCategory *category) {
                                    result = category;
                                    [exp fulfill];
                                }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];

                return result;
            };

            it(@"should return with nil when there is no actions in the content", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{}};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should not crash when there is no actions in the content and completionHandler is nil", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{}};

                [service createCategoryForContent:content
                                completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return with category that contains MEAppEvent, when the content contains MEAppEvent action", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID1",
                                        @"title": @"buttonTitle",
                                        @"type": @"MEAppEvent",
                                        @"name": @"nameOfTheEvent"
                                }
                        ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                UNNotificationAction *action = [[result actions] firstObject];
                [[[action identifier] should] equal:@"UUID1"];
                [[[action title] should] equal:@"buttonTitle"];
            });

            it(@"should return with category that contains Dismiss, when the content contains Dismiss type action", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID1",
                                        @"title": @"Dismiss",
                                        @"type": @"Dismiss",
                                }
                        ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                UNNotificationAction *action = [[result actions] firstObject];
                [[[action identifier] should] equal:@"UUID1"];
                [[[action title] should] equal:@"Dismiss"];
            });

            it(@"should not crash when category that contains MEAppEvent, when the content contains MEAppEvent action but completionHandler is nil", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID1",
                                        @"title": @"buttonTitle",
                                        @"type": @"MEAppEvent",
                                        @"name": @"nameOfTheEvent"
                                }
                        ]
                }};

                [service createCategoryForContent:content
                                completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return with nil when the content contains MEAppEvent action type but there are missing parameters", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID1",
                                        @"title": @"buttonTitle",
                                        @"type": @"MEAppEvent"
                                }
                        ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should not crash when when the content contains Dismiss action type but there are missing parameters and completionHandler is nil", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID1",
                                        @"type": @"Dismiss"
                                }
                        ]
                }};

                [service createCategoryForContent:content
                                completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should not crash when when the content contains MEAppEvent action type but there are missing parameters and completionHandler is nil", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID1",
                                        @"title": @"buttonTitle",
                                        @"type": @"MEAppEvent"
                                }
                        ]
                }};

                [service createCategoryForContent:content
                                completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return with category that contains OpenExternalUrl, when the content contains OpenExternalUrl action", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID2",
                                        @"title": @"buttonTitleForOpenUrl",
                                        @"type": @"OpenExternalUrl",
                                        @"url": @"https://www.emarsys.com"
                                }
                        ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                UNNotificationAction *action = [[result actions] firstObject];
                [[[action identifier] should] equal:@"UUID2"];
                [[[action title] should] equal:@"buttonTitleForOpenUrl"];
            });

            it(@"should return with nil when the content contains OpenExternalUrl action type but there are missing parameters", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID2",
                                        @"title": @"buttonTitleForOpenUrl",
                                        @"type": @"OpenExternalUrl"
                                }
                        ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should return with category that contains MECustomEvent, when the content contains MECustomEvent action", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID3",
                                        @"title": @"buttonTitleForCustomEvent",
                                        @"type": @"MECustomEvent",
                                        @"name": @"CustomEventName"
                                }
                        ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                UNNotificationAction *action = [[result actions] firstObject];
                [[[action identifier] should] equal:@"UUID3"];
                [[[action title] should] equal:@"buttonTitleForCustomEvent"];
            });

            it(@"should return with nil when the content contains OpenExternalUrl action type but there are missing parameters", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID3",
                                        @"title": @"buttonTitleForCustomEvent",
                                        @"type": @"MECustomEvent"
                                }
                        ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });
        });

        describe(@"createUserInfoWithInAppForContent:completionHandler:", ^{

            __block MEDownloader *downloader;

            beforeEach(^{
                downloader = [MEDownloader new];
            });

            NSDictionary *(^waitUntilNextResult)(EMSNotificationService *service, UNMutableNotificationContent *content) = (NSDictionary *(^)(EMSNotificationService *, UNMutableNotificationContent *)) (UNNotificationCategory *) ^(EMSNotificationService *service, UNMutableNotificationContent *content) {
                __block NSDictionary *result = [NSDictionary dictionary];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [service createUserInfoWithInAppForContent:content
                                            withDownloader:downloader
                                         completionHandler:^(NSDictionary *userInfo) {
                                             result = userInfo;
                                             [exp fulfill];
                                         }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];
                return result;
            };

            it(@"should return nil when content doesnt contain inApp", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{}};

                NSDictionary *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should return nil when content contains inApp but inapp is not dictionary", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"inapp": @""
                }};

                NSDictionary *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should return nil when content contains inApp but campaign_id is missing", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"inapp": @{
                                @"url": @"https://www.emarysy.com"
                        }
                }};

                NSDictionary *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should return nil when content contains inApp but url is missing", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"inapp": @{
                                @"campaign_id": @"campaign_id"
                        }
                }};

                NSDictionary *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should not crash when content doesnt contains inapp or contains inapp but invalid", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{}};

                [service createUserInfoWithInAppForContent:content
                                            withDownloader:downloader
                                         completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return nil when content contains inapp and the url is emptyString", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"inapp": @{
                                @"url": @"",
                                @"campaign_id": @"campaign_id"
                        }
                }};

                NSDictionary *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should not crash, when content contains inapp and the url is emptyString and completionHandler is nil", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"inapp": @{
                                @"url": @"",
                                @"campaign_id": @"campaign_id"
                        }
                }};

                [service createUserInfoWithInAppForContent:content
                                            withDownloader:downloader
                                         completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return userInfo extended with inAppData when everything is correct", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"inapp": @{
                        @"url": @"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png",
                                @"campaign_id": @"campaign_id"
                        }
                }};

                NSDictionary *result = waitUntilNextResult(service, content);

                [[result[@"ems"][@"inapp"][@"inAppData"] shouldNot] beNil];
            });

            it(@"should not crash when everything is correct but completionHandler is nil", ^{
                EMSNotificationService *service = [[EMSNotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                        @"inapp": @{
                        @"url": @"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png",
                                @"campaign_id": @"campaign_id"
                        }
                }};

                [service createUserInfoWithInAppForContent:content
                                            withDownloader:downloader
                                         completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should throw exception when downloader is nil", ^{
                @try {
                    [[[EMSNotificationService alloc] init] createUserInfoWithInAppForContent:[UNMutableNotificationContent mock]
                                                                              withDownloader:nil
                                                                           completionHandler:^(NSDictionary *userInfo) {
                                                                           }];
                    fail(@"Expected exception when downloader is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"didReceiveNotificationRequest:withContentHandler:", ^{

            UNNotificationRequest *(^requestWithUserInfo)(NSDictionary *userInfo) = ^UNNotificationRequest *(NSDictionary *userInfo) {
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = userInfo;
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                      content:content
                                                                                      trigger:nil];
                return request;
            };

            UNNotificationContent *(^waitForResult)(UNNotificationRequest *request) = ^UNNotificationContent *(UNNotificationRequest *request) {
                EMSNotificationService *service = [[EMSNotificationService alloc] init];

                __block UNNotificationContent *result;
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                [service didReceiveNotificationRequest:request
                                    withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                        result = contentToDeliver;
                                        [exp fulfill];
                                    }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:30];
                return result;
            };

            it(@"should contains categoryIdentifier in content when userInfo contain correct action items", ^{
                UNNotificationRequest *request = requestWithUserInfo(@{@"ems": @{
                        @"actions": @[
                                @{
                                        @"id": @"UUID1",
                                        @"title": @"buttonTitle",
                                        @"type": @"MEAppEvent",
                                        @"name": @"nameOfTheEvent"
                                }
                        ]
                }});

                UNNotificationContent *result = waitForResult(request);

                [[result.categoryIdentifier shouldNot] beNil];
            });

            it(@"should contains inAppData in userInfo when userInfo contains correct pushToInapp data", ^{
                UNNotificationRequest *request = requestWithUserInfo(@{@"ems": @{
                        @"inapp": @{
                        @"url": @"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png",
                                @"campaign_id": @"campaign_id"
                        }
                }});

                UNNotificationContent *result = waitForResult(request);

                [[result.userInfo[@"ems"][@"inapp"][@"inAppData"] shouldNot] beNil];
            });

            it(@"should contains attachment in content when userInfo contains correct image_url", ^{
                UNNotificationRequest *request = requestWithUserInfo(@{@"image_url": @"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png"});

                UNNotificationContent *result = waitForResult(request);

                [[result.attachments.firstObject shouldNot] beNil];
            });
        });

SPEC_END
