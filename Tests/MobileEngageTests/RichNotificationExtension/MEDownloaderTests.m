//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MEDownloader.h"
#import "EMSWaiter.h"

SPEC_BEGIN(MEDownloaderTests)

        __block MEDownloader *downloadUtils;

        beforeEach(^{
            downloadUtils = [[MEDownloader alloc] init];
        });

        void (^waitUntilNextFinishedDownload)(NSString *url) = ^(NSString *url) {
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
            [downloadUtils downloadFileFromUrl:[NSURL URLWithString:url]
                             completionHandler:^(NSURL *destinationUrl, NSError *error) {
                                 [exp fulfill];
                             }];
            [EMSWaiter waitForExpectations:@[exp] timeout:30];
        };

        describe(@"downloadFileFromUrl:completionHandler:", ^{
            it(@"should give error, when url doesn't exist", ^{
                __block NSError *resultError;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [downloadUtils downloadFileFromUrl:nil
                                 completionHandler:^(NSURL *destinationUrl, NSError *error) {
                                     resultError = error;
                                     [exp fulfill];
                                 }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[resultError.localizedDescription should] equal:@"Source url doesn't exist."];
            });

            it(@"should not crash when url doesn't exist and completionHandler doesn't exist", ^{
                [downloadUtils downloadFileFromUrl:nil
                                 completionHandler:nil];
            });

            it(@"should give error, when url not valid", ^{
                __block NSError *resultError;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [downloadUtils downloadFileFromUrl:[NSURL URLWithString:@""]
                                 completionHandler:^(NSURL *destinationUrl, NSError *error) {
                                     resultError = error;
                                     [exp fulfill];
                                 }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[resultError shouldNot] beNil];
            });

            it(@"should not crash when url doesn't valid and completionHandler doesn't exist", ^{
                [downloadUtils downloadFileFromUrl:[NSURL URLWithString:@""]
                                 completionHandler:nil];

                waitUntilNextFinishedDownload(@"");
            });

            it(@"should not crash when url doesn't supported and completionHandler doesn't exist", ^{
                [downloadUtils downloadFileFromUrl:[NSURL URLWithString:@"https://www.google.com"]
                                 completionHandler:nil];

                waitUntilNextFinishedDownload(@"https://www.google.com");
            });

            it(@"should give destinationUrl, when download successfully finished", ^{
                __block NSURL *result;

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [downloadUtils downloadFileFromUrl:[NSURL URLWithString:@"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png"]
                                 completionHandler:^(NSURL *destinationUrl, NSError *error) {
                                     result = destinationUrl;
                                     [exp fulfill];
                                 }];
                [EMSWaiter waitForExpectations:@[exp] timeout:30];

                [[result shouldNot] beNil];
                [[[result scheme] should] equal:@"file"];
                [[theValue([[[result pathComponents] lastObject] hasSuffix:@".png"]) should] beYes];
            });

            it(@"should not crash when download successfully finished and completionHandler doesn't exist", ^{
                [downloadUtils downloadFileFromUrl:[NSURL URLWithString:@"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png"]
                                 completionHandler:nil];

                waitUntilNextFinishedDownload(@"https://s3-eu-west-1.amazonaws.com/ems-mobileteam-artifacts/test-resources/Emarsys.png");
            });
        });

SPEC_END
