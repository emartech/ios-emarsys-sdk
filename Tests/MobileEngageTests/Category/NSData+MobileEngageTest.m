#import "Kiwi.h"
#import "NSData+MobileEngine.h"

SPEC_BEGIN(NSDataMobileEngageTests)

    describe(@"deviceTokenString", ^{

        it(@"should transform data into string", ^{
            char *rawData = "1234512345ABCDEF";
            NSData *deviceToken = [NSData dataWithBytes:rawData length:sizeof(rawData)];
            NSMutableString *token = [NSMutableString new];
            const char *data = [deviceToken bytes];
            for (int i = 0; i < deviceToken.length; ++i) {
                [token appendFormat:@"%02.2hhx", data[i]];
            }
            [[[deviceToken deviceTokenString] should] equal:token];
        });

    });

SPEC_END
