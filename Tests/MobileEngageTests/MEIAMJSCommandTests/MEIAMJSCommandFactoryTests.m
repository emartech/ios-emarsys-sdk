#import "Kiwi.h"
#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"
#import "MEIAMClose.h"
#import "MEIAMTriggerAppEvent.h"
#import "MEIAMButtonClicked.h"
#import "MEIAMViewController.h"
#import "MEIAMTriggerMEEvent.h"

MEIAMJSCommandFactory *_factory;

SPEC_BEGIN(MEIAMJSCommandFactoryTests)

        __block NSString *currentCampaignId;
        __block id _meiam;

        beforeEach(^{
            currentCampaignId = @"123";
            _meiam = [KWMock mockForProtocol:@protocol(MEIAMProtocol)];
            [_meiam stub:@selector(currentCampaignId) andReturn:currentCampaignId];
            [_meiam stub:@selector(meiamViewController) andReturn:[MEIAMViewController mock]];
            [_meiam stub:@selector(inAppTracker) andReturn:[KWMock mockForProtocol:@protocol(MEInAppTrackingProtocol)]];
            [_meiam stub:@selector(eventHandler) andReturn:[KWMock mockForProtocol:@protocol(MEEventHandler)]];
            _factory = [[MEIAMJSCommandFactory alloc] initWithMEIAM:_meiam
                                              buttonClickRepository:[MEButtonClickRepository nullMock]];
        });

        describe(@"initWithMEIAM:buttonClickRepository:", ^{
            it(@"should initialize MEInApp property", ^{
                id meiam = [KWMock mockForProtocol:@protocol(MEIAMProtocol)];
                MEIAMJSCommandFactory *meiamjsCommandFactory = [[MEIAMJSCommandFactory alloc] initWithMEIAM:meiam
                                                                                      buttonClickRepository:nil];

                [[@([meiamjsCommandFactory.meIam isEqual:meiam]) should] beYes];
            });
        });

        describe(@"commandByName", ^{
            it(@"should return MEIAMRequestPushPermission command when the given name is: requestPushPermission", ^{
                MEIAMRequestPushPermission *command = [_factory commandByName:@"requestPushPermission"];
                [[command should] beKindOfClass:[MEIAMRequestPushPermission class]];
            });

            it(@"should return MEIAMOpenExternalLink command when the given name is: openExternalLink", ^{
                MEIAMOpenExternalLink *command = [_factory commandByName:@"openExternalLink"];
                [[command should] beKindOfClass:[MEIAMOpenExternalLink class]];
            });

            it(@"should return MEIAMClose command when the given name is: close", ^{
                MEIAMClose *command = [_factory commandByName:@"close"];
                [[command should] beKindOfClass:[MEIAMClose class]];
            });

            it(@"should return MEIAMTriggerAppEvent command when the given name is: triggerAppEvent", ^{
                MEIAMTriggerAppEvent *command = [_factory commandByName:@"triggerAppEvent"];
                [[command should] beKindOfClass:[MEIAMTriggerAppEvent class]];
            });

            it(@"should return MEIAMButtonClicked command when the given name is: buttonClicked", ^{
                MEIAMButtonClicked *command = [_factory commandByName:@"buttonClicked"];
                [[command should] beKindOfClass:[MEIAMButtonClicked class]];
            });

            it(@"should initialize the MEIAMButtonClicked command", ^{
                MEIAMButtonClicked *command = [_factory commandByName:@"buttonClicked"];
                [[command.campaignId shouldNot] beNil];
                [[command.campaignId should] equal:currentCampaignId];
                [[command.repository shouldNot] beNil];
                [[(NSObject *) command.inAppTracker shouldNot] beNil];
            });

            it(@"should return MEIAMTriggerMEEvent command when the given name is: triggerMEEvent", ^{
                MEIAMTriggerMEEvent *command = [_factory commandByName:@"triggerMEEvent"];
                [[command should] beKindOfClass:[MEIAMTriggerMEEvent class]];
            });
        });

SPEC_END
