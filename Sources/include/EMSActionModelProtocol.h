//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMSActionModelProtocol <NSObject>

- (NSString *)id;
- (NSString *)title;
- (NSString *)type;

@end

NS_ASSUME_NONNULL_END