//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRESTClientCompletionProxyFactory.h"
#import "EMSCoreCompletionHandler.h"
#import "EMSCoreCompletionHandlerMiddleware.h"

@interface EMSRESTClientCompletionProxyFactoryTests : XCTestCase

@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> mockRequestRepository;
@property(nonatomic, strong) NSOperationQueue *mockOperationQueue;
@property(nonatomic, strong) CoreSuccessBlock defaultSuccessBlock;
@property(nonatomic, strong) CoreErrorBlock defaultErrorBlock;
@property(nonatomic, strong) id <EMSWorkerProtocol> mockWorker;
@property(nonatomic, strong) EMSRESTClientCompletionProxyFactory *factory;

@end

@implementation EMSRESTClientCompletionProxyFactoryTests

- (void)setUp {
    _mockRequestRepository = OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol));
    _mockOperationQueue = OCMClassMock([NSOperationQueue class]);
    _defaultSuccessBlock = ^(NSString *requestId, EMSResponseModel *response) {
    };
    _defaultErrorBlock = ^(NSString *requestId, NSError *error) {
    };
    _mockWorker = OCMProtocolMock(@protocol(EMSWorkerProtocol));

    _factory = [[EMSRESTClientCompletionProxyFactory alloc] initWithRequestRepository:self.mockRequestRepository
                                                                       operationQueue:self.mockOperationQueue
                                                                  defaultSuccessBlock:self.defaultSuccessBlock
                                                                    defaultErrorBlock:self.defaultErrorBlock];
}

- (void)testInit_shouldNotAccept_nilRequestRepository {
    @try {
        [[EMSRESTClientCompletionProxyFactory alloc] initWithRequestRepository:nil
                                                                operationQueue:OCMClassMock([NSOperationQueue class])
                                                           defaultSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                           }
                                                             defaultErrorBlock:^(NSString *requestId, NSError *error) {
                                                             }];
        XCTFail(@"Expected Exception when requestRepository is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestRepository");
    }
}

- (void)testInit_shouldNotAccept_nilOperationQueue {
    @try {
        [[EMSRESTClientCompletionProxyFactory alloc] initWithRequestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                                operationQueue:nil
                                                           defaultSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                           }
                                                             defaultErrorBlock:^(NSString *requestId, NSError *error) {
                                                             }];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testInit_shouldNotAccept_nilDefaultSuccessBlock {
    @try {
        [[EMSRESTClientCompletionProxyFactory alloc] initWithRequestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                                operationQueue:OCMClassMock([NSOperationQueue class])
                                                           defaultSuccessBlock:nil
                                                             defaultErrorBlock:^(NSString *requestId, NSError *error) {
                                                             }];
        XCTFail(@"Expected Exception when defaultSuccessBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: defaultSuccessBlock");
    }
}

- (void)testInit_shouldNotAccept_nilDefaultErrorBlock {
    @try {
        [[EMSRESTClientCompletionProxyFactory alloc] initWithRequestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                                operationQueue:OCMClassMock([NSOperationQueue class])
                                                           defaultSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                           }
                                                             defaultErrorBlock:nil];
        XCTFail(@"Expected Exception when defaultErrorBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: defaultErrorBlock");
    }
}

- (void)testCreate_shouldNotAccept_nilSuccessBlock_when_errorBlockIsNotNil {
    @try {
        [self.factory createWithWorker:nil
                          successBlock:nil
                            errorBlock:^(NSString *requestId, NSError *error) {
                            }];
        XCTFail(@"Expected Exception when successBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: (successBlock != nil) == (errorBlock != nil)");
    }
}

- (void)testCreate_shouldNotAccept_nilErrorBlock_when_successBlockIsNotNil {
    @try {
        [self.factory createWithWorker:nil
                          successBlock:^(NSString *requestId, EMSResponseModel *response) {
                          }
                            errorBlock:nil];
        XCTFail(@"Expected Exception when successBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: (successBlock != nil) == (errorBlock != nil)");
    }
}

- (void)testCreate_shouldReturn_CoreCompletionHandlerInstance_with_defaultSuccessAndErrorBlock {
    id <EMSRESTClientCompletionProxyProtocol> returnedProxy = [self.factory createWithWorker:nil
                                                                                successBlock:nil
                                                                                  errorBlock:nil];

    EMSCoreCompletionHandler *completionHandler = (EMSCoreCompletionHandler *) returnedProxy;

    XCTAssertEqualObjects([returnedProxy class], [EMSCoreCompletionHandler class]);
    XCTAssertEqualObjects(completionHandler.successBlock, self.defaultSuccessBlock);
    XCTAssertEqualObjects(completionHandler.errorBlock, self.defaultErrorBlock);
}

- (void)testCreate_shouldReturn_CoreCompletionHandlerInstance_with_SuccessAndErrorBlock {
    CoreSuccessBlock successBlock = ^(NSString *requestId, EMSResponseModel *response) {
    };
    CoreErrorBlock errorBlock = ^(NSString *requestId, NSError *error) {
    };

    id <EMSRESTClientCompletionProxyProtocol> returnedProxy = [self.factory createWithWorker:nil
                                                                                successBlock:successBlock
                                                                                  errorBlock:errorBlock];

    EMSCoreCompletionHandler *completionHandler = (EMSCoreCompletionHandler *) returnedProxy;

    XCTAssertEqualObjects([returnedProxy class], [EMSCoreCompletionHandler class]);
    XCTAssertEqualObjects(completionHandler.successBlock, successBlock);
    XCTAssertEqualObjects(completionHandler.errorBlock, errorBlock);
}

- (void)testCreate_shouldReturn_CoreCompletionHandlerMiddlewareInstance_with_defaultSuccessAndErrorBlocks {
    id <EMSRESTClientCompletionProxyProtocol> returnedProxy = [self.factory createWithWorker:self.mockWorker
                                                                                successBlock:nil
                                                                                  errorBlock:nil];

    EMSCoreCompletionHandlerMiddleware *completionHandlerMiddleware = (EMSCoreCompletionHandlerMiddleware *) returnedProxy;

    XCTAssertEqualObjects([returnedProxy class], [EMSCoreCompletionHandlerMiddleware class]);
    XCTAssertEqualObjects([completionHandlerMiddleware.completionHandler class], [EMSCoreCompletionHandler class]);

    EMSCoreCompletionHandler *completionHandler = (EMSCoreCompletionHandler *) completionHandlerMiddleware.completionHandler;

    XCTAssertEqualObjects(completionHandler.successBlock, self.defaultSuccessBlock);
    XCTAssertEqualObjects(completionHandler.errorBlock, self.defaultErrorBlock);
}

- (void)testCreate_shouldReturn_CoreCompletionHandlerMiddlewareInstance_with_successAndErrorBlocks {
    CoreSuccessBlock successBlock = ^(NSString *requestId, EMSResponseModel *response) {
    };
    CoreErrorBlock errorBlock = ^(NSString *requestId, NSError *error) {
    };

    id <EMSRESTClientCompletionProxyProtocol> returnedProxy = [self.factory createWithWorker:self.mockWorker
                                                                                successBlock:successBlock
                                                                                  errorBlock:errorBlock];

    EMSCoreCompletionHandlerMiddleware *completionHandlerMiddleware = (EMSCoreCompletionHandlerMiddleware *) returnedProxy;

    XCTAssertEqualObjects([returnedProxy class], [EMSCoreCompletionHandlerMiddleware class]);
    XCTAssertEqualObjects([completionHandlerMiddleware.completionHandler class], [EMSCoreCompletionHandler class]);

    EMSCoreCompletionHandler *completionHandler = (EMSCoreCompletionHandler *) completionHandlerMiddleware.completionHandler;

    XCTAssertEqualObjects(completionHandler.successBlock, successBlock);
    XCTAssertEqualObjects(completionHandler.errorBlock, errorBlock);
}

@end
