//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSTimestampProvider.h"
#import "Kiwi.h"
#import "MEIDResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "AbstractResponseHandler+Private.h"
#import "MEInApp.h"
#import "MEInApp+Private.h"
#import "MobileEngage+Test.h"
#import "MEDisplayedIAMRepository.h"
#import "MobileEngage+Private.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "FakeDbHelper.h"

SPEC_BEGIN(MEIAMResponseHandlerTests)

        __block EMSTimestampProvider *timestampProvider;

        beforeEach(^{
            timestampProvider = [EMSTimestampProvider new];
        });

        describe(@"MEIAMResponseHandler.shouldHandleResponse", ^{

            it(@"should return YES when the response contains html message", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"html": @"<html><body style=\"background-color:red\"></body></html>"}} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel mock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beYes];
            });

            it(@"should return NO when the response lacks html message", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel mock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response lacks html inside message", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{}} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel mock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response lacks body", ^{
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:nil
                                                                             requestModel:[EMSRequestModel mock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response contains message as a string", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @"whatever"} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel mock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

        });

        describe(@"MEIAMResponseHandler.handleResponse", ^{

            it(@"should call showMessage on MEInApp", ^{
                NSString *html = @"<html><body style=\"background-color:red\"></body></html>";
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"id": @"campaignId", @"html": html}} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel mock]
                                                                                timestamp:[NSDate date]];

                id iamMock = [MEInApp mock];
                [[iamMock should] receive:@selector(showMessage:completionHandler:) withArguments:[[MEInAppMessage alloc] initWithResponse:response], kw_any()];
                MobileEngage.inApp = iamMock;

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];
                [handler handleResponse:response];
            });

            it(@"should save the inapp display", ^{
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:@"appid"
                                           applicationPassword:@"pw"];
                }];

                [MobileEngage setupWithConfig:config launchOptions:[NSDictionary new]];
                FakeDbHelper *dbHelper = [FakeDbHelper new];
                [MobileEngage setDbHelper:dbHelper];
                MobileEngage.inApp.timestampProvider = timestampProvider;

                NSString *html = @"<html><body style=\"background-color:red\"></body></html>";
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"id": @"12345678", @"html": html}} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel mock]
                                                                                timestamp:[NSDate date]];

                [[MEIAMResponseHandler new] handleResponse:response];

                [dbHelper waitForInsert];
                [[[(MEDisplayedIAM *) dbHelper.insertedModel campaignId] should] equal:@"12345678"];
            });

        });

SPEC_END
