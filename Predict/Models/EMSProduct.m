//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSProduct.h"

@implementation EMSProduct

+ (instancetype)makeWithBuilder:(EMSProductBuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    EMSProductBuilder *builder = [EMSProductBuilder new];
    builderBlock(builder);
    return [[EMSProduct alloc] initWithProductId:builder.productId
                                           title:builder.title
                                         linkUrl:builder.linkUrl
                                    customFields:builder.customFields
                                        imageUrl:builder.imageUrl
                                    zoomImageUrl:builder.zoomImageUrl
                                    categoryPath:builder.categoryPath
                                       available:builder.available
                              productDescription:builder.productDescription
                                           price:builder.price
                                            msrp:builder.msrp
                                           album:builder.album
                                           actor:builder.actor
                                          artist:builder.artist
                                          author:builder.author
                                           brand:builder.brand
                                            year:builder.year];
}

- (instancetype)initWithProductId:(NSString *)productId
                            title:(NSString *)title
                          linkUrl:(NSURL *)linkUrl
                     customFields:(NSDictionary<NSString *, NSString *> *)customFields
                         imageUrl:(NSURL *)imageUrl
                     zoomImageUrl:(NSURL *)zoomImageUrl
                     categoryPath:(NSString *)categoryPath
                        available:(NSNumber *)available
               productDescription:(NSString *)productDescription
                            price:(NSNumber *)price
                             msrp:(NSNumber *)msrp
                            album:(NSString *)album
                            actor:(NSString *)actor
                           artist:(NSString *)artist
                           author:(NSString *)author
                            brand:(NSString *)brand
                             year:(NSNumber *)year {
    NSParameterAssert(productId);
    NSParameterAssert(title);
    NSParameterAssert(linkUrl);
    NSParameterAssert(customFields);
    if (self = [super init]) {
        _productId = productId;
        _title = title;
        _linkUrl = linkUrl;
        _customFields = customFields;
        _imageUrl = imageUrl;
        _zoomImageUrl = zoomImageUrl;
        _categoryPath = categoryPath;
        _available = available;
        _productDescription = productDescription;
        _price = price;
        _msrp = msrp;
        _album = album;
        _actor = actor;
        _artist = artist;
        _author = author;
        _brand = brand;
        _year = year;
    }
    return self;
}

@end