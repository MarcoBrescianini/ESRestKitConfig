//
//  ESPlistRequestDescriptorFactoryTest.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/11/15.
//  Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <RestKit/RestKit.h>

#import "ESPlistRequestDescriptorFactory.h"
#import "ESConfigFixtures.h"
#import "ESFoo.h"
#import "ESBar.h"

@interface ESPlistRequestDescriptorFactoryTest : XCTestCase
{
    ESPlistRequestDescriptorFactory * factory;

    ESMappingMap mappingMap;

    id fooMappingMock;
    id barMappingMock;

    id inversedFooMapping;
    id inversedBarMapping;
}

@end

@implementation ESPlistRequestDescriptorFactoryTest

- (void)setUp
{
    [super setUp];

    fooMappingMock = OCMClassMock([RKEntityMapping class]);
    barMappingMock = OCMClassMock([RKEntityMapping class]);

    inversedFooMapping = OCMClassMock([RKObjectMapping class]);
    inversedBarMapping = OCMClassMock([RKObjectMapping class]);

    mappingMap = @{
            @"foo" : fooMappingMock,
            @"bar" : barMappingMock
    };

    OCMStub([inversedFooMapping objectClass]).andReturn([NSMutableDictionary class]);
    OCMStub([inversedBarMapping objectClass]).andReturn([NSMutableDictionary class]);

}

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization Tests

- (void)testInitThrows
{
    XCTAssertThrows([ESPlistRequestDescriptorFactory new]);
}

- (void)testInitWithEmptyMappingThrows
{
    XCTAssertThrows([[ESPlistRequestDescriptorFactory alloc] initWithMappings:nil config:@{}]);
    XCTAssertThrows([[ESPlistRequestDescriptorFactory alloc] initWithMappings:@{} config:@{}]);
}

- (void)testInitWithEmptyConfigDictionaryThrows
{
    XCTAssertThrows([[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:nil]);
    XCTAssertThrows([[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:@{}]);
}

- (void)testCanInitWithConfigDictionary
{
    NSDictionary * config = @{

            @"desc" : @{
            }
    };

    factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:config];

    [self assertFactoryInitialized];
}

- (void)testCanInitWithFilepath
{
    NSString * filepath;

    @try {
        NSDictionary * conf = [ESConfigFixtures requestConfigDictionary];
        filepath = [ESConfigFixtures writeRequestFile:conf];

        factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap filepath:filepath];

        [self assertFactoryInitialized];

    }
    @finally {
        if(filepath)
        {
            NSFileManager * manager = [NSFileManager new];
            if([manager fileExistsAtPath:filepath])
            {
                [manager removeItemAtPath:filepath error:nil];
            }
        }
    }

}

#warning Skipped Test
- (void)_testCanInitFromMainBundle
{
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap fromMainBundle:@"Request"];

    [self assertFactoryInitialized];
}

- (void)assertFactoryInitialized
{
    XCTAssertNotNil(factory);
    XCTAssertNotNil(factory.mappings);
    XCTAssertNotNil(factory.config);
}

//-------------------------------------------------------------------------------------------
#pragma mark - Business Logic Tests


-(void)testDescriptorForName_nameNotFound_throws
{
    NSDictionary * config = @{
            @"desc" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"POST",
                    @"mapping" : @"foo",
                    @"object" : @"ESFoo"
            }
    };
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:config];

    XCTAssertThrowsSpecificNamed([factory createDescriptorNamed:@"baz"], NSException, @"ConfigurationException");
}



-(void)testDescriptorForName_missingMethod_throws
{
    NSDictionary * config = @{
            @"desc" : @{
                    @"keypath" : @"keypath",
                    @"mapping" : @"foo",
                    @"object" : @"ESFoo"
            }
    };
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:config];

    XCTAssertThrowsSpecificNamed([factory createDescriptorNamed:@"desc"], NSException, @"PlistMalformedException");
}


-(void)testDescriptorForName_missingMapping_throws
{
    NSDictionary * config = @{
            @"desc" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"POST",
                    @"mapping" : @"baz",
                    @"object" : @"ESFoo"
            }
    };
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:config];

    XCTAssertThrowsSpecificNamed([factory createDescriptorNamed:@"desc"], NSException, @"PlistMalformedException");
}


-(void)testDescriptorForName_missingObject_throws
{
    NSDictionary * config = @{
            @"desc" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"POST",
                    @"mapping" : @"foo",
                    @"object" : @"TYNotExistent"
            }
    };

    factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:config];

    XCTAssertThrowsSpecificNamed([factory createDescriptorNamed:@"desc"], NSException, @"PlistMalformedException");
}


- (void)testDescriptorForName
{
    NSDictionary * config = @{
            @"desc" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"POST",
                    @"mapping" : @"foo",
                    @"object" : @"ESFoo"
            }
    };

    OCMExpect([fooMappingMock inverseMapping]).andReturn(inversedFooMapping);
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:config];

    RKRequestDescriptor * descriptor = [factory createDescriptorNamed:@"desc"];
    RKRequestDescriptor * expectedDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:inversedFooMapping
                                                                                     objectClass:[ESFoo class]
                                                                                     rootKeyPath:@"keypath"
                                                                                          method:RKRequestMethodPOST];

    OCMStub([inversedFooMapping isEqualToMapping:OCMOCK_ANY]).andReturn(YES);

    XCTAssertTrue([expectedDescriptor isEqualToRequestDescriptor:descriptor]);
    OCMVerifyAll(fooMappingMock);
}


- (void)testCreateResponseDescriptors
{
    NSDictionary * config = @{
            @"foo" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"POST",
                    @"mapping" : @"foo",
                    @"object" : @"ESFoo"
            },
            @"bar" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"PUT",
                    @"mapping" : @"bar",
                    @"object" : @"ESBar"
            }
    };

    OCMExpect([fooMappingMock inverseMapping]).andReturn(inversedFooMapping);
    OCMExpect([barMappingMock inverseMapping]).andReturn(inversedBarMapping);

    factory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappingMap config:config];

    NSArray<RKRequestDescriptor *>* descriptors = [factory createRequestDescriptors];

    XCTAssertNotNil(descriptors);
    XCTAssertEqual(descriptors.count, 2);



    RKRequestDescriptor * fooDesc = [RKRequestDescriptor requestDescriptorWithMapping:inversedFooMapping
                                                                          objectClass:[ESFoo class]
                                                                          rootKeyPath:@"keypath"
                                                                               method:RKRequestMethodPOST];

    OCMStub([inversedFooMapping isEqualToMapping:OCMOCK_ANY]).andReturn(YES);

    XCTAssertTrue([descriptors[0] isEqualToRequestDescriptor:fooDesc]);



    RKRequestDescriptor * barDesc = [RKRequestDescriptor requestDescriptorWithMapping:inversedBarMapping
                                                                          objectClass:[ESBar class]
                                                                          rootKeyPath:@"keypath"
                                                                               method:RKRequestMethodPUT];

    OCMStub([inversedBarMapping isEqualToMapping:OCMOCK_ANY]).andReturn(YES);

    XCTAssertTrue([descriptors[1] isEqualToRequestDescriptor:barDesc]);

    OCMVerifyAll(fooMappingMock);
    OCMVerifyAll(barMappingMock);
}

@end
