//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEAppLoginParameters.h"


@implementation MEAppLoginParameters {

}

- (instancetype)initWithContactFieldId:(NSNumber *)contactFieldId contactFieldValue:(NSString *)contactFieldValue {
    self = [super init];
    if (self) {
        self.contactFieldId = contactFieldId;
        self.contactFieldValue = contactFieldValue;
    }

    return self;
}

+ (instancetype)parametersWithContactFieldId:(NSNumber *)contactFieldId contactFieldValue:(NSString *)contactFieldValue {
    return [[self alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
}

@end