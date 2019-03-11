//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HOST_URL @"https://ems-me-client.herokuapp.com"
#define CLIENT_URL(applicationCode) [NSString stringWithFormat:@"%@/v3/apps/%@/client", HOST_URL, applicationCode]
#define PUSH_TOKEN_URL(applicationCode) [NSString stringWithFormat:@"%@/push-token", CLIENT_URL(applicationCode)]
#define CONTACT_URL(applicationCode) [NSString stringWithFormat:@"%@/contact", CLIENT_URL(applicationCode)]