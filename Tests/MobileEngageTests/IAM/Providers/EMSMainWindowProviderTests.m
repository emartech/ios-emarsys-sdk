#import "Kiwi.h"
#import "EMSMainWindowProvider.h"

SPEC_BEGIN(EMSMainWindowProviderTests)

        describe(@"initWithApplication:", ^{

            it(@"should throw exception when application is nil", ^{
                @try {
                    [[EMSMainWindowProvider alloc] initWithApplication:nil];
                    fail(@"Expected Exception when application is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: application"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"provideMainWindow", ^{

            __block EMSMainWindowProvider *provider;
            __block UIApplication *application;

            beforeEach(^{
                application = [UIApplication nullMock];
                [[application should] receive:@selector(delegate)
                                    andReturn:[[UIApplication sharedApplication] delegate]];
                provider = [[EMSMainWindowProvider alloc] initWithApplication:application];
            });

            it(@"returned value should not be nil", ^{
                UIWindow *window = [provider provideMainWindow];

                [[window shouldNot] beNil];
            });

            it(@"should return the window from app delegate", ^{
                [[[provider provideMainWindow] should] equal:[[[UIApplication sharedApplication] delegate] window]];
            });

        });

SPEC_END
