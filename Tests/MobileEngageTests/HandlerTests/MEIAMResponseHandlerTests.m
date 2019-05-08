//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSTimestampProvider.h"
#import "Kiwi.h"
#import "MEIAMResponseHandler.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "MEInApp.h"

SPEC_BEGIN(MEIAMResponseHandlerTests)

        __block EMSTimestampProvider *timestampProvider;

        beforeEach(^{
            timestampProvider = [EMSTimestampProvider new];
        });

        describe(@"initWithInApp:", ^{
            it(@"should throw exception when inApp is nil", ^{
                @try {
                    [[MEIAMResponseHandler alloc] initWithInApp:nil];
                    fail(@"Expected Exception when inApp is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: inApp"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"MEIAMResponseHandler.shouldHandleResponse", ^{

            it(@"should return YES when the response contains html message", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"html": @"<html><body style=\"background-color:red\"></body></html>"}}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beYes];
            });

            it(@"should return NO when the response lacks html message", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response lacks html inside message", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{}} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response lacks body", ^{
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:nil
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response contains message as a string", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @"whatever"} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

        });

        describe(@"MEIAMResponseHandler.handleResponse", ^{

            it(@"should call showMessage on MEInApp", ^{
                NSString *html = @"<html><body style=\"background-color:red\"></body></html>";
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"id": @"campaignId", @"html": html}}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                id iamMock = [MEInApp mock];
                [[iamMock should] receive:@selector(showMessage:completionHandler:)
                            withArguments:[[MEInAppMessage alloc] initWithResponse:response], kw_any()];

                MEIAMResponseHandler *handler = [[MEIAMResponseHandler alloc] initWithInApp:iamMock];
                [handler handleResponse:response];
            });

        });

SPEC_END
