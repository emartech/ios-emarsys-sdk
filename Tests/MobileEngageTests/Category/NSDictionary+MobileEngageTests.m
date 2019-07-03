#import "Kiwi.h"
#import "NSDictionary+MobileEngage.h"

SPEC_BEGIN(NSDictionaryMobileEngageTests)

    describe(@"messageId", ^{
        it(@"should return with nil, when there is no CustomDataKey in the dictionary", ^{
            NSDictionary *dict = @{};
            NSString *messageId = [dict messageId];
            [[messageId should] beNil];
        });

        it(@"should return with nil, when there is no sid in the dictionary", ^{
            NSDictionary *dict = @{
                    @"key1": @"value1",
                    @"u": @"{\"noSid\": \"value\"}"
            };
            [[[dict messageId] should] beNil];
        });

        it(@"should return nil, when customData is available but data is not valid JSON wrapped in string", ^{
            NSDictionary *dict = @{
                    @"u": @"invalid json"
            };
            [[[dict messageId] should] beNil];
        });

        it(@"should return messageId, when it is present in json format", ^{
            NSDictionary *dict = @{
                    @"u": @"{\"sid\": \"123456789\"}"
            };
            [[[dict messageId] should] equal:@"123456789"];
        });

        it(@"should return messageId, when it is present in structured format", ^{
            NSDictionary *dict = @{
                    @"u": @{
                            @"sid": @"123456789"
                    }
            };
            [[[dict messageId] should] equal:@"123456789"];
        });
    });

SPEC_END
