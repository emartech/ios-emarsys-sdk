//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSDBTrigger.h"

@interface EMSDBTriggerKey : NSObject <NSCopying>
@property(nonatomic, readonly) NSString *tableName;
@property(nonatomic, readonly) EMSDBTriggerEvent *triggerEvent;
@property(nonatomic, readonly) EMSDBTriggerType *triggerType;

- (instancetype)initWithTableName:(NSString *)tableName
                        withEvent:(EMSDBTriggerEvent *)triggerEvent
                         withType:(EMSDBTriggerType *)triggerType;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToKey:(EMSDBTriggerKey *)key;

- (NSUInteger)hash;
@end