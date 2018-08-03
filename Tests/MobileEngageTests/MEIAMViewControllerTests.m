#import "Kiwi.h"
#import "MEIAMViewController.h"
#import "MEJSBridge.h"
#import "FakeJSBridge.h"
#import "EMSWaiter.h"

SPEC_BEGIN(MEIAMViewControllerTests)

    describe(@"loadMessage:completionHandler:", ^{

        it(@"should call completionHandler, when content loaded", ^{
            MEJSBridge *meJsBridge = [MEJSBridge new];
            [[meJsBridge should] receive:@selector(jsCommandNames) andReturn:@[@"IAMDidAppear"]];

            NSString *message = [NSString stringWithFormat:@"<!DOCTYPE html>\n"
                                                                   "<html lang=\"en\">\n"
                                                                   "  <head>\n"
                                                                   "    <script>\n"
                                                                   "      window.onload = function() {\n"
                                                                   "        window.webkit.messageHandlers.%@.postMessage({success:true});\n"
                                                                   "      };\n"
                                                                   "    </script>\n"
                                                                   "  </head>\n"
                                                                   "  <body style=\"background: transparent;\">\n"
                                                                   "  </body>\n"
                                                                   "</html>", @"IAMDidAppear"];
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:[NSString stringWithFormat:@"wait - %@", @"IAMDidAppear"]];

            [[meJsBridge shouldEventually] receive:@selector(userContentController:didReceiveScriptMessage:) withArguments:kw_any(), kw_any()];
            KWCaptureSpy *spy = [meJsBridge captureArgument:@selector(userContentController:didReceiveScriptMessage:)
                                                    atIndex:1];
            MEIAMViewController *iamViewController = [[MEIAMViewController alloc] initWithJSBridge:meJsBridge];

            [iamViewController loadMessage:message
                         completionHandler:^{
                             [exp fulfill];
                         }];
            [EMSWaiter waitForExpectations:@[exp]
                                   timeout:30];

            WKScriptMessage *scriptMessage = spy.argument;
            [[scriptMessage.name shouldEventually] equal:@"IAMDidAppear"];
            [[scriptMessage.body shouldEventually] equal:@{@"success": @YES}];
        });
    });

    describe(@"IAMViewController", ^{

        it(@"should call JS callback method with the command's result", ^{
            NSDictionary *expectedDictionary = @{@"key": @"value"};
            NSString *message = [NSString stringWithFormat:@"<!DOCTYPE html>\n"
                                                                   "<html lang=\"en\">\n"
                                                                   "  <head>\n"
                                                                   "    <script>\n"
                                                                   "       var MEIAM = {};"
                                                                   "       MEIAM.handleResponse =  "
                                                                   "      function(responseObject) {\n"
                                                                   "        window.webkit.messageHandlers.%@.postMessage(responseObject);\n"
                                                                   "      };\n"
                                                                   "    </script>\n"
                                                                   "  </head>\n"
                                                                   "  <body style=\"background: transparent;\">\n"
                                                                   "  </body>\n"
                                                                   "</html>", @"IAMDidAppear"];
            __block WKScriptMessage *_result;
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:[NSString stringWithFormat:@"wait - JS result"]];
            FakeJSBridge *meJsBridge = [[FakeJSBridge alloc] initWithMessageBlock:^(WKScriptMessage *result) {
                _result = result;
                [exp fulfill];
            }];

            MEIAMViewController *iamViewController = [[MEIAMViewController alloc] initWithJSBridge:meJsBridge];
            [iamViewController loadMessage:message
                         completionHandler:^{
                             meJsBridge.jsResultBlock(expectedDictionary);
                         }];

            [EMSWaiter waitForExpectations:@[exp]
                                   timeout:30];

            [[_result.name should] equal:@"IAMDidAppear"];
            [[_result.body should] equal:expectedDictionary];

        });
    });

SPEC_END