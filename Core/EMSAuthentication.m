//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSAuthentication.h"

@implementation EMSAuthentication

+ (NSString *)createBasicAuthWithUsername:(NSString *)username
                                 password:(NSString *)password {
    NSParameterAssert(username);
    NSParameterAssert(password);
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *credentialsData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Credentials = [credentialsData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return [NSString stringWithFormat:@"Basic %@", base64Credentials];
}

@end