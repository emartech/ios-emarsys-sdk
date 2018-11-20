//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MERequestModelSelectEventsSpecification.h"
#import "EMSSchemaContract.h"

@implementation MERequestModelSelectEventsSpecification

- (NSString *)selection {
    return [NSString stringWithFormat:@"%@ LIKE ?", REQUEST_COLUMN_NAME_URL];
}

- (NSArray<NSString *> *)selectionArgs {
    return @[@"%%/v3/devices/_%%/events"];
}


@end