//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"
#import "MEIAMProtocol.h"
#import "MEInAppMessage.h"

@class MEButtonClickRepository;
@class UIPasteboard;

@interface MEIAMJSCommandFactory : NSObject

@property(readonly, nonatomic, weak) id <MEIAMProtocol> meIam;
@property(nonatomic, readonly) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, readonly) EMSEventHandlerBlock appEventHandlerBlock;
@property(nonatomic, readonly) id <EMSIAMCloseProtocol> closeProtocol;
@property(nonatomic, strong) MEInAppMessage *inAppMessage;
@property(nonatomic, strong) UIPasteboard *pasteboard;

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meIam
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
         appEventHandlerBlock:(EMSEventHandlerBlock)appEventHandlerBlock
                closeProtocol:(id <EMSIAMCloseProtocol>)closeProtocol
                   pasteboard:(UIPasteboard *)pasteboard;

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name;

@end