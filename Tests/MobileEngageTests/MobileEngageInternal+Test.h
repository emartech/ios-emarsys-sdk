//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractResponseHandler.h"
#import "MobileEngageInternal.h"

@interface MobileEngageInternal (Test)
@property(nonatomic, strong) NSArray<AbstractResponseHandler *> *responseHandlers;
@end