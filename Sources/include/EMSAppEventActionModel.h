//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSActionModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSAppEventActionModel : NSObject <EMSActionModelProtocol>

@property(nonatomic, readonly) NSString *id;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSString *type;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, id> *payload;

- (instancetype)initWithId:(NSString *)id
                     title:(NSString *)title
                      type:(NSString *)type
                      name:(NSString *)name
                   payload:(nullable NSDictionary<NSString *, id> *)payload;

@end

NS_ASSUME_NONNULL_END