#import "Kiwi.h"
#import "EMSViewControllerProvider.h"

SPEC_BEGIN(EMSViewControllerProviderTests)

        __block EMSViewControllerProvider *viewControllerProvider;

        beforeEach(^{
            viewControllerProvider = [EMSViewControllerProvider new];
        });

        describe(@"provideViewController", ^{

            it(@"returned value should not be nil", ^{
                UIViewController *viewController = [viewControllerProvider provideViewController];

                [[viewController shouldNot] beNil];
            });

            it(@"should have clear backgroundColor", ^{
                UIViewController *viewController = [viewControllerProvider provideViewController];

                [[viewController.view.backgroundColor should] equal:UIColor.clearColor];
            });
        });

SPEC_END
