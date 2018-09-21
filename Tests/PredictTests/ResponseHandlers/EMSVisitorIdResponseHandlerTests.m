//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSVisitorIdResponseHandler.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(EMSVisitorIdResponseHandlerTests)

        EMSResponseModel *(^createResponseModel)(NSString *url, NSDictionary *headers) = ^EMSResponseModel *(NSString *url, NSDictionary *headers) {
            EMSTimestampProvider *timestampProvider = [EMSTimestampProvider new];
            EMSUUIDProvider *uuidProvider = [EMSUUIDProvider new];
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:url]
                                                                      statusCode:200
                                                                     HTTPVersion:@"1.1"
                                                                    headerFields:headers];
            NSData *data = [@"dataString" dataUsingEncoding:NSUTF8StringEncoding];
            EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:url];
                }
                                                           timestampProvider:timestampProvider
                                                                uuidProvider:uuidProvider];
            return [[EMSResponseModel alloc] initWithHttpUrlResponse:response
                                                                data:data
                                                        requestModel:requestModel
                                                           timestamp:[timestampProvider provideTimestamp]];
        };

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

            it(@"should return no when response has no VisitorIdCookie", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *responseModel = createResponseModel(@"https://www.emarsys.com", @{});
                BOOL result = [responseHandler shouldHandleResponse:responseModel];
                [[theValue(result) should] beNo];
            });

            it(@"should return true when response has VisitorIdCookie", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *responseModel = createResponseModel(@"https://recommender.scarabresearch.com", @{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"});
                BOOL result = [responseHandler shouldHandleResponse:responseModel];
                [[theValue(result) should] beYes];
            });

            it(@"should return no, when the url is not predict url", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *responseModel = createResponseModel(@"https://www.emarsys.com", @{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"});
                BOOL result = [responseHandler shouldHandleResponse:responseModel];
                [[theValue(result) should] beNo];
            });

            it(@"should return no when the url is basePredict but there is no cookie", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *responseModel = createResponseModel(@"https://recommender.scarabresearch.com", @{});
                BOOL result = [responseHandler shouldHandleResponse:responseModel];
                [[theValue(result) should] beNo];
            });
        });

        describe(@"handleResponse:", ^{
            it(@"should set cookie to requestContext", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *responseModel = createResponseModel(@"https://www.emarsys.com", @{@"Set-Cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"});
                [[requestContext should] receive:@selector(setVisitorId:) withArguments:@"CDVVALUE"];
                [responseHandler handleResponse:responseModel];
            });

            it(@"should set cookie to requestContext when the header key is lowercase", ^{
                PRERequestContext *requestContext = [PRERequestContext mock];
                EMSVisitorIdResponseHandler *responseHandler = [[EMSVisitorIdResponseHandler alloc] initWithRequestContext:requestContext];
                EMSResponseModel *responseModel = createResponseModel(@"https://www.emarsys.com", @{@"set-cookie": @"CDV=CDVVALUE;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=SVALUE, xP=XPVALUE-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT"});
                [[requestContext should] receive:@selector(setVisitorId:) withArguments:@"CDVVALUE"];
                [responseHandler handleResponse:responseModel];
            });
        });
SPEC_END
