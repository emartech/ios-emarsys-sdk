//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"
#import "NSURLRequest+EMSCore.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(NSURLRequestCoreTests)

    describe(@"NSURLRequest+CoreTests requestWithRequestModel:additionalHeaders:", ^{

        it(@"should create an NSUrlRequest from EMSRequestModel when additionalHeaders is nil", ^{

            NSString *url = @"http://www.google.com";
            NSDictionary *headers = @{@"asdasd" : @"dgereg"};
            NSDictionary *payload = @{@"key": @"value"};

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setHeaders:headers];
                [builder setPayload:payload];
            }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

            NSURLRequest *request = [NSURLRequest requestWithRequestModel:model
                                                        additionalHeaders:nil];

            NSError *error = nil;
            NSData *body = [NSJSONSerialization dataWithJSONObject:payload
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

            [[[[request URL] absoluteString] should] equal:url];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] should] equal:headers];
            [[[request HTTPBody] should] equal:body];
        });

        it(@"should create an NSUrlRequest from EMSRequestModel when additionalHeaders is not nil", ^{

            NSString *url = @"http://www.google.com";
            NSDictionary *headers = @{@"headerKey": @"headerValue"};
            NSDictionary *additionalHeaders = @{@"additionalHeaderKey": @"additionalHeaderValue"};
            NSDictionary *payload = @{@"key": @"value"};

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setHeaders:headers];
                [builder setPayload:payload];
            }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

            NSURLRequest *request = [NSURLRequest requestWithRequestModel:model
                                                        additionalHeaders:additionalHeaders];

            NSError *error = nil;
            NSData *body = [NSJSONSerialization dataWithJSONObject:payload
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

            NSMutableDictionary *result = [headers mutableCopy];
            [result addEntriesFromDictionary:additionalHeaders];
            [[[[request URL] absoluteString] should] equal:url];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] should] equal:result];
            [[[request HTTPBody] should] equal:body];
        });

        it(@"should create an NSUrlRequest from EMSRequestModel when additionalHeaders is not nil, model's headers is nil", ^{

            NSString *url = @"http://www.google.com";
            NSDictionary *additionalHeaders = @{@"additionalHeaderKey": @"additionalHeaderValue"};
            NSDictionary *payload = @{@"key": @"value"};

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:payload];
            }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

            NSURLRequest *request = [NSURLRequest requestWithRequestModel:model
                                                        additionalHeaders:additionalHeaders];

            NSError *error = nil;
            NSData *body = [NSJSONSerialization dataWithJSONObject:payload
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

            [[[[request URL] absoluteString] should] equal:url];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] should] equal:additionalHeaders];
            [[[request HTTPBody] should] equal:body];
        });

        it(@"should create an NSUrlRequest from EMSRequestModel when additionalHeaders is nil, model's headers is nil", ^{

            NSString *url = @"http://www.google.com";
            NSDictionary *payload = @{@"key": @"value"};

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:payload];
            }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

            NSURLRequest *request = [NSURLRequest requestWithRequestModel:model
                                                        additionalHeaders:nil];

            NSError *error = nil;
            NSData *body = [NSJSONSerialization dataWithJSONObject:payload
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

            [[[[request URL] absoluteString] should] equal:url];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] should] beEmpty];
            [[[request HTTPBody] should] equal:body];
        });

    });

    describe(@"NSURLRequest+CoreTests requestWithRequestModel:(EMSRequestModel *)model", ^{
        it(@"should create NSURLRequest from EMSRequestModel", ^{
            NSString *url = @"http://www.google.com";
            NSDictionary *payload = @{@"key": @"value"};

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:payload];
            }                                       timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];

            NSURLRequest *request = [NSURLRequest requestWithRequestModel:model];

            NSError *error = nil;
            NSData *body = [NSJSONSerialization dataWithJSONObject:payload
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

            [[[[request URL] absoluteString] should] equal:url];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] should] beEmpty];
            [[[request HTTPBody] should] equal:body];
        });
    });

SPEC_END
