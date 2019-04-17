//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSMobileEngageProtocol <NSObject>

- (void)setContactWithContactFieldValue:(nullable NSString *)contactFieldValue;

- (void)setContactWithContactFieldValue:(nullable NSString *)contactFieldValue
                        completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)clearContact;

- (void)clearContactWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes;

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
