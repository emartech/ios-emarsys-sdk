//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "NSError+EMSCore.h"
#import "NSDictionary+EMSCore.h"

SPEC_BEGIN(NSDictionaryCoreTests)

        describe(@"NSDictionary+EMSCore subsetOfDictionary:(NSDictionary *)dictionary", ^{
            NSDictionary *testDictionary = @{
                @"key1": @{
                    @"key2": @"value2",
                    @"key3": @"345678",
                    @"key4": @[@456, @"sf"],
                    @"key5": @{
                        @"subKey1": @"subValue1",
                        @"subKey2": @"subValue2",
                        @"subKey3": [NSError errorWithCode:1555
                                      localizedDescription:@"1555"],
                        @12345: @"subValue4"
                    },
                    @"key6": [NSError errorWithCode:1444
                               localizedDescription:@"1444"],
                    @"key7": [NSNull null]
                },
                @"key8": @23456,
                @"key9": @"value111"
            };

            it(@"should return NO if other dictionary is nil", ^{
                [[@([testDictionary subsetOfDictionary:nil]) should] equal:@(NO)];
            });

            it(@"should return YES if the two dictionary are equal", ^{
                [[@([testDictionary subsetOfDictionary:testDictionary]) should] equal:@(YES)];
            });

            it(@"should return YES if the other dictionary is isEmpty", ^{
                [[@([testDictionary subsetOfDictionary:@{}]) should] equal:@(YES)];
            });

            it(@"should return YES if the other (flat) dictionary is a subset of the dictionary", ^{
                NSDictionary *other = @{
                    @"key8": @23456,
                    @"key9": @"value111"
                };

                [[@([other subsetOfDictionary:testDictionary]) should] equal:@(YES)];
            });
        });

        describe(@"NSDictionary+EMSCore archive - dictionaryWithData", ^{

            it(@"should return with original values of dictionary after archive and dictionaryWithData", ^{
                NSDictionary *testDict = @{
                    @"key1": @"value1",
                    @"key2": @"value2"
                };

                NSData *data = [testDict archive];
                NSDictionary *returnedDict = [NSDictionary dictionaryWithData:data];

                [[testDict should] equal:returnedDict];
            });
        });

        context(@"optValue", ^{
            describe(@"valueForKey:type:", ^{
                it(@"should return with nil, if the value is not string when the expected value type is string", ^{
                    NSDictionary *dict = @{
                        @"nameOfTheKey": @{}
                    };

                    NSString *returnedValue = [dict valueForKey:@"nameOfTheKey"
                                                           type:[NSString class]];

                    [[returnedValue should] beNil];
                });

                it(@"should return with stringValue, if the value is string when the expected value type is string", ^{
                    NSString *expectedStringValue = @"expectedStringValue";
                    NSDictionary *dict = @{
                        @"nameOfTheKey": expectedStringValue
                    };

                    NSString *returnedValue = [dict valueForKey:@"nameOfTheKey"
                                                           type:[NSString class]];

                    [[returnedValue should] equal:expectedStringValue];
                });
            });

            describe(@"stringValueForKey:", ^{
                it(@"should return with nil, if the value is not string when the expected value type is string", ^{
                    NSDictionary *dict = @{
                        @"nameOfTheKey": @{}
                    };

                    NSString *returnedValue = [dict stringValueForKey:@"nameOfTheKey"];

                    [[returnedValue should] beNil];
                });

                it(@"should return with stringValue, if the value is string when the expected value type is string", ^{
                    NSString *expectedStringValue = @"expectedStringValue";
                    NSDictionary *dict = @{
                        @"nameOfTheKey": expectedStringValue
                    };

                    NSString *returnedValue = [dict stringValueForKey:@"nameOfTheKey"];

                    [[returnedValue should] equal:expectedStringValue];
                });
            });

            describe(@"numberValueForKey:", ^{
                it(@"should return with nil, if the value is not number when the expected value type is number", ^{
                    NSDictionary *dict = @{
                        @"nameOfTheKey": @{}
                    };

                    NSNumber *returnedValue = [dict numberValueForKey:@"nameOfTheKey"];

                    [[returnedValue should] beNil];
                });

                it(@"should return with numberValue, if the value is number when the expected value type is number", ^{
                    NSNumber *expectedNumberValue = @3.14;
                    NSDictionary *dict = @{
                        @"nameOfTheKey": expectedNumberValue
                    };

                    NSNumber *returnedValue = [dict numberValueForKey:@"nameOfTheKey"];

                    [[returnedValue should] equal:expectedNumberValue];
                });
            });

            describe(@"dictionaryValueForKey:", ^{
                it(@"should return with nil, if the value is not dictionary when the expected value type is dictionary", ^{
                    NSDictionary *dict = @{
                        @"nameOfTheKey": @12345
                    };

                    NSDictionary *returnedValue = [dict dictionaryValueForKey:@"nameOfTheKey"];

                    [[returnedValue should] beNil];
                });

                it(@"should return with dictionaryValue, if the value is dictionary when the expected value type is dictionary", ^{
                    NSDictionary *expectedDictionaryValue = @{@"expectedKey": @"expectedValue"};
                    NSDictionary *dict = @{
                        @"nameOfTheKey": expectedDictionaryValue
                    };

                    NSDictionary *returnedValue = [dict dictionaryValueForKey:@"nameOfTheKey"];

                    [[returnedValue should] equal:expectedDictionaryValue];
                });
            });

            describe(@"arrayValueForKey:", ^{
                it(@"should return with nil, if the value is not array when the expected value type is array", ^{
                    NSDictionary *dict = @{
                        @"nameOfTheKey": @12345
                    };

                    NSArray *returnedValue = [dict arrayValueForKey:@"nameOfTheKey"];

                    [[returnedValue should] beNil];
                });

                it(@"should return with arrayValue, if the value is array when the expected value type is array", ^{
                    NSArray *expectedArrayValue = @[@"asd", @"dfg"];
                    NSDictionary *dict = @{
                        @"nameOfTheKey": expectedArrayValue
                    };

                    NSArray *returnedValue = [dict arrayValueForKey:@"nameOfTheKey"];

                    [[returnedValue should] equal:expectedArrayValue];
                });
            });
        });

        describe(@"NSDictionary+EMSCore valueForInsensitiveKey:", ^{

            it(@"should return with value", ^{
                NSDictionary *testDict = @{
                    @"KeY1": @"value1",
                    @"key2": @"value2"
                };

                [[[testDict valueForInsensitiveKey:@"key1"] should] equal:@"value1"];
            });
        });

SPEC_END