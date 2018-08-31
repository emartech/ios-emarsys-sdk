#import "Kiwi.h"
#import "MEJSBridge.h"
#import <UserNotifications/UserNotifications.h>
#import "MEIAMViewController.h"
#import "MEIAMDidAppear.h"
#import "MEIAMJSCommandFactory.h"
#import "EMSWaiter.h"

MEJSBridge *_meJsBridge;

@interface UserContentControllerRegistrationChecker : NSObject

+ (void)assertForJSCommand:(NSString *)commandName;

@end

@implementation UserContentControllerRegistrationChecker

+ (void)assertForJSCommand:(NSString *)commandName {
    it([NSString stringWithFormat:@"should register JSCommand_%@", commandName], ^{
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
                                                               "</html>", commandName];
        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:[NSString stringWithFormat:@"wait - %@", commandName]];

        [[_meJsBridge should] receive:@selector(userContentController:didReceiveScriptMessage:) withArguments:kw_any(), kw_any()];
        KWCaptureSpy *spy = [_meJsBridge captureArgument:@selector(userContentController:didReceiveScriptMessage:)
                                                 atIndex:1];
        MEIAMViewController *iamViewController = [[MEIAMViewController alloc] initWithJSBridge:_meJsBridge];

        [iamViewController loadMessage:message
                     completionHandler:^{
                         [exp fulfill];
                     }];
        [EMSWaiter waitForExpectations:@[exp]
                               timeout:30];

        WKScriptMessage *scriptMessage = spy.argument;
        [[scriptMessage.name should] equal:commandName];
        [[scriptMessage.body should] equal:@{@"success": @YES}];
    });
}

@end

SPEC_BEGIN(MEJSBridgeTests)

    beforeEach(^{
        _meJsBridge = [MEJSBridge new];
    });

    describe(@"jsCommandNames", ^{
        it(@"should contain IAMDidAppear, requestPushPermission, openExternalLink, close, triggerAppEvent, buttonClicked", ^{
            NSArray<NSString *> *const commands = [[MEJSBridge new] jsCommandNames];
            [[commands should] equal:@[
                    @"requestPushPermission",
                    @"openExternalLink",
                    @"close",
                    @"triggerAppEvent",
                    @"buttonClicked",
                    @"triggerMEEvent"
            ]];
        });
    });

    describe(@"userContentController", ^{

        it(@"should not return nil", ^{
            [[[_meJsBridge userContentController] shouldNot] beNil];
        });

        for (NSString *commandName in [[MEJSBridge new] jsCommandNames]) {
            [UserContentControllerRegistrationChecker assertForJSCommand:commandName];
        }

    });
    describe(@"userContentController:didReceiveScriptMessage:", ^{

        it(@"should call handleMessage on created command with arguments dictionary", ^{
            MEIAMDidAppear *commandMock = [MEIAMDidAppear mock];
            MEIAMJSCommandFactory *factoryMock = [MEIAMJSCommandFactory mock];
            [[factoryMock should] receive:@selector(commandByName:)
                                andReturn:commandMock
                            withArguments:MEIAMDidAppear.commandName];

            _meJsBridge = [[MEJSBridge alloc] initWithJSCommandFactory:factoryMock];

            NSDictionary *arguments = @{@"key": @"value"};
            WKScriptMessage *scriptMessageMock = [WKScriptMessage mock];
            [scriptMessageMock stub:@selector(name) andReturn:MEIAMDidAppear.commandName];
            [scriptMessageMock stub:@selector(body) andReturn:arguments];

            [[commandMock should] receive:@selector(handleMessage:resultBlock:)
                            withArguments:arguments, kw_any()];

            [_meJsBridge userContentController:[WKUserContentController mock]
                       didReceiveScriptMessage:scriptMessageMock];
        });

        it(@"should call resultBlock when command's resultBlock called", ^{
            NSDictionary *expectedDictionary = @{@"key": @"value"};

            MEIAMDidAppear *command = [MEIAMDidAppear new];
            MEIAMJSCommandFactory *factoryMock = [MEIAMJSCommandFactory mock];
            [[factoryMock should] receive:@selector(commandByName:)
                                andReturn:command
                            withArguments:MEIAMDidAppear.commandName];

            _meJsBridge = [[MEJSBridge alloc] initWithJSCommandFactory:factoryMock];

            WKScriptMessage *scriptMessageMock = [WKScriptMessage mock];
            [scriptMessageMock stub:@selector(name) andReturn:MEIAMDidAppear.commandName];
            [scriptMessageMock stub:@selector(body)];

            [_meJsBridge userContentController:[WKUserContentController mock]
                       didReceiveScriptMessage:scriptMessageMock];

            [command triggerResultBlockWithDictionary:expectedDictionary];

            __block NSDictionary *resultDictionary;
            [_meJsBridge setJsResultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                resultDictionary = result;
            }];

            [[resultDictionary shouldEventually] equal:expectedDictionary];
        });

    });

SPEC_END
