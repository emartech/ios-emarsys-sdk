//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSMobileEngageProtocol <NSObject>

- (void)setAnonymousContact;

- (void)setAnonymousContactWithCompletionBlock:(EMSCompletionBlock)completionBlock;

- (void)setContactWithContactFieldValue:(NSString *)contactFieldValue;

- (void)setContactWithContactFieldValue:(NSString *)contactFieldValue
                        completionBlock:(EMSCompletionBlock)completionBlock;

- (void)clearContact;

- (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock;

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes;

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(EMSCompletionBlock)completionBlock;

@end