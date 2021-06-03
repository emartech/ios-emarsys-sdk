//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSOpenExternalUrlActionModel.h"

@implementation EMSOpenExternalUrlActionModel

- (instancetype)initWithId:(NSString *)id
                     title:(NSString *)title
                      type:(NSString *)type
                       url:(NSURL *)url {
    NSParameterAssert(id);
    NSParameterAssert(title);
    NSParameterAssert(type);
    NSParameterAssert(url);
    if (self = [super init]) {
        _id = id;
        _title = title;
        _type = type;
        _url = url;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToUrl:other];
}

- (BOOL)isEqualToUrl:(EMSOpenExternalUrlActionModel *)url {
    if (self == url)
        return YES;
    if (url == nil)
        return NO;
    if (self.id != url.id && ![self.id isEqualToString:url.id])
        return NO;
    if (self.title != url.title && ![self.title isEqualToString:url.title])
        return NO;
    if (self.type != url.type && ![self.type isEqualToString:url.type])
        return NO;
    if (self.url != url.url && ![self.url isEqual:url.url])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [self.title hash];
    hash = hash * 31u + [self.type hash];
    hash = hash * 31u + [self.url hash];
    return hash;
}

@end