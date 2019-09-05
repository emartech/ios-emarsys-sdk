//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSResponseModel.h"
#import "EMSProductMapper.h"
#import "EMSProduct.h"
#import "EMSProduct+Emarsys.h"

@interface EMSProductMapperTests : XCTestCase

@end

@implementation EMSProductMapperTests

- (void)testMap_responseModel_mustNotBeNil {
    @try {
        [[EMSProductMapper new] mapFromResponse:nil];
        XCTFail(@"Expected Exception when responseModel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: responseModel");
    }
}

- (void)testMapWithSearch {
    [self assertForProductsWithFeature:@"SEARCH"];
}

- (void)testMapWithCart {
    [self assertForProductsWithFeature:@"CART"];
}

- (void)testMapWithRelated {
    [self assertForProductsWithFeature:@"RELATED"];
}

- (void)testMapWithCategory {
    [self assertForProductsWithFeature:@"CATEGORY"];
}

- (void)testMapWithAlsoBought {
    [self assertForProductsWithFeature:@"ALSO_BOUGHT"];
}

- (void)testMapWithPopular {
    [self assertForProductsWithFeature:@"POPULAR"];
}

- (void)assertForProductsWithFeature:(NSString *)feature {
    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                           headers:@{}
                                                                              body:[self rawResponseDataWithFeature:feature]
                                                                      requestModel:OCMClassMock([EMSRequestModel class])
                                                                         timestamp:[NSDate date]];

    EMSProduct *expectedProduct1 = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
        [builder setRequiredFieldsWithProductId:@"2119"
                                          title:@"LSL Men Polo Shirt SE16"
                                        linkUrl:[[NSURL alloc]
                                            initWithString:@"http://lifestylelabels.com/lsl-men-polo-shirt-se16.html"]
                                        feature:feature
                                         cohort:@"AAAA"];
        [builder setCategoryPath:@"MEN>Shirts"];
        [builder setAvailable:@(YES)];
        [builder setMsrp:@(100.0)];
        [builder setPrice:@(100.0)];
        [builder setImageUrl:[[NSURL alloc] initWithString:@"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg"]];
        [builder setZoomImageUrl:[[NSURL alloc] initWithString:@"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg"]];
        [builder setProductDescription:@"product Description"];
        [builder setAlbum:@"album"];
        [builder setActor:@"actor"];
        [builder setArtist:@"artist"];
        [builder setAuthor:@"author"];
        [builder setBrand:@"brand"];
        [builder setYear:@(2000)];
        [builder setCustomFields:@{@"msrp_gpb": @"83.2",
            @"price_gpb": @"83.2",
            @"msrp_aed": @"100",
            @"price_aed": @"100",
            @"msrp_cad": @"100",
            @"price_cad": @"100",
            @"msrp_mxn": @"2057.44",
            @"price_mxn": @"2057.44",
            @"msrp_pln": @"100",
            @"price_pln": @"100",
            @"msrp_rub": @"100",
            @"price_rub": @"100",
            @"msrp_sek": @"100",
            @"price_sek": @"100",
            @"msrp_try": @"339.95",
            @"price_try": @"339.95",
            @"msrp_usd": @"100",
            @"price_usd": @"100"}];
    }];
    EMSProduct *expectedProduct2 = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
        [builder setRequiredFieldsWithProductId:@"2120"
                                          title:@"LSL Men Polo Shirt LE16"
                                        linkUrl:[[NSURL alloc] initWithString:@"http://lifestylelabels.com/lsl-men-polo-shirt-le16.html"]
                                        feature:feature
                                         cohort:@"AAAA"];
    }];

    NSArray *expectedResult = @[expectedProduct1, expectedProduct2];

    NSArray *returnedResult = [[EMSProductMapper new] mapFromResponse:responseModel];
    XCTAssertEqualObjects(expectedResult, returnedResult);
}

- (NSData *)rawResponseDataWithFeature:(NSString *)feature {
    NSString *rawResponse = @"{\n"
                            "  \"cohort\": \"AAAA\",\n"
                            "  \"visitor\": \"11730071F07F469F\",\n"
                            "  \"session\": \"28ACE5FD314FCC1A\",\n"
                            "  \"features\": {\n"
                            "    \"REPLACE_PLACEHOLDER\": {\n"
                            "      \"hasMore\": true,\n"
                            "      \"merchants\": [\n"
                            "        \"1428C8EE286EC34B\"\n"
                            "      ],\n"
                            "      \"items\": [\n"
                            "        {\n"
                            "          \"id\": \"2119\",\n"
                            "          \"spans\": [\n"
                            "            [\n"
                            "              [\n"
                            "                8,\n"
                            "                12\n"
                            "              ],\n"
                            "              [\n"
                            "                13,\n"
                            "                18\n"
                            "              ]\n"
                            "            ],\n"
                            "            [\n"
                            "              [\n"
                            "                4,\n"
                            "                9\n"
                            "              ]\n"
                            "            ]\n"
                            "          ]\n"
                            "        },\n"
                            "        {\n"
                            "          \"id\": \"2120\",\n"
                            "          \"spans\": [\n"
                            "            [\n"
                            "              [\n"
                            "                8,\n"
                            "                12\n"
                            "              ],\n"
                            "              [\n"
                            "                13,\n"
                            "                18\n"
                            "              ]\n"
                            "            ],\n"
                            "            [\n"
                            "              [\n"
                            "                4,\n"
                            "                9\n"
                            "              ]\n"
                            "            ]\n"
                            "          ]\n"
                            "        }\n"
                            "      ]\n"
                            "    }\n"
                            "  },\n"
                            "  \"products\": {\n"
                            "    \"2119\": {\n"
                            "      \"item\": \"2119\",\n"
                            "      \"category\": \"MEN>Shirts\",\n"
                            "      \"title\": \"LSL Men Polo Shirt SE16\",\n"
                            "      \"available\": true,\n"
                            "      \"msrp\": 100,\n"
                            "      \"price\": 100,\n"
                            "      \"msrp_gpb\": \"83.2\",\n"
                            "      \"price_gpb\": \"83.2\",\n"
                            "      \"msrp_aed\": \"100\",\n"
                            "      \"price_aed\": \"100\",\n"
                            "      \"msrp_cad\": \"100\",\n"
                            "      \"price_cad\": \"100\",\n"
                            "      \"msrp_mxn\": \"2057.44\",\n"
                            "      \"price_mxn\": \"2057.44\",\n"
                            "      \"msrp_pln\": \"100\",\n"
                            "      \"price_pln\": \"100\",\n"
                            "      \"msrp_rub\": \"100\",\n"
                            "      \"price_rub\": \"100\",\n"
                            "      \"msrp_sek\": \"100\",\n"
                            "      \"price_sek\": \"100\",\n"
                            "      \"msrp_try\": \"339.95\",\n"
                            "      \"price_try\": \"339.95\",\n"
                            "      \"msrp_usd\": \"100\",\n"
                            "      \"price_usd\": \"100\",\n"
                            "      \"link\": \"http://lifestylelabels.com/lsl-men-polo-shirt-se16.html\",\n"
                            "      \"image\": \"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg\",\n"
                            "      \"zoom_image\": \"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg\",\n"
                            "      \"description\": \"product Description\",\n"
                            "      \"album\": \"album\",\n"
                            "      \"actor\": \"actor\",\n"
                            "      \"artist\": \"artist\",\n"
                            "      \"author\": \"author\",\n"
                            "      \"brand\": \"brand\",\n"
                            "      \"year\": 2000,\n"
                            "    },\n"
                            "    \"2120\": {\n"
                            "      \"item\": \"2120\",\n"
                            "      \"title\": \"LSL Men Polo Shirt LE16\",\n"
                            "      \"link\": \"http://lifestylelabels.com/lsl-men-polo-shirt-le16.html\",\n"
                            "    }\n"
                            "  }\n"
                            "}";
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[rawResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
    NSMutableDictionary *mutableResponseDict = [responseDict mutableCopy];
    NSMutableDictionary *mutableFeaturesDict = [mutableResponseDict[@"features"] mutableCopy];
    mutableFeaturesDict[feature] = mutableFeaturesDict[@"REPLACE_PLACEHOLDER"];
    mutableFeaturesDict[@"REPLACE_PLACEHOLDER"] = nil;
    mutableResponseDict[@"features"] = mutableFeaturesDict;
    return [NSJSONSerialization dataWithJSONObject:mutableResponseDict
                                           options:NSJSONWritingPrettyPrinted
                                             error:nil];
}

@end