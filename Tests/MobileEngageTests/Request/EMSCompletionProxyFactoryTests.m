//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSCompletionProxyFactory.h"
#import "EMSMobileEngageRefreshTokenCompletionProxy.h"
#import "EMSContactTokenResponseHandler.h"
#import "EMSEndpoint.h"

@interface EMSCompletionProxyFactoryTests : XCTestCase

@property(nonatomic, strong) EMSRESTClient *mockRestClient;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSContactTokenResponseHandler *mockContactTokenResponseHandler;

@end

@implementation EMSCompletionProxyFactoryTests

- (void)setUp {
    _mockRestClient = OCMClassMock([EMSRESTClient class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockContactTokenResponseHandler = OCMClassMock([EMSContactTokenResponseHandler class]);
}

- (void)testInit_restClient_mustNotBeNil {
    @try {
        [[EMSCompletionProxyFactory alloc] initWithRequestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                      operationQueue:OCMClassMock([NSOperationQueue class])
                                                 defaultSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                 }
                                                   defaultErrorBlock:^(NSString *requestId, NSError *error) {
                                                   }
                                                          restClient:nil
                                                      requestFactory:self.mockRequestFactory
                                              contactResponseHandler:OCMClassMock([EMSContactTokenResponseHandler class])
                                                            endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when restClient is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: restClient");
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSCompletionProxyFactory alloc] initWithRequestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                      operationQueue:OCMClassMock([NSOperationQueue class])
                                                 defaultSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                 }
                                                   defaultErrorBlock:^(NSString *requestId, NSError *error) {
                                                   }
                                                          restClient:self.mockRestClient
                                                      requestFactory:nil
                                              contactResponseHandler:OCMClassMock([EMSContactTokenResponseHandler class])
                                                            endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_contactResponseHandler_mustNotBeNil {
    @try {
        [[EMSCompletionProxyFactory alloc] initWithRequestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                      operationQueue:OCMClassMock([NSOperationQueue class])
                                                 defaultSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                 }
                                                   defaultErrorBlock:^(NSString *requestId, NSError *error) {
                                                   }
                                                          restClient:self.mockRestClient
                                                      requestFactory:self.mockRequestFactory
                                              contactResponseHandler:nil
                                                            endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when contactResponseHandler is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: contactResponseHandler");
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSCompletionProxyFactory alloc] initWithRequestRepository:OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol))
                                                      operationQueue:OCMClassMock([NSOperationQueue class])
                                                 defaultSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                 }
                                                   defaultErrorBlock:^(NSString *requestId, NSError *error) {
                                                   }
                                                          restClient:self.mockRestClient
                                                      requestFactory:self.mockRequestFactory
                                              contactResponseHandler:OCMClassMock([EMSContactTokenResponseHandler class])
                                                            endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testCreate {
    id <EMSRequestModelRepositoryProtocol> repository = OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol));
    NSOperationQueue *operationQueue = OCMClassMock([NSOperationQueue class]);

    void (^successBlock)(NSString *, EMSResponseModel *) = ^(NSString *requestId, EMSResponseModel *response) {
    };
    void (^errorBlock)(NSString *, NSError *) = ^(NSString *requestId, NSError *error) {
    };

    EMSCompletionProxyFactory *factory = [[EMSCompletionProxyFactory alloc] initWithRequestRepository:repository
                                                                                       operationQueue:operationQueue
                                                                                  defaultSuccessBlock:successBlock
                                                                                    defaultErrorBlock:errorBlock
                                                                                           restClient:self.mockRestClient
                                                                                       requestFactory:self.mockRequestFactory
                                                                               contactResponseHandler:self.mockContactTokenResponseHandler
                                                                                             endpoint:OCMClassMock([EMSEndpoint class])];
    EMSRESTClientCompletionProxyFactory *parentFactory = [[EMSRESTClientCompletionProxyFactory alloc] initWithRequestRepository:repository
                                                                                                                 operationQueue:operationQueue
                                                                                                            defaultSuccessBlock:successBlock
                                                                                                              defaultErrorBlock:errorBlock];
    id <EMSWorkerProtocol> worker = OCMProtocolMock(@protocol(EMSRequestModelRepositoryProtocol));

    id <EMSRESTClientCompletionProxyProtocol> parentGeneratedProxy = [parentFactory createWithWorker:worker
                                                                                        successBlock:nil
                                                                                          errorBlock:nil];
    id <EMSRESTClientCompletionProxyProtocol> proxy = [factory createWithWorker:worker
                                                                   successBlock:nil
                                                                     errorBlock:nil];

    XCTAssertEqualObjects([proxy class], [EMSMobileEngageRefreshTokenCompletionProxy class]);

    EMSMobileEngageRefreshTokenCompletionProxy *refreshTokenCompletionProxy = (EMSMobileEngageRefreshTokenCompletionProxy *) proxy;

    XCTAssertEqualObjects(refreshTokenCompletionProxy.completionProxy, parentGeneratedProxy);
}

@end