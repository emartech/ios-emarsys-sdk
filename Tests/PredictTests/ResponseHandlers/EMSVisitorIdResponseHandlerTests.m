//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSVisitorIdResponseHandler.h"
#import "EMSAbstractResponseHandler+Private.h"

SPEC_BEGIN(EMSVisitorIdResponseHandlerTests)

        describe(@"initWithRequestContext:", ^{

            it(@"should throw exception when requestContext is nil", ^{
                @try {
                    [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:nil];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should return with an EMSVisitorIdResponseHandler instance", ^{
                EMSVisitorIdResponseHandler *result = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:[PRERequestContext mock]];
                [[result shouldNot] beNil];
                [[result should] beKindOfClass:[EMSVisitorIdResponseHandler class]];
            });

            it(@"should set property", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *result = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                [[result.requestContext should] equal:requestContext];
            });
        });

        describe(@"shouldHandleResponse:", ^{

            it(@"should return false when response has no VisitorIdCookie", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *mockResponse = [EMSResponseModel mock];
                [[mockResponse should] receive:@selector(cookies)
                                     andReturn:@{}];
                BOOL result = [responseHandler shouldHandleResponse:mockResponse];
                [[theValue(result) should] beNo];
            });

            it(@"should return true when response has VisitorIdCookie", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *mockResponse = [EMSResponseModel mock];
                [[mockResponse should] receive:@selector(cookies)
                                     andReturn:@{@"cdv": @"this is not a correct value"}];
                BOOL result = [responseHandler shouldHandleResponse:mockResponse];
                [[theValue(result) should] beYes];
            });
        });

        describe(@"handleResponse:", ^{
            it(@"should set cookie to requestContext", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *mockResponse = [EMSResponseModel mock];
                NSHTTPCookie *mockCookie = [NSHTTPCookie mock];
                [[mockCookie should] receive:@selector(value)
                                   andReturn:@"visitorId"];
                [[mockResponse should] receive:@selector(cookies)
                                     andReturn:@{@"cdv": mockCookie}];
                [[requestContext should] receive:@selector(setVisitorId:) withArguments:@"visitorId"];
                [responseHandler handleResponse:mockResponse];
            });
        });
SPEC_END
