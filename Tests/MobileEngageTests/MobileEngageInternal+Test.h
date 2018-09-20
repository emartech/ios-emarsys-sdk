//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"
#import "MobileEngageInternal.h"

@interface MobileEngageInternal (Test)
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;
@end