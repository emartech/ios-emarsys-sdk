//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSProductMapper.h"
#import "EMSProduct.h"
#import "EMSProduct+Emarsys.h"
#import "EMSResponseModel.h"
#import "NSMutableDictionary+EMSCore.h"

@implementation EMSProductMapper

- (NSArray<EMSProduct *> *)mapFromResponse:(EMSResponseModel *)responseModel {
    NSParameterAssert(responseModel);

    NSDictionary *responseData = [responseModel parsedBody];
    NSMutableArray *products = [NSMutableArray new];
    for (NSString *featureName in ((NSDictionary *) responseData[@"features"]).allKeys) {
        for (NSDictionary *item in responseData[@"features"][featureName][@"items"]) {
            NSString *key = item[@"id"];
            NSMutableDictionary *productData = [responseData[@"products"][key] mutableCopy];
            EMSProduct *product = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
                [builder setRequiredFieldsWithProductId:[productData takeValueForKey:@"item"]
                                                  title:[productData takeValueForKey:@"title"]
                                                linkUrl:[[NSURL alloc] initWithString:[productData takeValueForKey:@"link"]]
                                                feature:featureName
                                                 cohort:responseData[@"cohort"]];

                [builder setCategoryPath:[productData takeValueForKey:@"category"]];
                [builder setAvailable:[productData takeValueForKey:@"available"]];
                [builder setMsrp:[productData takeValueForKey:@"msrp"]];
                [builder setPrice:[productData takeValueForKey:@"price"]];

                NSString *imageUrl = [productData takeValueForKey:@"image"];
                [builder setImageUrl:imageUrl ? [[NSURL alloc] initWithString:imageUrl] : nil];

                NSString *zoomImageUrl = [productData takeValueForKey:@"zoom_image"];
                [builder setZoomImageUrl:zoomImageUrl ? [[NSURL alloc] initWithString:zoomImageUrl] : nil];

                [builder setProductDescription:[productData takeValueForKey:@"description"]];
                [builder setAlbum:[productData takeValueForKey:@"album"]];
                [builder setActor:[productData takeValueForKey:@"actor"]];
                [builder setArtist:[productData takeValueForKey:@"artist"]];
                [builder setAuthor:[productData takeValueForKey:@"author"]];
                [builder setBrand:[productData takeValueForKey:@"brand"]];
                [builder setYear:[productData takeValueForKey:@"year"]];
                [builder setCustomFields:[NSDictionary dictionaryWithDictionary:productData]];
            }];
            [products addObject:product];
        }
    }
    return products;
}

@end