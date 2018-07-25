//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (EMSCore)

+ (NSError *)errorWithCode:(int)errorCode
      localizedDescription:(NSString *)localizedDescription;

@end

NS_ASSUME_NONNULL_END