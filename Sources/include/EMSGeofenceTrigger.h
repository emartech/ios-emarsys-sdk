//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMSGeofenceTrigger : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, assign) int loiteringDelay;
@property(nonatomic, strong) NSDictionary<NSString *, id> *action;

- (instancetype)initWithId:(NSString *)id
                      type:(NSString *)type
            loiteringDelay:(int)loiteringDelay
                    action:(NSDictionary<NSString *, id> *)action;

@end