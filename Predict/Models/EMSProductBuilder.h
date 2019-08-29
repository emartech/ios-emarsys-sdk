//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSProductBuilder : NSObject

@property(nonatomic, readonly) NSString *productId;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSURL *linkUrl;
@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *customFields;
@property(nonatomic, readonly) NSString *feature;
@property(nonatomic, readonly) NSString *cohort;
@property(nonatomic, readonly, nullable) NSURL *imageUrl;
@property(nonatomic, readonly, nullable) NSURL *zoomImageUrl;
@property(nonatomic, readonly, nullable) NSString *categoryPath;
@property(nonatomic, readonly, nullable) NSNumber *available;
@property(nonatomic, readonly, nullable) NSString *productDescription;
@property(nonatomic, readonly, nullable) NSNumber *price;
@property(nonatomic, readonly, nullable) NSNumber *msrp;
@property(nonatomic, readonly, nullable) NSString *album;
@property(nonatomic, readonly, nullable) NSString *actor;
@property(nonatomic, readonly, nullable) NSString *artist;
@property(nonatomic, readonly, nullable) NSString *author;
@property(nonatomic, readonly, nullable) NSString *brand;
@property(nonatomic, readonly, nullable) NSNumber *year;

- (instancetype)setRequiredFieldsWithProductId:(NSString *)productId
                                         title:(NSString *)title
                                       linkUrl:(NSURL *)linkUrl
                                       feature:(NSString *)feature
                                        cohort:(NSString *)cohort;

- (instancetype)setCustomFields:(NSDictionary<NSString *, NSString *> *)customFields;

- (instancetype)setImageUrl:(NSURL *)imageUrl;

- (instancetype)setZoomImageUrl:(NSURL *)zoomImageUrl;

- (instancetype)setCategoryPath:(NSString *)categoryPath;

- (instancetype)setAvailable:(NSNumber *)available;

- (instancetype)setProductDescription:(NSString *)productDescription;

- (instancetype)setPrice:(NSNumber *)price;

- (instancetype)setMsrp:(NSNumber *)msrp;

- (instancetype)setAlbum:(NSString *)album;

- (instancetype)setActor:(NSString *)actor;

- (instancetype)setArtist:(NSString *)artist;

- (instancetype)setAuthor:(NSString *)author;

- (instancetype)setBrand:(NSString *)brand;

- (instancetype)setYear:(NSNumber *)year;

@end

NS_ASSUME_NONNULL_END