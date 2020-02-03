//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSCartItem.h"


@implementation EMSCartItem {

}

- (instancetype)initWithItemId:(NSString *)itemId price:(double)price quantity:(double)quantity {
    self = [super init];
    if (self) {
        self.itemId = itemId;
        self.price = price;
        self.quantity = quantity;
    }

    return self;
}

+ (instancetype)itemWithItemId:(NSString *)itemId price:(double)price quantity:(double)quantity {
    return [[self alloc] initWithItemId:itemId price:price quantity:quantity];
}


@end