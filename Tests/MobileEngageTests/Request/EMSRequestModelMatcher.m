//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestModelBuilder.h"
#import "EMSRequestModelMatcher.h"


@implementation EMSRequestModelMatcher {
    id _otherSubject;
    NSString *_differance;
}

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"beSimilarWithRequest:"];
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"\nexpected subject to be similar: %@", _differance];
}

- (NSString *)failureMessageForShouldNot {
    return [NSString stringWithFormat:@"\nexpected subject to be NOT similar: %@", _differance];
}

#pragma mark - Matching

- (BOOL)evaluate {
    if (self.subject == _otherSubject)
        return YES;
    if (_otherSubject == nil) {
        _differance = @"subject is nil";
        return NO;
    }
    if ([self.subject url] != [_otherSubject url] && ![[self.subject url] isEqual:[_otherSubject url]]) {
        _differance = [NSString stringWithFormat:@"URL %@ != %@", [self.subject url], [_otherSubject url]];
        return NO;
    }
    if ([self.subject method] != [_otherSubject method]
            && ![[self.subject method] isEqualToString:[_otherSubject method]]) {
        _differance = [NSString stringWithFormat:@"method %@ != %@", [self.subject method], [_otherSubject method]];
        return NO;
    }
    if ([self.subject payload] != [_otherSubject payload]
            && ![[self.subject payload] isEqualToDictionary:[_otherSubject payload]]) {
        _differance = [NSString stringWithFormat:@"payload %@ != %@", [self.subject payload], [_otherSubject payload]];
        return NO;
    }
    if ([self.subject headers] != [_otherSubject headers]
            && ![[self.subject headers] isEqualToDictionary:[_otherSubject headers]]) {
        _differance = [NSString stringWithFormat:@"headers %@ != %@", [self.subject headers], [_otherSubject headers]];
        return NO;
    }
    return YES;
}

- (void)beSimilarWithRequest:(EMSRequestModel *)model {
    _otherSubject = model;
}


@end