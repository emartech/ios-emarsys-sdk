//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"
#import "MEIAMProtocol.h"

@class MEButtonClickRepository;

@interface MEIAMJSCommandFactory : NSObject

@property(readonly, nonatomic, weak) id <MEIAMProtocol> meIam;
@property(nonatomic, readonly) MEButtonClickRepository *buttonClickRepository;

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meIam
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository;

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name;

@end