//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"
#import "MEIAMProtocol.h"
#import "MEInAppMessage.h"

@class MEButtonClickRepository;

@interface MEIAMJSCommandFactory : NSObject

@property(readonly, nonatomic, weak) id <MEIAMProtocol> meIam;
@property(nonatomic, readonly) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, readonly) EMSEventHandlerBlock appEventHandlerBlock;
@property(nonatomic, readonly) id <EMSIAMCloseProtocol> closeProtocol;
@property(nonatomic, strong) MEInAppMessage *inAppMessage;

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meIam
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
        appEventHandlerBlock:(EMSEventHandlerBlock)appEventHandlerBlock
                closeProtocol:(id <EMSIAMCloseProtocol>)closeProtocol;

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name;

@end