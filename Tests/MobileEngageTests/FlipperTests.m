#import "Kiwi.h"
#import "MEExperimental.h"

@interface MEExperimental(Tests)
+ (void)reset;
@end

SPEC_BEGIN(FlipperTest)

    describe(@"enableFeatures", ^{
       it(@"should enable all the given features", ^{
           NSArray<EMSFlipperFeature> *features = @[USER_CENTRIC_INBOX];
           [MEExperimental enableFeatures:features];
           for (EMSFlipperFeature feature in features) {
                [[theValue([MEExperimental isFeatureEnabled:feature]) should] beYes];
           }
       });
    });

    describe(@"MEExperimental.reset", ^{
        it(@"should reset the state", ^{
            [MEExperimental enableFeature:USER_CENTRIC_INBOX];
            [MEExperimental reset];
            [[theValue([MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX]) should] beFalse];
        }) ;
    });

SPEC_END
