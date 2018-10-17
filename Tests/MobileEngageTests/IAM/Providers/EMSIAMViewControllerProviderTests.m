#import "Kiwi.h"
#import "EMSIAMViewControllerProvider.h"
#import "MEJSBridge.h"
#import "MEIAMViewController.h"

SPEC_BEGIN(EMSIAMViewControllerProviderTests)

        __block EMSIAMViewControllerProvider *viewControllerProvider;
        __block MEJSBridge *jsBridge;

        beforeEach(^{
            jsBridge = [MEJSBridge mock];
            viewControllerProvider = [[EMSIAMViewControllerProvider alloc] initWithJSBridge:jsBridge];
        });

        describe(@"initWithJSBridge:", ^{
            it(@"should throw exception when jsBridge is nil", ^{
                @try {
                    [[EMSIAMViewControllerProvider alloc] initWithJSBridge:nil];
                    fail(@"Expected Exception when jsBridge is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: jsBridge"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"provideViewController", ^{

            it(@"returned value should not be nil", ^{
                MEIAMViewController *viewController = [viewControllerProvider provideViewController];

                [[viewController shouldNot] beNil];
            });
        });

SPEC_END
