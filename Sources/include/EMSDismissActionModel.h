//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSActionModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSDismissActionModel : NSObject<EMSActionModelProtocol>

@property(nonatomic, readonly) NSString *id;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSString *type;

- (instancetype)initWithId:(NSString *)id
                     title:(NSString *)title
                      type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END