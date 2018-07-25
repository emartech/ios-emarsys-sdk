#import "Kiwi.h"
#import "MERequestMatcher.h"

SPEC_BEGIN(MERequestMatcherTest)

        describe(@"isV3CustomEventUrl", ^{
            it(@"should return yes for v3 custom event urls", ^{
                [[theValue([MERequestMatcher isV3CustomEventUrl:@"https://mobile-events.eservice.emarsys.net/v3/devices/meid/events"]) should] beYes];
                [[theValue([MERequestMatcher isV3CustomEventUrl:@"https://mobile-events.eservice.emarsys.net/v3/devices/345353453/events"]) should] beYes];
                [[theValue([MERequestMatcher isV3CustomEventUrl:@"https://mobile-events.eservice.emarsys.net/v3/devices/g430jg0934jg3/events"]) should] beYes];
            });

            it(@"should return no for non v3 custom event urls", ^{
                [[theValue([MERequestMatcher isV3CustomEventUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"]) should] beNo];
                [[theValue([MERequestMatcher isV3CustomEventUrl:@"https://www.emarsys.com"]) should] beNo];
                [[theValue([MERequestMatcher isV3CustomEventUrl:@"https://mobile-events.eservice.emarsys.net/v2/devices/g430jg0934jg3/events"]) should] beNo];
                [[theValue([MERequestMatcher isV3CustomEventUrl:@"https://something.eservice.emarsys.net/v3/devices/g430jg0934jg3/events"]) should] beNo];
            });

            it(@"should return no for nil url", ^{
                [[theValue([MERequestMatcher isV3CustomEventUrl:nil]) should] beNo];
            });
        });

SPEC_END
