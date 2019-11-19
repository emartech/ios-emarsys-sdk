//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EmarsysSDK/EMSCartItemProtocol.h>

@interface EMSCartItem : NSObject <EMSCartItemProtocol>

@property(nonatomic, strong) NSString *itemId;
@property(nonatomic, assign) double price;
@property(nonatomic, assign) double quantity;

- (instancetype)initWithItemId:(NSString *)itemId price:(double)price quantity:(double)quantity;

+ (instancetype)itemWithItemId:(NSString *)itemId price:(double)price quantity:(double)quantity;


@end
