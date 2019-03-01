//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HOST_URL @"https://ems-me-client.herokuapp.com"
#define CLIENT_URL(applicationCode) [NSString stringWithFormat:@"%@/v3/apps/%@/client", HOST_URL, applicationCode]