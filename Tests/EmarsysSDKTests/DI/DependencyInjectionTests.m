//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDependencyContainer.h"
#import "EMSDependencyInjection.h"

@interface EMSDependencyInjection ()

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer;

@end

SPEC_BEGIN(DependencyInjectionTests)

        beforeEach(^{
            [EMSDependencyInjection setDependencyContainer:nil];
        });

        describe(@"setupWithDependencyContainer:", ^{

            it(@"should set the given dependencyContainer", ^{
                EMSDependencyContainer *dependencyContainer = [EMSDependencyContainer mock];

                [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer];

                [[(NSObject <EMSDependencyContainerProtocol> *) EMSDependencyInjection.dependencyContainer should] equal:dependencyContainer];
            });

            it(@"should not override previously set dependencyContainer", ^{
                EMSDependencyContainer *dependencyContainer1 = [EMSDependencyContainer mock];
                EMSDependencyContainer *dependencyContainer2 = [EMSDependencyContainer mock];

                [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer1];
                [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer2];

                [[(NSObject <EMSDependencyContainerProtocol> *) EMSDependencyInjection.dependencyContainer should] equal:dependencyContainer1];
            });
        });

        describe(@"tearDown", ^{

            it(@"should set the dependencyContainer to nil", ^{
                [EMSDependencyInjection setupWithDependencyContainer:[EMSDependencyContainer mock]];

                [EMSDependencyInjection tearDown];

                [[(NSObject <EMSDependencyContainerProtocol> *) EMSDependencyInjection.dependencyContainer should] beNil];
            });
        });

SPEC_END
