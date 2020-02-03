//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSProduct.h"
#import "EMSProduct+Emarsys.h"

@implementation EMSProduct

+ (instancetype)makeWithBuilder:(EMSProductBuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    EMSProductBuilder *builder = [EMSProductBuilder new];
    builderBlock(builder);
    return [[EMSProduct alloc] initWithProductId:builder.productId
                                           title:builder.title
                                         linkUrl:builder.linkUrl
                                         feature:builder.feature
                                          cohort:builder.cohort
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
                          feature:(NSString *)feature
                           cohort:(NSString *)cohort
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
    NSParameterAssert(feature);
    NSParameterAssert(cohort);
    NSParameterAssert(customFields);
    if (self = [super init]) {
        _productId = productId;
        _title = title;
        _linkUrl = linkUrl;
        _feature = feature;
        _cohort = cohort;
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

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.productId=%@", self.productId];
    [description appendFormat:@", self.title=%@", self.title];
    [description appendFormat:@", self.linkUrl=%@", self.linkUrl];
    [description appendFormat:@", self.customFields=%@", self.customFields];
    [description appendFormat:@", self.feature=%@", self.feature];
    [description appendFormat:@", self.cohort=%@", self.cohort];
    [description appendFormat:@", self.imageUrl=%@", self.imageUrl];
    [description appendFormat:@", self.zoomImageUrl=%@", self.zoomImageUrl];
    [description appendFormat:@", self.categoryPath=%@", self.categoryPath];
    [description appendFormat:@", self.available=%@", self.available];
    [description appendFormat:@", self.productDescription=%@", self.productDescription];
    [description appendFormat:@", self.price=%@", self.price];
    [description appendFormat:@", self.msrp=%@", self.msrp];
    [description appendFormat:@", self.album=%@", self.album];
    [description appendFormat:@", self.actor=%@", self.actor];
    [description appendFormat:@", self.artist=%@", self.artist];
    [description appendFormat:@", self.author=%@", self.author];
    [description appendFormat:@", self.brand=%@", self.brand];
    [description appendFormat:@", self.year=%@", self.year];
    [description appendString:@">"];
    return description;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToProduct:other];
}

- (BOOL)isEqualToProduct:(EMSProduct *)product {
    if (self == product)
        return YES;
    if (product == nil)
        return NO;
    if (self.productId != product.productId && ![self.productId isEqualToString:product.productId])
        return NO;
    if (self.title != product.title && ![self.title isEqualToString:product.title])
        return NO;
    if (self.linkUrl != product.linkUrl && ![self.linkUrl isEqual:product.linkUrl])
        return NO;
    if (self.customFields != product.customFields && ![self.customFields isEqualToDictionary:product.customFields])
        return NO;
    if (self.feature != product.feature && ![self.feature isEqualToString:product.feature])
        return NO;
    if (self.cohort != product.cohort && ![self.cohort isEqualToString:product.cohort])
        return NO;
    if (self.imageUrl != product.imageUrl && ![self.imageUrl isEqual:product.imageUrl])
        return NO;
    if (self.zoomImageUrl != product.zoomImageUrl && ![self.zoomImageUrl isEqual:product.zoomImageUrl])
        return NO;
    if (self.categoryPath != product.categoryPath && ![self.categoryPath isEqualToString:product.categoryPath])
        return NO;
    if (self.available != product.available && ![self.available isEqualToNumber:product.available])
        return NO;
    if (self.productDescription != product.productDescription && ![self.productDescription isEqualToString:product.productDescription])
        return NO;
    if (self.price != product.price && ![self.price isEqualToNumber:product.price])
        return NO;
    if (self.msrp != product.msrp && ![self.msrp isEqualToNumber:product.msrp])
        return NO;
    if (self.album != product.album && ![self.album isEqualToString:product.album])
        return NO;
    if (self.actor != product.actor && ![self.actor isEqualToString:product.actor])
        return NO;
    if (self.artist != product.artist && ![self.artist isEqualToString:product.artist])
        return NO;
    if (self.author != product.author && ![self.author isEqualToString:product.author])
        return NO;
    if (self.brand != product.brand && ![self.brand isEqualToString:product.brand])
        return NO;
    if (self.year != product.year && ![self.year isEqualToNumber:product.year])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.productId hash];
    hash = hash * 31u + [self.title hash];
    hash = hash * 31u + [self.linkUrl hash];
    hash = hash * 31u + [self.customFields hash];
    hash = hash * 31u + [self.feature hash];
    hash = hash * 31u + [self.cohort hash];
    hash = hash * 31u + [self.imageUrl hash];
    hash = hash * 31u + [self.zoomImageUrl hash];
    hash = hash * 31u + [self.categoryPath hash];
    hash = hash * 31u + [self.available hash];
    hash = hash * 31u + [self.productDescription hash];
    hash = hash * 31u + [self.price hash];
    hash = hash * 31u + [self.msrp hash];
    hash = hash * 31u + [self.album hash];
    hash = hash * 31u + [self.actor hash];
    hash = hash * 31u + [self.artist hash];
    hash = hash * 31u + [self.author hash];
    hash = hash * 31u + [self.brand hash];
    hash = hash * 31u + [self.year hash];
    return hash;
}

@end
