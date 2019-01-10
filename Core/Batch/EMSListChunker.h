//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EMSListChunker : NSObject

- (instancetype)initWithChunkSize:(int)size;

- (NSArray<NSArray *> *)chunk:(NSArray *)array;

@end