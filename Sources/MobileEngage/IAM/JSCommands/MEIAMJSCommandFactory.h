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
@property(nonatomic, readonly) id <EMSIAMAppEventProtocol> appEventProtocol;
@property(nonatomic, readonly) id <EMSIAMCloseProtocol> closeProtocol;

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meIam
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
             appEventProtocol:(id <EMSIAMAppEventProtocol>)appEventProtocol
                closeProtocol:(id <EMSIAMCloseProtocol>)closeProtocol;

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name;

@end