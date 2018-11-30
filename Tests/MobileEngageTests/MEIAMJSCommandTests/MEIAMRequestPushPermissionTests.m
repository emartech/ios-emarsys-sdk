#import "Kiwi.h"
#import "MEIAMRequestPushPermission.h"


SPEC_BEGIN(MEIAMRequestPushPermissionTests)

    __block UIApplication *_applicationMock;
    __block MEIAMRequestPushPermission *_command;

    describe(@"requestPushPermission", ^{

        beforeEach(^{
            _command = [MEIAMRequestPushPermission new];
            _applicationMock = [UIApplication mock];
            [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];
        });

    });

SPEC_END



