//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSLogger.h"
#import "EMSLoggerSettings.h"

@interface EMSLogger ()

+ (void)log:(NSString *)topicTag
    message:(NSString *)message;

+ (NSString *)currentThread;

+ (NSString *)callingStack;

@end

@implementation EMSLogger

#pragma mark - Public methods

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
        [stackTrace appendString:[NSString stringWithFormat:@"\n⛓ Stack: %@ Framework: %@ Memory address: %@, Class caller: %@, Method caller: %@", splittedStackRow[0], splittedStackRow[1], splittedStackRow[2], splittedStackRow[3], splittedStackRow[4]]];
    }
    return stackTrace;
}

@end
