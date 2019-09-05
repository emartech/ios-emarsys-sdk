//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSProduct.h"
#import "EMSProduct+Emarsys.h"

@interface EMSProductTests : XCTestCase

@end

@implementation EMSProductTests

- (void)testMakeWithBuilder_builderBlock_mustNotBeNil {
    @try {
        [EMSProduct makeWithBuilder:nil];
        XCTFail(@"Expected Exception when builderBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: builderBlock");
    }
}

- (void)testMakeWithBuilder_productId_mustNotBeNil {
    @try {
        [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
            [builder setRequiredFieldsWithProductId:nil
                                              title:@"testTitle"
                                            linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                            feature:@"testFeature"
                                             cohort:@"testCohort"];
        }];
        XCTFail(@"Expected Exception when productId is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: productId");
    }
}

- (void)testMakeWithBuilder_title_mustNotBeNil {
    @try {
        [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
            [builder setRequiredFieldsWithProductId:@"testProductId"
                                              title:nil
                                            linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                            feature:@"testFeature"
                                             cohort:@"testCohort"];
        }];
        XCTFail(@"Expected Exception when title is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: title");
    }
}

- (void)testMakeWithBuilder_linkUrl_mustNotBeNil {
    @try {
        [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
            [builder setRequiredFieldsWithProductId:@"testProductId"
                                              title:@"testTitle"
                                            linkUrl:nil
                                            feature:@"testFeature"
                                             cohort:@"testCohort"];
        }];
        XCTFail(@"Expected Exception when linkUrl is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: linkUrl");
    }
}

- (void)testMakeWithBuilder_feature_mustNotBeNil {
    @try {
        [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
            [builder setRequiredFieldsWithProductId:@"testProductId"
                                              title:@"testTitle"
                                            linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                            feature:nil
                                             cohort:@"testCohort"];
        }];
        XCTFail(@"Expected Exception when feature is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: feature");
    }
}

- (void)testMakeWithBuilder_cohort_mustNotBeNil {
    @try {
        [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
            [builder setRequiredFieldsWithProductId:@"testProductId"
                                              title:@"testTitle"
                                            linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                            feature:@"testFeature"
                                             cohort:nil];
        }];
        XCTFail(@"Expected Exception when cohort is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: cohort");
    }
}

- (void)testMakeWithBuilder_requiredFields {
    EMSProduct *product = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
        [builder setRequiredFieldsWithProductId:@"testProductId"
                                          title:@"testTitle"
                                        linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                        feature:@"testFeature"
                                         cohort:@"testCohort"];
    }];
    XCTAssertEqualObjects(@{}, product.customFields);
    XCTAssertEqualObjects(@"testProductId", product.productId);
    XCTAssertEqualObjects(@"testTitle", product.title);
    XCTAssertEqualObjects([[NSURL alloc] initWithString:@"https://www.emarsys.com"], product.linkUrl);
    XCTAssertEqualObjects(@"testFeature", product.feature);
    XCTAssertEqualObjects(@"testCohort", product.cohort);
}

- (void)testMakeWithBuilder_allFields {
    EMSProduct *product = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
        [builder setRequiredFieldsWithProductId:@"testProductId"
                                          title:@"testTitle"
                                        linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                        feature:@"testFeature"
                                         cohort:@"testCohort"];
        [builder setCustomFields:@{@"key": @"value"}];
        [builder setImageUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com/testImageUrl"]];
        [builder setZoomImageUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com/testZoomImageUrl"]];
        [builder setCategoryPath:@"testCategoryPath"];
        [builder setAvailable:@YES];
        [builder setProductDescription:@"testDescription"];
        [builder setPrice:@1324.34];
        [builder setMsrp:@4235.54];
        [builder setAlbum:@"testAlbum"];
        [builder setActor:@"testActor"];
        [builder setArtist:@"testArtist"];
        [builder setAuthor:@"testAuthor"];
        [builder setBrand:@"testBrand"];
        [builder setYear:@2000];
    }];
    XCTAssertEqualObjects(@"testProductId", product.productId);
    XCTAssertEqualObjects(@"testTitle", product.title);
    XCTAssertEqualObjects([[NSURL alloc] initWithString:@"https://www.emarsys.com"], product.linkUrl);
    XCTAssertEqualObjects(@"testFeature", product.feature);
    XCTAssertEqualObjects(@"testCohort", product.cohort);
    XCTAssertEqualObjects(@{@"key": @"value"}, product.customFields);
    XCTAssertEqualObjects([[NSURL alloc] initWithString:@"https://www.emarsys.com/testImageUrl"], product.imageUrl);
    XCTAssertEqualObjects([[NSURL alloc] initWithString:@"https://www.emarsys.com/testZoomImageUrl"], product.zoomImageUrl);
    XCTAssertEqualObjects(@"testCategoryPath", product.categoryPath);
    XCTAssertEqualObjects(@YES, product.available);
    XCTAssertEqualObjects(@"testDescription", product.productDescription);
    XCTAssertEqualObjects(@1324.34, product.price);
    XCTAssertEqualObjects(@4235.54, product.msrp);
    XCTAssertEqualObjects(@"testAlbum", product.album);
    XCTAssertEqualObjects(@"testActor", product.actor);
    XCTAssertEqualObjects(@"testArtist", product.artist);
    XCTAssertEqualObjects(@"testAuthor", product.author);
    XCTAssertEqualObjects(@"testBrand", product.brand);
    XCTAssertEqualObjects(@2000, product.year);
}

@end