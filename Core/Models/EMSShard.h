//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EMSShard : NSObject

@property(nonatomic, readonly) NSString *category;
@property(nonatomic, readonly) NSDate *timestamp;
@property(nonatomic, readonly) NSTimeInterval ttl;
@property(nonatomic, readonly) NSDictionary<NSString *, id> *data;

- (instancetype)initWithCategory:(NSString *)category
                       timestamp:(NSDate *)timestamp
                             ttl:(NSTimeInterval)ttl
                            data:(NSDictionary<NSString *, id> *)data;


@end