//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MEIDResponseHandler.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "MobileEngageInternal.h"
#import "MERequestContext.h"
#import "MEExperimental.h"
#import "MEExperimental+Test.h"

SPEC_BEGIN(MEIdResponseHandlerTests)

        __block EMSTimestampProvider *timestampProvider;

        beforeEach(^{
            timestampProvider = [EMSTimestampProvider new];
        });

        describe(@"MEIdResponseHandler.shouldHandleResponse", ^{

            it(@"should return YES when the response contains meId and meIdSignature", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{
                                @"api_me_id": @123456789,
                                @"me_id_signature": @"TheValueOfTheMeIdSignature!"}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                MEIdResponseHandler *handler = [MEIdResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beYes];
            });

            it(@"should return NO when the response lacks meId", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"me_id_signature": @"TheValueOfTheMeIdSignature!"}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                MEIdResponseHandler *handler = [MEIdResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response lacks meIdSignature", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"api_me_id": @123456789}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                MEIdResponseHandler *handler = [MEIdResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

        });

        describe(@"MEIdResponseHandler.handleResponse", ^{

            beforeEach(^{
               [MEExperimental reset];
            });

            it(@"should call setMeId, setMeIdSignature on MobileEngageInternal when meId is a number", ^{
                NSNumber *meId = @123456789;
                NSString *meIdSignature = @"meidsignature";
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"api_me_id": meId, @"me_id_signature": meIdSignature}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                MERequestContext *requestContext = [MERequestContext mock];
                [[requestContext should] receive:@selector(setMeId:) withArguments:[meId stringValue]];
                [[requestContext should] receive:@selector(setMeIdSignature:) withArguments:meIdSignature];
                MEIdResponseHandler *handler = [[MEIdResponseHandler alloc] initWithRequestContext:requestContext];

                [handler handleResponse:response];
            });

            it(@"should call setMeId, setMeIdSignature on MobileEngageInternal when meId is a string", ^{
                NSString *meId = @"me123456789";
                NSString *meIdSignature = @"meidsignature";
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"api_me_id": meId, @"me_id_signature": meIdSignature}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];
                MERequestContext *requestContext = [MERequestContext mock];
                [[requestContext should] receive:@selector(setMeId:) withArguments:meId];
                [[requestContext should] receive:@selector(setMeIdSignature:) withArguments:meIdSignature];
                MEIdResponseHandler *handler = [[MEIdResponseHandler alloc] initWithRequestContext:requestContext];

                [handler handleResponse:response];
            });

        });

SPEC_END