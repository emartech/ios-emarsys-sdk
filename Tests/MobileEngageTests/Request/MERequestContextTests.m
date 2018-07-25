#import "Kiwi.h"
#import "MERequestContext.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(MERequestContextTests)

        describe(@"uuidProvider", ^{
            it(@"should be initialized after requestContext has been initialized", ^{
                MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:[MEConfig mock]];
                [[requestContext.uuidProvider shouldNot] beNil];
            });
        });

SPEC_END
