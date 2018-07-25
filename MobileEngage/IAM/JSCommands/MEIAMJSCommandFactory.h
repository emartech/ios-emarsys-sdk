//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"
#import "MEIAMProtocol.h"


@interface MEIAMJSCommandFactory : NSObject

@property(readonly, nonatomic, weak) id <MEIAMProtocol> meiam;

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meiam;

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name;

@end