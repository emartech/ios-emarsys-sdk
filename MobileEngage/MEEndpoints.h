//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLIENT_SERVICE_URL @"https://ems-me-client.herokuapp.com"
#define EVENT_SERVICE_URL @"https://mobile-events.eservice.emarsys.net"
#define BASE_URL(applicationCode, serviceUrl) [NSString stringWithFormat:@"%@/v3/apps/%@/client", serviceUrl, applicationCode]
#define CLIENT_URL(applicationCode) BASE_URL(applicationCode, CLIENT_SERVICE_URL)
#define PUSH_TOKEN_URL(applicationCode) [NSString stringWithFormat:@"%@/push-token", CLIENT_URL(applicationCode)]
#define CONTACT_URL(applicationCode) [NSString stringWithFormat:@"%@/contact", CLIENT_URL(applicationCode)]
#define CONTACT_TOKEN_URL(applicationCode) [NSString stringWithFormat:@"%@/contact-token", CLIENT_URL(applicationCode)]
#define EVENT_URL(applicationCode) [NSString stringWithFormat:@"%@/events", BASE_URL(applicationCode, EVENT_SERVICE_URL)]