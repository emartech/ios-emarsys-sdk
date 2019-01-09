//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "EMSLogger.h"
#import "EMSLoggerSettings.h"
#import "EMSLogEntryProtocol.h"
#import "EMSShard.h"

@interface EMSLogger ()

@property(nonatomic, strong) EMSShardRepository *shardRepository;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;

+ (void)log:(NSString *)topicTag
    message:(NSString *)message;

+ (NSString *)currentThread;

+ (NSString *)callingStack;

@end

@implementation EMSLogger

#pragma mark - Public methods

- (instancetype)initWithShardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                         opertaionQueue:(NSOperationQueue *)operationQueue
                      timestampProvider:(EMSTimestampProvider *)timestampProvider
                           uuidProvider:(EMSUUIDProvider *)uuidProvider {
    NSParameterAssert(shardRepository);
    NSParameterAssert(operationQueue);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    if (self = [super init]) {
        _shardRepository = shardRepository;
        _operationQueue = operationQueue;
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
    }
    return self;
}

- (void)log:(id <EMSLogEntryProtocol>)entry {
    [self.operationQueue addOperationWithBlock:^{
        [self.shardRepository add:[EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:[entry topic]];
                [builder addPayloadEntries:[entry data]];
            }
                                          timestampProvider:self.timestampProvider
                                               uuidProvider:self.uuidProvider]];

    }];
}


+ (void)logWithTopic:(id <EMSLogTopicProtocol>)topic
             message:(NSString *)message {
    if ([EMSLoggerSettings isEnabled:topic]) {
        [EMSLogger log:topic.topicTag
               message:message];
    }
}

#pragma mark - Private methods

+ (void)log:(NSString *)topicTag
    message:(NSString *)message {
    NSLog(@"\n💡 Log - Topic: %@\nMessage: %@\n🔮️ Thread: %@\nCalling stack: %@", topicTag, message, [EMSLogger currentThread], [EMSLogger callingStack]);
}

+ (NSString *)currentThread {
    return [[NSThread currentThread] description];
}

+ (NSString *)callingStack {
    NSMutableString *stackTrace = [NSMutableString string];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSArray<NSString *> *const stackSymbols = [NSThread callStackSymbols];
    for (int i = 0; i < 6; i++) {
        NSMutableArray<NSString *> *splittedStackRow = [[stackSymbols[(NSUInteger) i] componentsSeparatedByCharactersInSet:separatorSet] mutableCopy];
        [splittedStackRow removeObject:@""];
        [stackTrace appendString:[NSString stringWithFormat:@"\n⛓ Stack: %@ Framework: %@ Memory address: %@, Class caller: %@, Method caller: %@",
                                                            splittedStackRow[0],
                                                            splittedStackRow[1],
                                                            splittedStackRow[2],
                                                            splittedStackRow[3],
                                                            splittedStackRow[4]]];
    }
    return stackTrace;
}

@end
