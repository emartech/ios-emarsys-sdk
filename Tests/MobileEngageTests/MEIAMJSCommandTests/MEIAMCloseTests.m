#import "Kiwi.h"
#import "MEIAMClose.h"
#import "MEInApp.h"

SPEC_BEGIN(MEIAMCloseTests)

    __block id closeProtocol;
    __block MEIAMClose *meiamClose;

    beforeEach(^{
        closeProtocol = [KWMock mockForProtocol:@protocol(EMSIAMCloseProtocol)];
        meiamClose = [[MEIAMClose alloc] initWithEMSIAMCloseProtocol:closeProtocol];
    });

    describe(@"commandName", ^{

        it(@"should return 'close'", ^{
            [[[MEIAMClose commandName] should] equal:@"close"];
        });

    });

    describe(@"handleMessage:resultBlock:", ^{
        it(@"should invoke closeInAppWithCompletionHandler: on closeProtocol", ^{
            [[closeProtocol should] receive:@selector(closeInAppWithCompletionHandler:)];
            [meiamClose handleMessage:@{} resultBlock:nil];
        });
    });

SPEC_END



