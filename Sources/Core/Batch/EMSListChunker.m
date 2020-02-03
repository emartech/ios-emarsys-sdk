//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSListChunker.h"

@interface EMSListChunker ()
@property(nonatomic, assign) int chunkSize;
@end

@implementation EMSListChunker

- (instancetype)initWithChunkSize:(int)size {
    NSParameterAssert(size > 0);
    if (self = [super init]) {
        _chunkSize = size;
    }
    return self;
}

- (NSArray<NSArray *> *)chunk:(NSArray *)array {
    NSParameterAssert(array);
    NSMutableArray *result = [@[] mutableCopy];
    NSUInteger size = [array count];
    if (size != 0) {
        for (NSUInteger chunkStartIndex = 0; chunkStartIndex < size; chunkStartIndex += self.chunkSize) {
            NSUInteger length = chunkStartIndex + self.chunkSize < size ? self.chunkSize : size - chunkStartIndex;
            [result addObject:[array subarrayWithRange:NSMakeRange(chunkStartIndex, length)]];
        }
    }
    return [NSArray arrayWithArray:result];
}

@end