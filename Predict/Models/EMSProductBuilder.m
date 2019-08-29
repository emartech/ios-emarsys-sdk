//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSProductBuilder.h"

@implementation EMSProductBuilder

- (instancetype)setRequiredFieldsWithProductId:(NSString *)productId
                                         title:(NSString *)title
                                       linkUrl:(NSURL *)linkUrl
                                       feature:(NSString *)feature
                                        cohort:(NSString *)cohort {
    _productId = productId;
    _title = title;
    _linkUrl = linkUrl;
    _feature = feature;
    _cohort = cohort;
    _customFields = @{};
    return self;
}

- (instancetype)setCustomFields:(NSDictionary<NSString *, NSString *> *)customFields {
    _customFields = customFields;
    return self;
}

- (instancetype)setImageUrl:(NSURL *)imageUrl {
    _imageUrl = imageUrl;
    return self;
}

- (instancetype)setZoomImageUrl:(NSURL *)zoomImageUrl {
    _zoomImageUrl = zoomImageUrl;
    return self;
}

- (instancetype)setCategoryPath:(NSString *)categoryPath {
    _categoryPath = categoryPath;
    return self;
}

- (instancetype)setAvailable:(NSNumber *)available {
    _available = available;
    return self;
}

- (instancetype)setProductDescription:(NSString *)productDescription {
    _productDescription = productDescription;
    return self;
}

- (instancetype)setPrice:(NSNumber *)price {
    _price = price;
    return self;
}

- (instancetype)setMsrp:(NSNumber *)msrp {
    _msrp = msrp;
    return self;
}

- (instancetype)setAlbum:(NSString *)album {
    _album = album;
    return self;
}

- (instancetype)setActor:(NSString *)actor {
    _actor = actor;
    return self;
}

- (instancetype)setArtist:(NSString *)artist {
    _artist = artist;
    return self;
}

- (instancetype)setAuthor:(NSString *)author {
    _author = author;
    return self;
}

- (instancetype)setBrand:(NSString *)brand {
    _brand = brand;
    return self;
}

- (instancetype)setYear:(NSNumber *)year {
    _year = year;
    return self;
}

@end