//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSOnEventActionInternal.h"

@interface EMSOnEventActionInternalTests : XCTestCase

@end

@implementation EMSOnEventActionInternalTests

- (void)testEventHandler {
    id eventHandler = OCMProtocolMock(@protocol(EMSEventHandler));
    EMSActionFactory *mockActionFactory = OCMClassMock([EMSActionFactory class]);
    EMSOnEventActionInternal *eventActionInternal = [[EMSOnEventActionInternal alloc] initWithActionFactory:mockActionFactory];
    
    eventActionInternal.eventHandler = eventHandler;
    
    OCMVerify([mockActionFactory setEventHandler: eventHandler]);
}

@end
