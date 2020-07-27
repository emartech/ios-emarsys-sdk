//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSNotificationInformation.h"

@protocol EMSNotificationInformationDelegate <NSObject>

- (void)didReceiveNotificationInformation:(EMSNotificationInformation *)notificationInformation;

@end
