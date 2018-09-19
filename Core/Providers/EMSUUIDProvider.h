//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EMSUUIDProvider : NSObject

- (NSUUID *)provideUUID;

- (NSString *)provideUUIDString;

@end