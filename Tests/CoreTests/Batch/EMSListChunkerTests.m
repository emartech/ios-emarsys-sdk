//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSListChunker.h"

@interface EMSListChunkerTests : XCTestCase

@property(nonatomic, strong) EMSListChunker *chunker;
@end

@implementation EMSListChunkerTests

- (void)setUp {
    _chunker = [[EMSListChunker alloc] initWithChunkSize:10];
}

- (void)tearDown {
    _chunker = nil;
}

- (void)testInit_shouldThrowException_when_chunkSizeLessThan1 {
    @try {
        [[EMSListChunker alloc] initWithChunkSize:0];
        XCTFail(@"Expected Exception when chunk size is less than 1!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: size > 0"]);
    }
}

- (void)testChunk_shouldNotAccept_nilArray {
    @try {
        [self.chunker chunk:nil];
        XCTFail(@"Expected Exception when array is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: array"]);
    }
}

- (void)testChunk_shouldReturnAnEmptyArray_when_inputArrayIsEmpty {
    NSArray *inputArray = @[];
    NSArray *resultArray = [self.chunker chunk:inputArray];

    XCTAssertNotNil(resultArray);
    XCTAssertTrue([resultArray count] == 0);
}

- (void)testChunk_whenChunkSize_is1 {
    _chunker = [[EMSListChunker alloc] initWithChunkSize:1];

    NSArray *input = @[@1, @2, @3, @4, @5];
    NSArray *expectedResult = @[
        @[@1],
        @[@2],
        @[@3],
        @[@4],
        @[@5]
    ];
    NSArray *result = [self.chunker chunk:input];
    XCTAssertTrue([result isEqualToArray:expectedResult]);
}

- (void)testChunk_whenChunkSize_is3 {
    _chunker = [[EMSListChunker alloc] initWithChunkSize:3];

    NSArray *input = @[@1, @2, @3, @4, @5, @6, @7];
    NSArray *expectedResult = @[
        @[@1, @2, @3],
        @[@4, @5, @6],
        @[@7]
    ];
    NSArray *result = [self.chunker chunk:input];
    XCTAssertTrue([result isEqualToArray:expectedResult]);
}

@end
