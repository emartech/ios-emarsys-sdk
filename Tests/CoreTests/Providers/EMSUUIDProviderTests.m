#import "Kiwi.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(EMSUUIDProviderTests)

        describe(@"provideUUID", ^{

            it(@"should not return with nil", ^{
                [[[[EMSUUIDProvider new] provideUUID] shouldNot] beNil];
            });

            it(@"should return with UUID", ^{
                [[[[EMSUUIDProvider new] provideUUID] should] beKindOfClass:[NSUUID class]];
            });

        });

        describe(@"provideUUIDString", ^{

            it(@"should not return with nil", ^{
                [[[[EMSUUIDProvider new] provideUUIDString] shouldNot] beNil];
            });

            it(@"should return with UUID", ^{
                [[[[EMSUUIDProvider new] provideUUIDString] should] beKindOfClass:[NSString class]];
            });

        });

SPEC_END