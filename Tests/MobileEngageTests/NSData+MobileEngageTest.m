#import "Kiwi.h"
#import "NSData+MobileEngine.h"

SPEC_BEGIN(NSDataMobileEngageTests)

    describe(@"deviceTokenString", ^{

        it(@"should transform data into string", ^{
            char *rawData = "1234512345ABCDEF";
            NSData *data = [NSData dataWithBytes:rawData length:sizeof(rawData)];
            NSString *token = [[[data description]
                    stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                    stringByReplacingOccurrencesOfString:@" " withString:@""];
            [[[data deviceTokenString] should] equal:token];
        });

    });

SPEC_END
