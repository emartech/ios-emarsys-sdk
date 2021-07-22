//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSPredictInternalProtocol <NSObject>

- (void)setContactWithContactFieldId:(NSNumber *)contactFieldId
                   contactFieldValue:(NSString *)contactFieldValue;

- (void)clearContact;

@end