//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"
#import "EMSSQLiteHelper.h"
#import "EMSDBTriggerKey.h"
#import "EMSDependencyContainer.h"

@interface Emarsys ()

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer;
+ (EMSSQLiteHelper *)sqliteHelper;

@end

SPEC_BEGIN(EmarsysTests)

        __block PredictInternal *predict;
        __block MobileEngageInternal *engage;
        __block EMSDependencyContainer *container;
        NSString *const customerId = @"customerId";

        beforeEach(^{
            predict = [PredictInternal nullMock];
            engage = [MobileEngageInternal nullMock];
            container = [EMSDependencyContainer nullMock];

            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"applicationCode"
                                    applicationPassword:@"applicationPassword"];
                [builder setContactFieldId:@32];
                [builder setMerchantId:@"merchantId"];
            }];
            [Emarsys setupWithConfig:config];

            [container stub:@selector(mobileEngage)
                  andReturn:engage];
            [container stub:@selector(predict)
                  andReturn:predict];
            [Emarsys setDependencyContainer:container];
        });

        describe(@"setupWithConfig:", ^{
            it(@"should set predict", ^{
                [[(NSObject *) [Emarsys predict] shouldNot] beNil];
            });

            it(@"should set push", ^{
                [[(NSObject *) [Emarsys push] shouldNot] beNil];
            });

            it(@"register Predict trigger", ^{
                EMSConfig *configMock = [EMSConfig nullMock];
                [[configMock should] receive:@selector(merchantId) andReturn:@"merchantId"];
                [Emarsys setupWithConfig:configMock];

                NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];

                NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                                         withEvent:[EMSDBTriggerEvent insertEvent]
                                                                                          withType:[EMSDBTriggerType afterType]]];
                [[theValue([afterInsertTriggers count]) should] equal:theValue(1)];
            });

            it(@"should throw an exception when there is no config set", ^{

                @try {
                    [Emarsys setupWithConfig:nil];
                    fail(@"Expected Exception when config is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: config"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"setCustomerWithCustomerId:resultBlock:", ^{
            it(@"should delegate the call to predictInternal", ^{
                [[predict should] receive:@selector(setCustomerWithId:)
                            withArguments:customerId];
                [Emarsys setCustomerWithId:customerId];
            });

            it(@"should delegate the call to mobileEngageInternal", ^{
                [[engage should] receive:@selector(appLoginWithContactFieldValue:completionBlock:)
                           withArguments:customerId, kw_any()];
                [Emarsys setCustomerWithId:customerId];
            });

            it(@"should delegate the call to mobileEngageInternal with customerId and completionBlock", ^{
                void (^ const completionBlock)(NSError *) = ^(NSError *error) {};

                [[engage should] receive:@selector(appLoginWithContactFieldValue:completionBlock:)
                           withArguments:customerId, completionBlock];

                [Emarsys setCustomerWithId:customerId
                           completionBlock:completionBlock];
            });
        });

        describe(@"clearCustomer", ^{
            it(@"should delegate call to MobileEngage", ^{
                [[engage should] receive:@selector(appLogout)];

                [Emarsys clearCustomer];
            });

            it(@"should delegate call to Predict", ^{
                [[predict should] receive:@selector(clearCustomer)];

                [Emarsys clearCustomer];
            });
        });

        context(@"production setup", ^{

            beforeEach(^{
                EMSConfig *configMock = [EMSConfig nullMock];
                [[configMock should] receive:@selector(merchantId) andReturn:@"merchantId"];
                [Emarsys setupWithConfig:configMock];
            });

            describe(@"push", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.push) shouldNot] beNil];
                });
            });

            describe(@"inbox", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.inbox) shouldNot] beNil];
                });
            });

            describe(@"inApp", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.inApp) shouldNot] beNil];
                });
            });


            describe(@"predict", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.predict) shouldNot] beNil];
                });
            });
        });

SPEC_END
