//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSResponseModel.h"
#import "EMSTimestampProvider.h"
#import "EMSRequestModelBuilder.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(EMSResponseModelTests)

        __block EMSTimestampProvider *timestampProvider;
        __block EMSUUIDProvider *uuidProvider;

        beforeEach(^{
            timestampProvider = [EMSTimestampProvider new];
            uuidProvider = [EMSUUIDProvider new];
        });

        describe(@"ResponseModel init", ^{

            it(@"should be created and fill all of properties, when correct NSHttpUrlResponse and NSData is passed", ^{
                NSDictionary<NSString *, NSString *> *headers = @{
                    @"key": @"value",
                    @"key2": @"value2"
                };
                NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"host.com/url"]
                                                                          statusCode:200
                                                                         HTTPVersion:@"1.1"
                                                                        headerFields:headers];
                NSString *dataString = @"dataString";
                NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:response
                                                                                               data:data
                                                                                       requestModel:[EMSRequestModel nullMock]
                                                                                          timestamp:[timestampProvider provideTimestamp]];
                NSString *responseDataString = [[NSString alloc] initWithData:responseModel.body
                                                                     encoding:NSUTF8StringEncoding];
                [[@(responseModel.statusCode) should] equal:@200];
                [[responseModel.headers should] equal:headers];
                [[responseDataString should] equal:dataString];
            });


            it(@"should create ResponseModel with the specified properties", ^{
                NSData *responseBody = [NSJSONSerialization dataWithJSONObject:@{@"b1": @"bv1"} options:0 error:nil];
                EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402
                                                                               headers:@{@"h1": @"hv1"}
                                                                                  body:responseBody
                                                                          requestModel:[EMSRequestModel nullMock]
                                                                             timestamp:[timestampProvider provideTimestamp]];

                [[theValue(model.statusCode) should] equal:theValue(402)];
                [[model.headers[@"h1"] should] equal:@"hv1"];

                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:model.body options:0 error:nil];
                [[json[@"b1"] should] equal:@"bv1"];
            });

            it(@"should not accept nil request model", ^{
                @try {
                    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"host.com/url"]
                                                                              statusCode:200
                                                                             HTTPVersion:@"1.1"
                                                                            headerFields:@{}];
                    NSData *data = [@"dataString" dataUsingEncoding:NSUTF8StringEncoding];
                    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:response
                                                                                                   data:data
                                                                                           requestModel:nil
                                                                                              timestamp:[timestampProvider provideTimestamp]];
                    fail(@"Expected exception when requestModel is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should make requestModel accessible through the property", ^{
                NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"host.com/url"]
                                                                          statusCode:200
                                                                         HTTPVersion:@"1.1"
                                                                        headerFields:@{}];
                NSData *data = [@"dataString" dataUsingEncoding:NSUTF8StringEncoding];
                EMSRequestModel *expectedModel = [EMSRequestModel nullMock];
                EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:response
                                                                                               data:data
                                                                                       requestModel:expectedModel
                                                                                          timestamp:[timestampProvider provideTimestamp]];
                [[responseModel.requestModel should] equal:expectedModel];
            });

            it(@"should initialize cookies when present", ^{
                NSString *const cookiesString = @"cdv=6EABCEF289FF5E44;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=340830C6DC60E76D, xp=ERyKp0JzMpzkCQ1YDyEcTirU-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT";
                NSDictionary<NSString *, NSString *> *headers = @{
                    @"key": @"value",
                    @"key2": @"value2",
                    @"Set-Cookie": cookiesString
                };
                NSString *url = @"https://host.com/url";
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
                EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:response
                                                                                               data:data
                                                                                       requestModel:requestModel
                                                                                          timestamp:[timestampProvider provideTimestamp]];

                NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                                                                  forURL:requestModel.url];
                NSDictionary *expectedCookies = @{
                    @"cdv": cookies[0],
                    @"s": cookies[1],
                    @"xp": cookies[2]
                };
                NSDictionary *resultCookies = responseModel.cookies;

                [[resultCookies should] equal:expectedCookies];
            });
            
            it(@"should initialize cookies with lowerCased key when present", ^{
                NSString *const cookiesString = @"CDV=6EABCEF289FF5E44;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT, s=340830C6DC60E76D, xP=ERyKp0JzMpzkCQ1YDyEcTirU-1_JmYJ0idhLv23ebPQHuvQANK5aTUfzOBKf89-h;Path=/;Expires=Thu, 19-Sep-2019 18:39:42 GMT";
                NSDictionary<NSString *, NSString *> *headers = @{
                    @"key": @"value",
                    @"key2": @"value2",
                    @"Set-Cookie": cookiesString
                };
                NSString *url = @"https://host.com/url";
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
                EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:response
                                                                                               data:data
                                                                                       requestModel:requestModel
                                                                                          timestamp:[timestampProvider provideTimestamp]];

                NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                                                                  forURL:requestModel.url];
                NSDictionary *expectedCookies = @{
                    @"cdv": cookies[0],
                    @"s": cookies[1],
                    @"xp": cookies[2]
                };
                NSDictionary *resultCookies = responseModel.cookies;

                [[resultCookies should] equal:expectedCookies];
            });

        });

        describe(@"parsedBody", ^{

            it(@"should return the body parsed as JSON", ^{
                NSDictionary *dict = @{@"b1": @"bv1", @"deep": @{@"child1": @"value1"}};
                NSData *responseBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402
                                                                               headers:@{}
                                                                                  body:responseBody
                                                                          requestModel:[EMSRequestModel nullMock]
                                                                             timestamp:[timestampProvider provideTimestamp]];

                [[model.parsedBody should] equal:dict];
            });

            it(@"should return nil when body is nil", ^{
                EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402
                                                                               headers:@{}
                                                                                  body:nil
                                                                          requestModel:[EMSRequestModel nullMock]
                                                                             timestamp:[timestampProvider provideTimestamp]];

                [[model.parsedBody should] beNil];
            });

            it(@"should return nil when body is not a JSON", ^{
                EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402
                                                                               headers:@{}
                                                                                  body:[@"Created" dataUsingEncoding:NSUTF8StringEncoding]
                                                                          requestModel:[EMSRequestModel nullMock]
                                                                             timestamp:[timestampProvider provideTimestamp]];

                [[model.parsedBody should] beNil];
            });

            it(@"should only parse once, when called multiple times", ^{
                NSDictionary *dict = @{@"b1": @"bv1", @"deep": @{@"child1": @"value1"}};
                NSData *responseBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402
                                                                               headers:@{}
                                                                                  body:responseBody
                                                                          requestModel:[EMSRequestModel nullMock]
                                                                             timestamp:[timestampProvider provideTimestamp]];

                id parsedBody1 = model.parsedBody;
                id parsedBody2 = model.parsedBody;

                [[theValue(parsedBody1 == parsedBody2) should] beTrue];
            });

        });

SPEC_END