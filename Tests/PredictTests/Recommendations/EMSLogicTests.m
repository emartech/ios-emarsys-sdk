//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSLogic.h"
#import "EMSCartItem.h"

@interface EMSLogicTests : XCTestCase

@end

@implementation EMSLogicTests

- (void)testSearch {
    EMSLogic *logic = EMSLogic.search;

    XCTAssertEqualObjects(logic.logic, @"SEARCH");
}

- (void)testSearchWithSearchTerm_when_searchTermIsNotNil {
    EMSLogic *logic = [EMSLogic searchWithSearchTerm:@"searchTerm"];

    XCTAssertEqualObjects(logic.logic, @"SEARCH");
    XCTAssertEqualObjects(logic.data, @{@"q": @"searchTerm"});
}

- (void)testSearchWithSearchTerm_when_searchTermIsNil {
    EMSLogic *logic = [EMSLogic searchWithSearchTerm:nil];

    XCTAssertEqualObjects(logic.logic, @"SEARCH");
    XCTAssertEqualObjects(logic.data, @{});
}

- (void)testCart {
    EMSLogic *logic = EMSLogic.cart;

    XCTAssertEqualObjects(logic.logic, @"CART");
}

- (void)testCartWithCartItems_when_cartItemsAreNotNil {
    EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                           price:123
                                                        quantity:1];
    EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                           price:456
                                                        quantity:2];
    NSDictionary *expectedData = @{
        @"cv": @"1",
        @"ca": @"i:cartItemId1,p:123.0,q:1.0|i:cartItemId2,p:456.0,q:2.0"
    };

    EMSLogic *logic = [EMSLogic cartWithCartItems:@[cartItem1, cartItem2]];

    XCTAssertEqualObjects(logic.logic, @"CART");
    XCTAssertEqualObjects(logic.data, expectedData);
}

- (void)testCartWithCartItems_when_cartItemsAreNil {
    EMSLogic *logic = [EMSLogic cartWithCartItems:nil];

    XCTAssertEqualObjects(logic.logic, @"CART");
    XCTAssertEqualObjects(logic.data, @{});
}

- (void)testRelated {
    EMSLogic *logic = EMSLogic.related;

    XCTAssertEqualObjects(logic.logic, @"RELATED");
}

- (void)testRelatedWithViewItemId_when_ViewItemIdIsNotNil {
    EMSLogic *logic = [EMSLogic relatedWithViewItemId:@"testItemId"];

    XCTAssertEqualObjects(logic.logic, @"RELATED");
    XCTAssertEqualObjects(logic.data, @{@"v": @"i:testItemId"});
}

- (void)testRelatedWithViewItemId_when_ViewItemIdIsNil {
    EMSLogic *logic = [EMSLogic relatedWithViewItemId:nil];

    XCTAssertEqualObjects(logic.logic, @"RELATED");
    XCTAssertEqualObjects(logic.data, @{});
}

- (void)testCategory {
    EMSLogic *logic = EMSLogic.category;

    XCTAssertEqualObjects(logic.logic, @"CATEGORY");
}

- (void)testCategoryWithCategoryPath_when_categoryPathIsNil {
    EMSLogic *logic = [EMSLogic categoryWithCategoryPath:nil];

    XCTAssertEqualObjects(logic.logic, @"CATEGORY");
    XCTAssertEqualObjects(logic.data, @{});
}

- (void)testCategoryWithCategoryPath_when_categoryPathIsNotNil {
    EMSLogic *logic = [EMSLogic categoryWithCategoryPath:@"testCategoryPath"];

    XCTAssertEqualObjects(logic.logic, @"CATEGORY");
    XCTAssertEqualObjects(logic.data, @{@"vc": @"testCategoryPath"});
}


- (void)testAlsoBought {
    EMSLogic *logic = EMSLogic.alsoBought;

    XCTAssertEqualObjects(logic.logic, @"ALSO_BOUGHT");
}

- (void)testAlsoBoughtWithViewItemId_when_itemIdIsNil {
    EMSLogic *logic = [EMSLogic alsoBoughtWithViewItemId:nil];

    XCTAssertEqualObjects(logic.logic, @"ALSO_BOUGHT");
    XCTAssertEqualObjects(logic.data, @{});
}

- (void)testAlsoBoughtWithViewItemId_when_itemIdIsNotNil {
    EMSLogic *logic = [EMSLogic alsoBoughtWithViewItemId:@"testItemId"];

    XCTAssertEqualObjects(logic.logic, @"ALSO_BOUGHT");
    XCTAssertEqualObjects(logic.data, @{@"v": @"i:testItemId"});
}

- (void)testPopular {
    EMSLogic *logic = EMSLogic.popular;

    XCTAssertEqualObjects(logic.logic, @"POPULAR");
}

- (void)testPopularWithCategoryPath_when_categoryPathIsNil {
    EMSLogic *logic = [EMSLogic popularWithCategoryPath:nil];

    XCTAssertEqualObjects(logic.logic, @"POPULAR");
    XCTAssertEqualObjects(logic.data, @{});
}

- (void)testPopularWithCategoryPath_when_categoryPathIsNotNil {
    EMSLogic *logic = [EMSLogic popularWithCategoryPath:@"testCategoryPath"];

    XCTAssertEqualObjects(logic.logic, @"POPULAR");
    XCTAssertEqualObjects(logic.data, @{@"vc": @"testCategoryPath"});
}

- (void)testPersonal {
    EMSLogic *logic = EMSLogic.personal;

    XCTAssertEqualObjects(logic.logic, @"PERSONAL");
}

- (void)testPersonal_when_thereAreNoVariants {
    EMSLogic *logic = [EMSLogic personalWithVariants:nil];

    XCTAssertEqualObjects(logic.logic, @"PERSONAL");
    XCTAssertNil(logic.variants);
    XCTAssertNotNil(logic.data);
}

- (void)testPersonal_when_thereAreVariants {
    NSArray *const expectedVariants = @[@"1", @"2", @"3"];

    EMSLogic *logic = [EMSLogic personalWithVariants:@[@"1", @"2", @"3"]];

    XCTAssertEqualObjects(logic.logic, @"PERSONAL");
    XCTAssertEqualObjects(logic.variants, expectedVariants);
    XCTAssertNotNil(logic.data);
}

- (void)testHome {
    EMSLogic *logic = EMSLogic.home;

    XCTAssertEqualObjects(logic.logic, @"HOME");
}

- (void)testHome_when_thereAreNoVariants {
    EMSLogic *logic = [EMSLogic homeWithVariants:nil];

    XCTAssertEqualObjects(logic.logic, @"HOME");
    XCTAssertNil(logic.variants);
    XCTAssertNotNil(logic.data);
}

- (void)testHome_when_thereAreVariants {
    NSArray *const expectedVariants = @[@"1", @"2", @"3"];

    EMSLogic *logic = [EMSLogic homeWithVariants:@[@"1", @"2", @"3"]];

    XCTAssertEqualObjects(logic.logic, @"HOME");
    XCTAssertEqualObjects(logic.variants, expectedVariants);
    XCTAssertNotNil(logic.data);
}

@end