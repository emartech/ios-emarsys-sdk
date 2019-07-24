//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSMutableDictionary+EMSCore.h"

@interface NSMutableDicitionary_EMSCoreTests : XCTestCase

@end

@implementation NSMutableDicitionary_EMSCoreTests

- (void)testTakeValueForKey {
    NSMutableDictionary *originalDictionary = [@{
            @"key1": @"value1",
            @"key2": @[@"a", @"b", @"c"],
            @"key3": @{
                    @"innerKey1": @"innerValue1",
                    @"innerKey2": @"innerValue2"
            },
            @"key4": @"value4"
    } mutableCopy];
    NSDictionary *expectedDictionary = @{
            @"key2": @[@"a", @"b", @"c"],
            @"key3": @{
                    @"innerKey1": @"innerValue1",
                    @"innerKey2": @"innerValue2"
            }
    };
    NSString *expectedValue1 = @"value1";
    NSString *expectedValue2 = @"value4";

    NSString *returnedValue1 = [originalDictionary takeValueForKey:@"key1"];
    NSString *returnedValue2 = [originalDictionary takeValueForKey:@"key4"];
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithDictionary:originalDictionary];

    XCTAssertEqualObjects(returnedValue1, expectedValue1);
    XCTAssertEqualObjects(returnedValue2, expectedValue2);
    XCTAssertEqualObjects(resultDictionary, expectedDictionary);
}

@end
