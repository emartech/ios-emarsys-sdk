#import "Kiwi.h"
#import "EMSWindowProvider.h"
#import "EMSSceneProvider.h"
#import "EMSViewControllerProvider.h"

SPEC_BEGIN(EMSWindowProviderTests)

        __block EMSWindowProvider *windowProvider;
        __block EMSSceneProvider *mockSceneProvider;
        __block EMSViewControllerProvider *viewControllerProvider;

        beforeEach(^{
            viewControllerProvider = [EMSViewControllerProvider nullMock];
            mockSceneProvider = [EMSSceneProvider nullMock];
            windowProvider = [[EMSWindowProvider alloc] initWithViewControllerProvider:viewControllerProvider
                                                                         sceneProvider:mockSceneProvider];
        });

        describe(@"initWithViewControllerProvider", ^{
            it(@"iamViewControllerProvider must not be null", ^{
                @try {
                    [[EMSWindowProvider alloc] initWithViewControllerProvider:nil
                                                                sceneProvider:mockSceneProvider];
                    fail(@"Expected Exception when iamViewControllerProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: viewControllerProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"sceneProvider must not be null", ^{
                @try {
                    [[EMSWindowProvider alloc] initWithViewControllerProvider:viewControllerProvider
                                                                sceneProvider:nil];
                    fail(@"Expected Exception when sceneProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: sceneProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"window check", ^{

            if (@available(iOS 13.0, *)) {

                it(@"should use sceneProvider for window creating", ^{
                    [[mockSceneProvider should] receive:@selector(provideScene)];

                    UIWindow *result = [windowProvider provideWindow];

                    [[result shouldNot] beNil];
                });

            } else {

                it(@"should not use sceneProvider for window creating", ^{
                    [[mockSceneProvider shouldNot] receive:@selector(provideScene)];

                    UIWindow *result = [windowProvider provideWindow];

                    [[result shouldNot] beNil];
                });

            }

        });

        describe(@"provideWindow", ^{

            it(@"returned value should not be nil", ^{
                UIWindow *window = [windowProvider provideWindow];

                [[window shouldNot] beNil];
            });

            if (!@available(iOS 13.0, *)) {

                it(@"should have a screen size", ^{
                    UIWindow *window = [windowProvider provideWindow];

                    [[theValue(window.frame) should] equal:theValue(UIScreen.mainScreen.bounds)];
                });

            }

            it(@"should have clear backgroundColor", ^{
                UIWindow *window = [windowProvider provideWindow];

                [[window.backgroundColor should] equal:UIColor.clearColor];
            });

            it(@"should have windowLevel set to UIWindowLevelAlert", ^{
                UIWindow *window = [windowProvider provideWindow];

                [[theValue(window.windowLevel) should] equal:theValue(UIWindowLevelAlert)];
            });

            it(@"should have rootViewController set", ^{
                UIViewController *viewController = [UIViewController new];
                [[viewControllerProvider should] receive:@selector(provideViewController) andReturn:viewController];

                UIWindow *window = [windowProvider provideWindow];

                [[window.rootViewController should] equal:viewController];
            });

        });

SPEC_END
