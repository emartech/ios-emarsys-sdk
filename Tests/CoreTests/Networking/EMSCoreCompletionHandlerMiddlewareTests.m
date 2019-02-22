//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSCoreCompletionHandlerMiddleware.h"
#import "EMSWorkerProtocol.h"
#import "EMSRequestModelRepositoryProtocol.h"

@interface EMSCoreCompletionHandlerMiddlewareTests : XCTestCase

@end

@implementation EMSCoreCompletionHandlerMiddlewareTests

- (void)setUp {
}

- (void)testInit_completionHandler_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:nil
                                                                           worker:OCMProtocolMock(@protocol(EMSWorkerProtocol))
                                                                requestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                                   operationQueue:OCMClassMock([NSOperationQueue class])];
        XCTFail(@"Expected Exception when completionHandler is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: completionHandler");
    }
}

- (void)testInit_worker_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol))
                                                                           worker:nil
                                                                requestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                                   operationQueue:OCMClassMock([NSOperationQueue class])];
        XCTFail(@"Expected Exception when worker is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: worker");
    }
}

- (void)testInit_requestRepository_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol))
                                                                           worker:OCMProtocolMock(@protocol(EMSWorkerProtocol))
                                                                requestRepository:nil
                                                                   operationQueue:OCMClassMock([NSOperationQueue class])];
        XCTFail(@"Expected Exception when requestRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestRepository");
    }
}

- (void)testInit_operationQueue_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandlerMiddleware alloc] initWithCoreCompletionHandler:OCMProtocolMock(@protocol(EMSRESTClientCompletionProxyProtocol))
                                                                           worker:OCMProtocolMock(@protocol(EMSWorkerProtocol))
                                                                requestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                                   operationQueue:nil];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testSuccess_should {

}


@end
