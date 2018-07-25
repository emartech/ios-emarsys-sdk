//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MENotificationService.h"
#import "MENotificationService+Attachment.h"
#import "MENotificationService+Actions.h"
#import "MENotificationService+PushToInApp.h"

SPEC_BEGIN(MENotificationServiceTests)

        if (@available(iOS 10.0, *)) {

            describe(@"createAttachmentForContent:withDownloader:completionHandler:", ^{

                __block MEDownloader *downloader;

                beforeEach(^{
                    downloader = [MEDownloader new];
                });

                void (^waitUntilNextResult)(MENotificationService *service, UNMutableNotificationContent *content) = ^(MENotificationService *service, UNMutableNotificationContent *content) {
                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [service createAttachmentForContent:content
                                         withDownloader:downloader
                                      completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                          [exp fulfill];
                                      }];
                    [XCTWaiter waitForExpectations:@[exp]
                                           timeout:30];
                };

                it(@"should return with nil when content doesn't contain image url", ^{
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{};

                    MENotificationService *service = [[MENotificationService alloc] init];

                    __block NSArray<UNNotificationAttachment *> *result = [NSArray array];

                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [service createAttachmentForContent:content
                                         withDownloader:downloader
                                      completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                          result = attachments;
                                          [exp fulfill];
                                      }];
                    [XCTWaiter waitForExpectations:@[exp]
                                           timeout:30];

                    [[result should] beNil];
                });

                it(@"should not crash when content doesn't contain image url and completionHandler is nil", ^{
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{};

                    MENotificationService *service = [[MENotificationService alloc] init];

                    [service createAttachmentForContent:content
                                         withDownloader:downloader
                                      completionHandler:nil];

                    waitUntilNextResult(service, content);
                });

                it(@"should return with array of attachments when content contains image url", ^{
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"image_url": @"https://ems-denna.herokuapp.com/images/Emarsys.png"};

                    MENotificationService *service = [[MENotificationService alloc] init];

                    __block NSArray<UNNotificationAttachment *> *result = [NSArray array];

                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [service createAttachmentForContent:content
                                         withDownloader:downloader
                                      completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                          result = attachments;
                                          [exp fulfill];
                                      }];
                    [XCTWaiter waitForExpectations:@[exp]
                                           timeout:30];

                    [[result shouldNot] beNil];
                    [[[[result firstObject] identifier] should] equal:@"Emarsys.png"];
                });

                it(@"should not crash when content contains image url and completionHandler is nil", ^{
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"image_url": @"https://ems-denna.herokuapp.com/images/Emarsys.png"};

                    MENotificationService *service = [[MENotificationService alloc] init];

                    [service createAttachmentForContent:content
                                         withDownloader:downloader
                                      completionHandler:nil];

                    waitUntilNextResult(service, content);
                });

                it(@"should throw exception when downloader is nil", ^{
                    @try {
                        [[[MENotificationService alloc] init] createAttachmentForContent:[UNMutableNotificationContent mock]
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

                UNNotificationCategory *(^waitUntilNextResult)(MENotificationService *service, UNMutableNotificationContent *content) = (UNNotificationCategory *(^)(MENotificationService *, UNMutableNotificationContent *)) (UNNotificationCategory *) ^(MENotificationService *service, UNMutableNotificationContent *content) {
                    __block UNNotificationCategory *result = [UNNotificationCategory new];

                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [service createCategoryForContent:content
                                    completionHandler:^(UNNotificationCategory *category) {
                                        result = category;
                                        [exp fulfill];
                                    }];
                    [XCTWaiter waitForExpectations:@[exp]
                                           timeout:30];

                    return result;
                };

                it(@"should return with nil when there is no actions in the content", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"ems": @{}};

                    UNNotificationCategory *result = waitUntilNextResult(service, content);

                    [[result should] beNil];
                });

                it(@"should not crash when there is no actions in the content and completionHandler is nil", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"ems": @{}};

                    [service createCategoryForContent:content
                                    completionHandler:nil];

                    waitUntilNextResult(service, content);
                });

                it(@"should return with category that contains MEAppEvent, when the content contains MEAppEvent action", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
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

                it(@"should not crash when category that contains MEAppEvent, when the content contains MEAppEvent action but completionHandler is nil", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
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

                it(@"should not crash when when the content contains MEAppEvent action type but there are missing parameters and completionHandler is nil", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
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

                NSDictionary *(^waitUntilNextResult)(MENotificationService *service, UNMutableNotificationContent *content) = (NSDictionary *(^)(MENotificationService *, UNMutableNotificationContent *)) (UNNotificationCategory *) ^(MENotificationService *service, UNMutableNotificationContent *content) {
                    __block NSDictionary *result = [NSDictionary dictionary];

                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                    [service createUserInfoWithInAppForContent:content
                                                withDownloader:downloader
                                             completionHandler:^(NSDictionary *userInfo) {
                                                 result = userInfo;
                                                 [exp fulfill];
                                             }];
                    [XCTWaiter waitForExpectations:@[exp]
                                           timeout:30];
                    return result;
                };

                it(@"should return nil when content doesnt contain inApp", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"ems": @{}};

                    NSDictionary *result = waitUntilNextResult(service, content);

                    [[result should] beNil];
                });

                it(@"should return nil when content contains inApp but inapp is not dictionary", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"ems": @{
                        @"inapp": @""
                    }};

                    NSDictionary *result = waitUntilNextResult(service, content);

                    [[result should] beNil];
                });

                it(@"should return nil when content contains inApp but campaign_id is missing", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"ems": @{}};

                    [service createUserInfoWithInAppForContent:content
                                                withDownloader:downloader
                                             completionHandler:nil];

                    waitUntilNextResult(service, content);
                });

                it(@"should return nil when content contains inapp and the url is emptyString", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
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
                    MENotificationService *service = [[MENotificationService alloc] init];
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"ems": @{
                        @"inapp": @{
                            @"url": @"https://ems-denna.herokuapp.com/images/Emarsys.png",
                            @"campaign_id": @"campaign_id"
                        }
                    }};

                    NSDictionary *result = waitUntilNextResult(service, content);

                    [[result[@"ems"][@"inapp"][@"inAppData"] shouldNot] beNil];
                });

                it(@"should not crash when everything is correct but completionHandler is nil", ^{
                    MENotificationService *service = [[MENotificationService alloc] init];
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.userInfo = @{@"ems": @{
                        @"inapp": @{
                            @"url": @"https://ems-denna.herokuapp.com/images/Emarsys.png",
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
                        [[[MENotificationService alloc] init] createUserInfoWithInAppForContent:[UNMutableNotificationContent mock]
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
                    MENotificationService *service = [[MENotificationService alloc] init];

                    __block UNNotificationContent *result;
                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                    [service didReceiveNotificationRequest:request
                                        withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                            result = contentToDeliver;
                                            [exp fulfill];
                                        }];
                    [XCTWaiter waitForExpectations:@[exp]
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
                            @"url": @"https://ems-denna.herokuapp.com/images/Emarsys.png",
                            @"campaign_id": @"campaign_id"
                        }
                    }});

                    UNNotificationContent *result = waitForResult(request);

                    [[result.userInfo[@"ems"][@"inapp"][@"inAppData"] shouldNot] beNil];
                });

                it(@"should contains attachment in content when userInfo contains correct image_url", ^{
                    UNNotificationRequest *request = requestWithUserInfo(@{@"image_url": @"https://ems-denna.herokuapp.com/images/Emarsys.png"});

                    UNNotificationContent *result = waitForResult(request);

                    [[result.attachments.firstObject shouldNot] beNil];
                });
            });
        }

SPEC_END
