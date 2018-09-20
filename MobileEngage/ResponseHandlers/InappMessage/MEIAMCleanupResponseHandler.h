//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"
#import "MEButtonClickRepository.h"
#import "MEDisplayedIAMRepository.h"

@interface MEIAMCleanupResponseHandler : EMSAbstractResponseHandler

- (instancetype)initWithButtonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                         displayIamRepository:(MEDisplayedIAMRepository *)displayedIAMRepository;

@end