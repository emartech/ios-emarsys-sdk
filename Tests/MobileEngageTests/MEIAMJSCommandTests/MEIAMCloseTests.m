#import "Kiwi.h"
#import "MEIAMClose.h"
#import "MEIAMViewController.h"
#import "MEInApp.h"

SPEC_BEGIN(MEIAMCloseTests)

    __block MEInApp *meInApp;
    __block MEIAMClose *meiamClose;

    beforeEach(^{
        meInApp = [MEIAMViewController mock];
        meiamClose = [[MEIAMClose alloc] initWithMEIAM:meInApp];
    });

    describe(@"commandName", ^{

        it(@"should return 'close'", ^{
            [[[MEIAMClose commandName] should] equal:@"close"];
        });

    });

    describe(@"handleMessage:resultBlock:", ^{
        it(@"should invoke closeInAppMessageWithCompletionBlock: on meInApp", ^{
            [[meInApp should] receive:@selector(closeInAppMessageWithCompletionBlock:)];
            [meiamClose handleMessage:@{} resultBlock:nil];
        });
    });

SPEC_END



