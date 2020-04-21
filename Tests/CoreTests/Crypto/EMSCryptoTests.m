//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSCrypto.h"

@interface EMSCryptoTests : XCTestCase

@property(nonatomic, strong) EMSCrypto *crypto;

@end

@implementation EMSCryptoTests

- (void)setUp {
    _crypto = [[EMSCrypto alloc] initWithPemFileName:@"public"];
}

- (void)testInit_pemFile_mustNotBeNil {
    @try {
        [[EMSCrypto alloc] initWithPemFileName:nil];
        XCTFail(@"Expected Exception when pemFile is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: pemFile");
    }
}

- (void)testVerifyContentWithSignature {
    NSData *content = [self dataForName:@"EMS11-C3FD3"
                              extension:@"json"];
    NSData *signature = [self dataForName:@"EMS11-C3FD3"
                                extension:@"sig"];

    BOOL verified = [self.crypto verifyContent:content
                                 withSignature:signature];

    XCTAssertTrue(verified);
}

- (void)testVerifyContentWithSignature_whenInvalidContent {
    NSDictionary *contentDict = @{@"key": @"value"};
    NSError *error = nil;
    NSData *content = [NSJSONSerialization dataWithJSONObject:contentDict
                                                      options:NSJSONWritingPrettyPrinted
                                                        error:&error];
    NSData *signature = [self dataForName:@"EMS11-C3FD3"
                                extension:@"sig"];

    BOOL verified = [self.crypto verifyContent:content
                                 withSignature:signature];

    XCTAssertFalse(verified);
}

- (NSData *)dataForName:(NSString *)name
              extension:(NSString *)extension {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:name
                                                                      ofType:extension];
    return [NSData dataWithContentsOfFile:path];
}

@end
