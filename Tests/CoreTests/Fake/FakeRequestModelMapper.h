//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestModelMapperProtocol.h"

@interface FakeRequestModelMapper : NSObject <EMSRequestModelMapperProtocol>

@property(nonatomic, strong) EMSRequestModel *returningValue;
@property(nonatomic, strong) EMSRequestModel *inputValue;
@property(nonatomic, assign) BOOL shouldHandle;

- (instancetype)initWithShouldHandle:(BOOL)shouldHandle
                      returningValue:(EMSRequestModel *)returningValue;

@end