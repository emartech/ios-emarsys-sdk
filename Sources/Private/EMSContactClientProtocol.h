//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSContactClientProtocol <NSObject>

- (void)setAuthenticatedContactWithContactFieldId:(nullable NSNumber *)contactFieldId
                                      openIdToken:(nullable NSString *)openIdToken
                                  completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)setContactWithContactFieldId:(nullable NSNumber *)contactFieldId
                   contactFieldValue:(nullable NSString *)contactFieldValue;

- (void)setContactWithContactFieldId:(nullable NSNumber *)contactFieldId
                   contactFieldValue:(nullable NSString *)contactFieldValue
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)clearContact;

- (void)clearContactWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
