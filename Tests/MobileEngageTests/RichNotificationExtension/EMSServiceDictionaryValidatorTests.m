//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "EMSServiceDictionaryValidator.h"

SPEC_BEGIN(EMSServiceDictionaryValidatorTests)

        describe(@"initWithDictionary:", ^{

            it(@"should set the parameter", ^{
                id dictMock = [NSDictionary mock];
                EMSServiceDictionaryValidator *validator = [[EMSServiceDictionaryValidator alloc] initWithDictionary:dictMock];
                [[validator.dictionary should] equal:dictMock];
            });


            it(@"validate category method on NSDictionary should create a validate:: with the correct dictionary", ^{
                NSDictionary *dict = @{};

                [dict validate:^(EMSServiceDictionaryValidator *validate) {
                    [[validate.dictionary should] equal:dict];
                }];
            });

        });

        describe(@"validate", ^{

            __block NSDictionary *emptyDictionary;
            __block NSDictionary *dictionary;

            beforeEach(^{
                emptyDictionary = @{};
                dictionary = @{@"someKey": @"someValue"};
            });

            it(@"should return true if no validation rules are set", ^{
                NSArray *failureReasons = [emptyDictionary validate:^(EMSServiceDictionaryValidator *validate) {
                }];

                [[failureReasons should] beEmpty];
            });

            context(@"valueExistsForKey:withType:", ^{

                it(@"should pass validation when called with nil key parameter", ^{
                    NSArray *failureReasons = [emptyDictionary validate:^(EMSServiceDictionaryValidator *validate) {
                        [validate valueExistsForKey:nil withType:[NSString class]];
                    }];

                    [[failureReasons should] beEmpty];
                });

                it(@"should pass validation when there is such key with nil type parameter", ^{
                    NSArray *failureReasons = [dictionary validate:^(EMSServiceDictionaryValidator *validate) {
                        [validate valueExistsForKey:@"someKey" withType:nil];
                    }];

                    [[failureReasons should] beEmpty];
                });

                it(@"should pass validation when there is such key in the dictionary with the correct type.", ^{
                    NSArray *failureReasons = [dictionary validate:^(EMSServiceDictionaryValidator *validate) {
                        [validate valueExistsForKey:@"someKey" withType:[NSString class]];
                    }];

                    [[failureReasons should] beEmpty];
                });

                it(@"should fail validation with failure reason when there is no such key in the dictionary and type is not specified", ^{
                    NSArray *failureReasons = [emptyDictionary validate:^(EMSServiceDictionaryValidator *validate) {
                        [validate valueExistsForKey:@"missingKey" withType:nil];
                    }];

                    [[theValue([failureReasons count]) should] equal:@1];
                    [[[failureReasons firstObject] should] equal:@"Missing 'missingKey' key."];
                });

                it(@"should fail validation with failure reason when there is no such key in the dictionary with the specified type", ^{
                    NSArray *failureReasons = [emptyDictionary validate:^(EMSServiceDictionaryValidator *validate) {
                        [validate valueExistsForKey:@"missingKey" withType:[NSArray class]];
                    }];

                    [[theValue([failureReasons count]) should] equal:@1];
                    NSString *arrayTypeName = NSStringFromClass([NSArray class]);
                    NSString *error = [NSString stringWithFormat:@"Missing 'missingKey' key with type: %@.",
                                                                 arrayTypeName];
                    [[[failureReasons firstObject] should] equal:error];
                });

                it(@"should fail validation with failure reason when there is such key in the dictionary with different type", ^{
                    NSArray *failureReasons = [dictionary validate:^(EMSServiceDictionaryValidator *validate) {
                        [validate valueExistsForKey:@"someKey" withType:[NSArray class]];
                    }];

                    [[theValue([failureReasons count]) should] equal:@1];
                    NSString *arrayTypeName = NSStringFromClass([NSArray class]);
                    NSString *valueTypeName = NSStringFromClass([dictionary[@"someKey"] class]);
                    NSString *error = [NSString stringWithFormat:@"Type mismatch for key 'someKey', expected type: %@, but was: %@.",
                                                                 arrayTypeName,
                                                                 valueTypeName];
                    [[[failureReasons firstObject] should] equal:error];
                });

                it(@"should fail validation with failure reason when there is such key in the dictionary with other different type", ^{
                    NSArray *failureReasons = [@{@"someKey": @{}} validate:^(EMSServiceDictionaryValidator *validate) {
                        [validate valueExistsForKey:@"someKey" withType:[NSArray class]];
                    }];

                    [[theValue([failureReasons count]) should] equal:@1];
                    NSString *arrayTypeName = NSStringFromClass([NSArray class]);
                    NSString *stringTypeName = NSStringFromClass([@{} class]);
                    NSString *error = [NSString stringWithFormat:@"Type mismatch for key 'someKey', expected type: %@, but was: %@.",
                                                                 arrayTypeName,
                                                                 stringTypeName];
                    [[[failureReasons firstObject] should] equal:error];
                });

                it(@"should fail validation with multiple failure reasons", ^{
                    NSString *arrayTypeName = NSStringFromClass([NSArray class]);
                    NSString *valueTypeName = NSStringFromClass([dictionary[@"someKey"] class]);
                    NSArray *failureReasons = [dictionary validate:^(EMSServiceDictionaryValidator *validate) {
                        [validate valueExistsForKey:@"missingKey" withType:nil];
                        [validate valueExistsForKey:@"missingKey2" withType:[NSArray class]];
                        [validate valueExistsForKey:@"someKey" withType:[NSArray class]];
                    }];

                    [[theValue([failureReasons count]) should] equal:@3];
                    [[failureReasons[0] should] equal:@"Missing 'missingKey' key."];
                    [[failureReasons[1] should] equal:[NSString stringWithFormat:@"Missing 'missingKey2' key with type: %@.",
                                                                                 arrayTypeName]];
                    [[failureReasons[2] should] equal:[NSString stringWithFormat:@"Type mismatch for key 'someKey', expected type: %@, but was: %@.",
                                                                                 arrayTypeName,
                                                                                 valueTypeName]];
                });

            });

        });


SPEC_END
