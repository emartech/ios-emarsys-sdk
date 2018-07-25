//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractResponseHandler.h"
#import "MEButtonClickRepository.h"
#import "MEDisplayedIAMRepository.h"

@interface MEIAMCleanupResponseHandler : AbstractResponseHandler

- (instancetype)initWithButtonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                         displayIamRepository:(MEDisplayedIAMRepository *)displayedIAMRepository;

@end