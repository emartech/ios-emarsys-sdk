//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSDismissActionModel.h"

@implementation EMSDismissActionModel

- (instancetype)initWithId:(NSString *)id
                     title:(NSString *)title
                      type:(NSString *)type {
    NSParameterAssert(id);
    NSParameterAssert(title);
    NSParameterAssert(type);
    if (self = [super init]) {
        _id = id;
        _title = title;
        _type = type;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToDismiss:other];
}

- (BOOL)isEqualToDismiss:(EMSDismissActionModel *)dismiss {
    if (self == dismiss)
        return YES;
    if (dismiss == nil)
        return NO;
    if (self.id != dismiss.id && ![self.id isEqualToString:dismiss.id])
        return NO;
    if (self.title != dismiss.title && ![self.title isEqualToString:dismiss.title])
        return NO;
    if (self.type != dismiss.type && ![self.type isEqualToString:dismiss.type])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [self.title hash];
    hash = hash * 31u + [self.type hash];
    return hash;
}

@end