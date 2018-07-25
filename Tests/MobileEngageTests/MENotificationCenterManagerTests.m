#import "Kiwi.h"
#import "MENotificationCenterManager.h"


SPEC_BEGIN(MENotificationCenterManagerTests)

    beforeEach(^{
    });

    describe(@"addHandlerBlock:forNotification:", ^{
        it(@"should register the block for the notification", ^{
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"expectation"];

            MENotificationCenterManager *ncm = [MENotificationCenterManager new];
            [ncm addHandlerBlock:^{
                [exp fulfill];
            }    forNotification:@"testNotification"];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification" object:nil];

            [XCTWaiter waitForExpectations:@[exp] timeout:5];
        });
    });


SPEC_END
