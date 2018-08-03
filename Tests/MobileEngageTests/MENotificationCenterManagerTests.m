#import "Kiwi.h"
#import "MENotificationCenterManager.h"
#import "EMSWaiter.h"


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

            [EMSWaiter waitForExpectations:@[exp] timeout:5];
        });
    });


SPEC_END
