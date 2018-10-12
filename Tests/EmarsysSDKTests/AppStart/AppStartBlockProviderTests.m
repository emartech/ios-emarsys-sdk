//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "AppStartBlockProvider.h"

SPEC_BEGIN(AppStartBlockProviderTests)

        __block EMSRequestManager *requestManager;
        __block MERequestContext *requestContext;
        __block AppStartBlockProvider *appStartBlockProvider;
        __block MEHandlerBlock handlerBlock;

        beforeEach(^{
            requestManager = [EMSRequestManager mock];
            requestContext = [[MERequestContext alloc] initWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                    applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                [builder setMerchantId:@"testMerchantId"];
                [builder setContactFieldId:@3];
            }]];

            [requestContext setMeId:nil];
            [requestContext setMeIdSignature:nil];

            appStartBlockProvider = [AppStartBlockProvider new];
            handlerBlock = [appStartBlockProvider createAppStartBlockWithRequestManager:requestManager
                                                                         requestContext:requestContext];
        });

        afterEach(^{
            [requestContext setMeId:nil];
            [requestContext setMeIdSignature:nil];
        });

        describe(@"createAppStartBlockWithRequestManager:requestContext:", ^{

            it(@"should submit appStart event when invoking handlerBlock", ^{
                [requestContext setMeId:@"testMeId"];
                [requestContext setMeIdSignature:@"testMeIdSignature"];

                [[requestManager should] receive:@selector(submitRequestModel:withCompletionBlock:)
                                withCountAtLeast:1];
                KWCaptureSpy *submitSpy = [requestManager captureArgument:@selector(submitRequestModel:withCompletionBlock:)
                                                                  atIndex:0];

                handlerBlock();

                EMSRequestModel *result = submitSpy.argument;
                [[[result.url absoluteString] should] equal:@"https://mobile-events.eservice.emarsys.net/v3/devices/testMeId/events"];
                [[result.payload[@"events"][0][@"type"] should] equal:@"internal"];
                [[result.payload[@"events"][0][@"name"] should] equal:@"app:start"];
            });

            it(@"should not call submit on RequestManager when there is no meid (no login)", ^{
                [[requestManager shouldNot] receive:@selector(submitRequestModel:withCompletionBlock:)];

                handlerBlock();
            });

        });

SPEC_END
