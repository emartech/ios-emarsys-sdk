#import "Kiwi.h"
#import "MEIAMMetricsLogHandler.h"
#import "KWEqualMatcher.h"

SPEC_BEGIN(MEIAMMetricsLogHandlerTests)

        NSString *kInDatabaseTime = @"in_database_time";
        NSString *kNetworkingTime = @"networking_time";
        NSString *kLoadingTime = @"loading_time";
        NSString *kCampaignId = @"campaign_id";
        NSString *kRequestId = @"request_id";
        NSString *kUrl = @"url";
        NSString *kCustomEventV3Url = @"https://mobile-events.eservice.emarsys.net/v3/devices/123456789/events";
        NSString *kNotCustomEventV3Url = @"https://push.eservice.emarsys.net/api/mobileengage/v2/events/mycustomevent";

        NSDictionary<NSString *, NSObject *> *kInDatabaseMetric = @{
            kRequestId: @"requestId",
            kUrl: kCustomEventV3Url,
            kInDatabaseTime: @30
        };

        NSDictionary<NSString *, NSObject *> *kNetworkingTimeMetric = @{
            kRequestId: @"requestId",
            kUrl: kCustomEventV3Url,
            kNetworkingTime: @30
        };

        NSDictionary<NSString *, NSObject *> *kLoadingTimeMetric = @{
            kRequestId: @"requestId",
            kCampaignId: @"campaignId",
            kLoadingTime: @30
        };

        NSDictionary<NSString *, NSObject *> *kMetric = @{
            kRequestId: @"requestId",
            kCampaignId: @"campaignId",
            kUrl: kCustomEventV3Url,
            kInDatabaseTime: @30,
            kNetworkingTime: @30,
            kLoadingTime: @30
        };

        __block NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *metricsBuffer;
        __block MEIAMMetricsLogHandler *handler;

//        private static final String CUSTOM_EVENT_V3_URL = "https://mobile-events.eservice.emarsys.net/v3/devices/123456789/events";
//        private static final String NOT_CUSTOM_EVENT_V3_URL = "https://push.eservice.emarsys.net/api/mobileengage/v2/events/mycustomevent";
//        private static final String REQUEST_ID = "request_id";
//        private static final String URL = "url";
//        private static final String IN_DATABASE = "in_database";
//        private static final String NETWORKING_TIME = "networking_time";
//        private static final String LOADING_TIME = "loading_time";
//        private static final String ON_SCREEN_TIME = "on_screen_time";
//        private static final String CAMPAIGN_ID = "campaign_id";

        beforeEach(^{
            metricsBuffer = [NSMutableDictionary dictionary];
            handler = [[MEIAMMetricsLogHandler alloc] initWithMetricsBuffer:metricsBuffer];
        });

        describe(@"initWithMetricsBuffer:", ^{

            it(@"should throw exception when metricsBuffer is nil", ^{
                @try {
                    [[MEIAMMetricsLogHandler alloc] initWithMetricsBuffer:nil];
                    fail(@"Expected Exception when metricsBuffer is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });


        describe(@"handle:", ^{

            it(@"should throw exception when item is nil", ^{
                @try {
                    [handler handle:nil];
                    fail(@"Expected Exception when item is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should not put metrics into buffer if requestId is missing", ^{
                [handler handle:@{@"missingRequestId": @"NotARequestId"}];

                [[metricsBuffer should] beEmpty];
            });

            it(@"should not put metrics into buffer if requestId is invalid", ^{
                [handler handle:@{kRequestId: @{}}];

                [[metricsBuffer should] beEmpty];
            });

            it(@"should not put metric into buffer if it is not a known metric", ^{
                NSDictionary<NSString *, NSObject *> *genericMetric = @{
                    kRequestId: @"requestId",
                };

                [handler handle:genericMetric];

                [[metricsBuffer should] beEmpty];
            });

            context(@"inDatabaseMetrics", ^{
                it(@"should put inDatabaseMetrics metrics into buffer", ^{
                    [handler handle:kInDatabaseMetric];

                    [[metricsBuffer should] equal:@{@"requestId": kInDatabaseMetric}];
                });

                it(@"should not put inDatabaseMetrics into buffer if the url is not valid", ^{
                    NSDictionary<NSString *, NSObject *> *inDatabaseMetric = @{
                        kRequestId: @"requestId",
                        kInDatabaseTime: @30,
                        kUrl: kNotCustomEventV3Url
                    };

                    [handler handle:inDatabaseMetric];

                    [[metricsBuffer should] beEmpty];
                });
            });

            context(@"networkingMetrics", ^{
                it(@"should put networking time metrics into buffer", ^{
                    [handler handle:kNetworkingTimeMetric];

                    [[metricsBuffer should] equal:@{@"requestId": kNetworkingTimeMetric}];
                });

                it(@"should not put networkingMetrics into buffer if the url is not valid", ^{
                    NSDictionary<NSString *, NSObject *> *networkingMetric = @{
                        kRequestId: @"requestId",
                        kNetworkingTime: @30,
                        kUrl: kNotCustomEventV3Url
                    };

                    [handler handle:networkingMetric];

                    [[metricsBuffer should] beEmpty];
                });
            });

            context(@"loadingTimeMetrics", ^{
                it(@"should put loading_time metrics into the buffer", ^{
                    [handler handle:kLoadingTimeMetric];

                    [[metricsBuffer should] equal:@{@"requestId": kLoadingTimeMetric}];
                });

                it(@"should not put loading_time metrics into buffer if the campaignId is missing", ^{
                    NSDictionary<NSString *, NSObject *> *loadingTimeMetric = @{
                        kRequestId: @"requestId",
                        kLoadingTime: @30
                    };

                    [handler handle:loadingTimeMetric];

                    [[metricsBuffer should] beEmpty];
                });
            });

            context(@"buffering", ^{
                it(@"should return the metric for storing only when in_database_time, network_time, loading_time is available", ^{
                    [handler handle:kInDatabaseMetric];
                    [handler handle:kNetworkingTimeMetric];
                    NSDictionary<NSString *, NSObject *> *returnedMetric = [handler handle:kLoadingTimeMetric];

                    [[returnedMetric should] equal:kMetric];
                });

                it(@"should return with nil when not all of metrics are available for requestId", ^{
                    [handler handle:kNetworkingTimeMetric];
                    NSDictionary<NSString *, NSObject *> *returnedMetric = [handler handle:kLoadingTimeMetric];

                    [[returnedMetric should] beNil];
                });

                it(@"should remove complete metric from buffer after returned", ^{
                    [handler handle:kInDatabaseMetric];
                    [handler handle:kNetworkingTimeMetric];
                    [handler handle:kLoadingTimeMetric];

                    [[metricsBuffer[@"requestId"] should] beNil];
                });
            });
        });

SPEC_END