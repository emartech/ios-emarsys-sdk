//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSNotificationInformation.h"
#import "EMSBlocks.h"

@protocol EMSNotificationInformationDelegate <NSObject>

@property(nonatomic, strong) EMSSilentNotificationInformationBlock silentNotificationInformationDelegate;


- (void)didReceiveNotificationInformation:(EMSNotificationInformation *)notificationInformation;

@end
