#import "Kiwi.h"
#import "MEIAMOpenExternalLink.h"
#import "EMSWaiter.h"

SPEC_BEGIN(MEIAMOpenExternalLinkTests)

    __block UIApplication *_applicationMock;
    __block MEIAMOpenExternalLink *_command;

    describe(@"openExternalLink", ^{

        beforeEach(^{
            _command = [MEIAMOpenExternalLink new];
            _applicationMock = [UIApplication mock];
            [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];
        });

        it(@"should return false if link is not valid", ^{
            NSString *link = @"notAValidUrl";

            [[_applicationMock should] receive:@selector(canOpenURL:) andReturn:theValue(NO)];
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];

            __block BOOL returnedContent;
            [_command handleMessage:@{@"id": @1, @"url": link}
                        resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                            returnedContent = [((NSNumber *) result[@"success"]) boolValue];
                            [exp fulfill];
                        }];

            [EMSWaiter waitForExpectations:@[exp]
                                   timeout:30];

            [[theValue(returnedContent) should] beNo];
        });

        it(@"should return false if there is no url", ^{
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
            __block NSDictionary<NSString *, NSObject *> *returnedResult;

            [_command handleMessage:@{@"id": @"999"}
                        resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                            returnedResult = result;
                            [exp fulfill];
                        }];
            [EMSWaiter waitForExpectations:@[exp] timeout:30];

            [[returnedResult should] equal:@{@"success": @NO, @"id": @"999", @"errors": @[@"Missing 'url' key with type: NSString."]}];

        });

        it(@"should return false if the url is wrong type", ^{
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
            __block NSDictionary<NSString *, NSObject *> *returnedResult;

            NSArray *urlValue = @[];
            [_command handleMessage:@{@"id": @"999", @"url": urlValue}
                        resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                            returnedResult = result;
                            [exp fulfill];
                        }];
            [EMSWaiter waitForExpectations:@[exp] timeout:30];

            [[returnedResult should] equal:@{@"success": @NO, @"id": @"999", @"errors": @[[NSString stringWithFormat:@"Type mismatch for key 'url', expected type: NSString, but was: %@.", NSStringFromClass([urlValue class])]]}];
        });

    });

SPEC_END



