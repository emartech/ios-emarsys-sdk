//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSAuthentication.h"

@implementation EMSAuthentication

+ (NSString *)createBasicAuthWithUsername:(NSString *)username {
    NSParameterAssert(username);
    NSString *credentials = [NSString stringWithFormat:@"%@:", username];
    NSData *credentialsData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Credentials = [credentialsData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return [NSString stringWithFormat:@"Basic %@", base64Credentials];
}

@end