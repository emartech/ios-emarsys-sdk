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

@interface Emarsys ()
+ (void)setPredict:(PredictInternal *)predictInternal;

+ (void)setMobileEngage:(MobileEngageInternal *)mobileEngage;
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
                [Emarsys setPredict:predict];
                [Emarsys setMobileEngage:engage];

                [[predict should] receive:@selector(setCustomerWithId:) withArguments:customerId];
                [Emarsys setCustomerWithId:customerId];
            });

            it(@"should delegate the call to mobileEngageInternal", ^{
                PredictInternal *const predict = [PredictInternal nullMock];
                MobileEngageInternal *const engage = [MobileEngageInternal mock];
                NSString *const customerId = @"customerId";
                [Emarsys setPredict:predict];
                [Emarsys setMobileEngage:engage];

                [[engage should] receive:@selector(appLoginWithContactFieldId:contactFieldValue:) withArguments:kw_any(), customerId];
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
                [Emarsys setPredict:predict];
                [Emarsys setMobileEngage:engage];

                [[engage should] receive:@selector(appLoginWithContactFieldId:contactFieldValue:) withArguments:@32, customerId];
                [Emarsys setCustomerWithId:customerId];
            });
        });

SPEC_END
