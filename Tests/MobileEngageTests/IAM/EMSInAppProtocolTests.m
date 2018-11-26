#import "Kiwi.h"
#import "EmarsysTestUtils.h"

SPEC_BEGIN(EMSInAppProtocolTests)

        beforeEach(^{
            [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];
        });

        afterEach(^{
            [EmarsysTestUtils tearDownEmarsys];
        });

        describe(@"pause", ^{

            it(@"should set paused state to YES", ^{
                [Emarsys.inApp pause];

                [[theValue([Emarsys.inApp isPaused]) should] beYes];
            });
        });

        describe(@"resume", ^{

            it(@"should set paused state to NO", ^{
                [Emarsys.inApp resume];

                [[theValue([Emarsys.inApp isPaused]) should] beNo];
            });
        });

        describe(@"isPaused", ^{

            it(@"should be ", ^{
                [[theValue([Emarsys.inApp isPaused]) should] beNo];
            });
        });

SPEC_END
