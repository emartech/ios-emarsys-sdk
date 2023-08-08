//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSRepositoryProtocol.h"
#import "EMSActionFactory.h"
#import "EMSTimestampProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSOnEventResponseHandler : EMSAbstractResponseHandler

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                displayedIAMRepository:(id <EMSRepositoryProtocol>)repository
                         actionFactory:(EMSActionFactory *)actionFactory
                     timestampProvider:(EMSTimestampProvider *)timestampProvider;

@end

NS_ASSUME_NONNULL_END
