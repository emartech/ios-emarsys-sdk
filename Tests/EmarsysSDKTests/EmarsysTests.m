//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "Emarsys.h"
#import "PredictInternal.h"
#import "MobileEngageInternal.h"
#import "Emarsys+Tests.h"
#import "EMSSQLiteHelper.h"
#import "EMSDBTriggerKey.h"
#import "EMSDependencyContainer.h"

@interface Emarsys ()

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer;

@end

SPEC_BEGIN(EmarsysTests)

        beforeEach(^{
            EMSConfig *configMock = [EMSConfig nullMock];
            [[configMock should] receive:@selector(merchantId) andReturn:@"merchantId"];
            [Emarsys setupWithConfig:configMock];
        });

        describe(@"setupWithConfig:", ^{
            it(@"should set predict", ^{
                [[(NSObject *) [Emarsys predict] shouldNot] beNil];
            });

            it(@"should set push", ^{
                [[(NSObject *) [Emarsys push] shouldNot] beNil];
            });

            it(@"register Predict trigger", ^{
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
                PredictInternal *const predict = [PredictInternal mock];
                MobileEngageInternal *const engage = [MobileEngageInternal nullMock];
                NSString *const customerId = @"customerId";

                EMSDependencyContainer *container = [EMSDependencyContainer mock];
                [[container should] receive:@selector(mobileEngage)
                                  andReturn:engage];
                [[container should] receive:@selector(predict)
                                  andReturn:predict];
                [Emarsys setDependencyContainer:container];

                [[predict should] receive:@selector(setCustomerWithId:)
                            withArguments:customerId];
                [Emarsys setCustomerWithId:customerId];
            });

            it(@"should delegate the call to mobileEngageInternal", ^{
                PredictInternal *const predict = [PredictInternal nullMock];
                MobileEngageInternal *const engage = [MobileEngageInternal mock];
                NSString *const customerId = @"customerId";
                EMSDependencyContainer *container = [EMSDependencyContainer nullMock];
                [[container should] receive:@selector(mobileEngage)
                                  andReturn:engage];
                [[container should] receive:@selector(predict)
                                  andReturn:predict];
                [Emarsys setDependencyContainer:container];

                [[engage should] receive:@selector(appLoginWithContactFieldValue:)
                           withArguments:kw_any(),
                                         customerId];
                [Emarsys setCustomerWithId:customerId];
            });

            it(@"should delegate call to MobileEngage with correct customerId", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setContactFieldId:@32];
                    [builder setMobileEngageApplicationCode:@"applicationCode"
                                        applicationPassword:@"applicationPassword"];
                    [builder setMerchantId:@"merchantId"];
                }];
                PredictInternal *const predict = [PredictInternal nullMock];
                MobileEngageInternal *const engage = [MobileEngageInternal mock];
                [Emarsys setupWithConfig:config];

                NSString *const customerId = @"customerId";
                EMSDependencyContainer *container = [EMSDependencyContainer nullMock];
                [[container should] receive:@selector(mobileEngage)
                                  andReturn:engage];
                [[container should] receive:@selector(predict)
                                  andReturn:predict];
                [Emarsys setDependencyContainer:container];

                [[engage should] receive:@selector(appLoginWithContactFieldValue:)
                           withArguments: customerId];
                [Emarsys setCustomerWithId:customerId];
            });
        });

        describe(@"clearCustomer", ^{
            it(@"should delegate call to MobileEngage", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setContactFieldId:@32];
                    [builder setMobileEngageApplicationCode:@"applicationCode"
                                        applicationPassword:@"applicationPassword"];
                    [builder setMerchantId:@"merchantId"];
                }];
                MobileEngageInternal *const engage = [MobileEngageInternal mock];
                [Emarsys setupWithConfig:config];

                EMSDependencyContainer *container = [EMSDependencyContainer nullMock];
                [[container should] receive:@selector(mobileEngage)
                                  andReturn:engage];
                [Emarsys setDependencyContainer:container];

                [[engage should] receive:@selector(appLogout)];

                [Emarsys clearCustomer];
            });

            it(@"should delegate call to Predict", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setContactFieldId:@32];
                    [builder setMobileEngageApplicationCode:@"applicationCode"
                                        applicationPassword:@"applicationPassword"];
                    [builder setMerchantId:@"merchantId"];
                }];
                PredictInternal *const predict = [PredictInternal mock];
                [Emarsys setupWithConfig:config];

                EMSDependencyContainer *container = [EMSDependencyContainer nullMock];
                [[container should] receive:@selector(predict)
                                  andReturn:predict];
                [Emarsys setDependencyContainer:container];

                [[predict should] receive:@selector(clearCustomer)];

                [Emarsys clearCustomer];
            });
        });

SPEC_END
