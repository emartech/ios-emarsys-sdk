#import "Kiwi.h"
#import "MELogRepositoryProxy.h"
#import "MELogRepository.h"
#import "MEIAMMetricsLogHandler.h"
#import "FakeSpecification.h"
#import "KWEqualMatcher.h"

SPEC_BEGIN(MELogRepositoryProxyTests)

    __block MELogRepository *logRepository;
    __block MEIAMMetricsLogHandler *handler1;
    __block MEIAMMetricsLogHandler *handler2;
    __block MEIAMMetricsLogHandler *handler3;
    __block NSArray<id <EMSLogHandlerProtocol>> *handlers;
    __block MELogRepositoryProxy *proxy;
    __block NSDictionary<NSString *, NSObject *> *metric1;
    __block NSDictionary<NSString *, NSObject *> *metric2;
    __block NSDictionary<NSString *, NSObject *> *metric3;

    beforeEach(^{
        logRepository = [MELogRepository mock];
        handler1 = [MEIAMMetricsLogHandler mock];
        handler2 = [MEIAMMetricsLogHandler mock];
        handler3 = [MEIAMMetricsLogHandler mock];
        handlers = @[handler1, handler2, handler3];
        proxy = [[MELogRepositoryProxy alloc] initWithLogRepository:logRepository
                                                           handlers:handlers];
        metric1 = @{
            @"m1Key1": @"alpha",
            @"m1Key2": @NO
        };
        metric2 = @{
            @"m2Key1": @23571113,
            @"m2Key2": @3.14
        };
        metric3 = @{
            @"m3Key1": @"omega",
            @"m3Key2": @YES,
            @"m2Key2": @11235813
        };
    });

    describe(@"initWithLogRepository:handlers:", ^{

        it(@"should throw exception when logRepository is nil", ^{
            @try {
                (void)[[MELogRepositoryProxy alloc] initWithLogRepository:nil
                                                           handlers:handlers];
                fail(@"Expected Exception when logRepository is nil!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw exception when handlers is nil", ^{
            @try {
                (void)[[MELogRepositoryProxy alloc] initWithLogRepository:logRepository
                                                           handlers:nil];
                fail(@"Expected Exception when handlers is nil!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw exception when handlers is empty", ^{
            @try {
                (void)[[MELogRepositoryProxy alloc] initWithLogRepository:logRepository
                                                           handlers:@[]];
                fail(@"Expected Exception when handlers is empty!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });
    });

    describe(@"add:", ^{

        it(@"should invoke Handlers", ^{
            [[handler1 should] receive:@selector(handle:)
                         withArguments:metric1];
            [[handler2 should] receive:@selector(handle:)
                         withArguments:metric1];
            [[handler3 should] receive:@selector(handle:)
                         withArguments:metric1];

            [proxy add:metric1];
        });

        it(@"should add handled metrics to logRepository", ^{
            handlers = @[handler1];
            proxy = [[MELogRepositoryProxy alloc] initWithLogRepository:logRepository
                                                               handlers:handlers];

            [[logRepository should] receive:@selector(add:)
                              withArguments:metric2];
            [[handler1 should] receive:@selector(handle:)
                             andReturn:metric2
                         withArguments:metric1];

            [proxy add:metric1];
        });

        it(@"should add handled non nil metrics to logRepository", ^{
            handlers = @[handler1, handler2];
            proxy = [[MELogRepositoryProxy alloc] initWithLogRepository:logRepository
                                                               handlers:handlers];

            [[handler1 should] receive:@selector(handle:)
                             andReturn:metric2
                         withArguments:metric1];
            [[handler2 should] receive:@selector(handle:)
                             andReturn:nil
                         withArguments:metric1];

            [[logRepository should] receive:@selector(add:)
                              withArguments:metric2];
            [proxy add:metric1];
        });

        it(@"should add handled merged metrics to logRepository", ^{
            NSDictionary<NSString *, NSObject *> *expected = @{
                @"m2Key1": @23571113,
                @"m3Key1": @"omega",
                @"m3Key2": @YES,
                @"m2Key2": @11235813
            };

            [[handler1 should] receive:@selector(handle:)
                             andReturn:metric2
                         withArguments:metric1];
            [[handler2 should] receive:@selector(handle:)
                             andReturn:nil
                         withArguments:metric1];
            [[handler3 should] receive:@selector(handle:)
                             andReturn:metric3
                         withArguments:metric1];

            [[logRepository should] receive:@selector(add:)
                              withArguments:expected];
            [proxy add:metric1];
        });
    });

    describe(@"remove:", ^{
        it(@"should invoke logRepository's remove with the given specification", ^{
            FakeSpecification *specification = [FakeSpecification mock];

            [[logRepository should] receive:@selector(remove:)
                              withArguments:specification];

            [proxy remove:specification];
        });
    });

    describe(@"query:", ^{
        it(@"should invoke logRepository's query with the given specification and return with that returned value", ^{
            FakeSpecification *specification = [FakeSpecification mock];

            [[logRepository should] receive:@selector(query:)
                                  andReturn:@[metric1]
                              withArguments:specification];

            NSDictionary<NSString *, NSObject *> *returnedValue = [proxy query:specification].firstObject;

            [[returnedValue should] equal:metric1];
        });
    });

    describe(@"isEmpty", ^{
        it(@"should invoke logRepository's isEmpty and return with that returned value", ^{
            [[logRepository should] receive:@selector(isEmpty)
                                  andReturn:theValue(YES)];

            BOOL returnedValue = [proxy isEmpty];

            [[theValue(returnedValue) should] beYes];
        });
    });

SPEC_END