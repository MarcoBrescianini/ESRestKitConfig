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
#import "ESDictionaryRequestDescriptorFactory.h"

@interface ESPlistRequestDescriptorFactoryTest : XCTestCase
{
    ESPlistRequestDescriptorFactory * factory;

    NSDictionary<NSString *, RKMapping *> *mappingMap;

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


- (void)testInitWithEmptyMappingThrows
{
    XCTAssertThrows([[ESPlistRequestDescriptorFactory alloc] initWithConfig:@{}]);
    XCTAssertThrows([[ESPlistRequestDescriptorFactory alloc] initWithConfig:@{}]);
}

- (void)testInitWithEmptyConfigDictionaryThrows
{
    XCTAssertThrows([[ESPlistRequestDescriptorFactory alloc] initWithConfig:nil]);
    XCTAssertThrows([[ESPlistRequestDescriptorFactory alloc] initWithConfig:@{}]);
}

- (void)testCanInitWithConfigDictionary
{
    NSDictionary * config = @{

            @"desc" : @{
            }
    };

    factory = [[ESPlistRequestDescriptorFactory alloc] initWithConfig:config];

    [self assertFactoryInitialized];
}

- (void)testCanInitWithFilepath
{
    NSString * filepath;

    @try {
        NSDictionary * conf = [ESConfigFixtures requestConfigDictionary];
        filepath = [ESConfigFixtures writeRequestFile:conf];

        factory = [[ESPlistRequestDescriptorFactory alloc] initWithFilepath:filepath];

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
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithFilename:@"Request"];

    [self assertFactoryInitialized];
}

- (void)assertFactoryInitialized
{
    XCTAssertNotNil(factory);
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
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithConfig:config];

    XCTAssertThrowsSpecificNamed([factory createDescriptorNamed:@"baz" forMappings:mappingMap], NSException, @"ConfigurationException");
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
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithConfig:config];

    XCTAssertThrowsSpecificNamed([factory createDescriptorNamed:@"desc" forMappings:mappingMap], NSException, @"PlistMalformedException");
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
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithConfig:config];

    XCTAssertThrowsSpecificNamed([factory createDescriptorNamed:@"desc" forMappings:mappingMap], NSException, @"PlistMalformedException");
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

    factory = [[ESPlistRequestDescriptorFactory alloc] initWithConfig:config];

    XCTAssertThrowsSpecificNamed([factory createDescriptorNamed:@"desc" forMappings:mappingMap], NSException, @"PlistMalformedException");
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
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithConfig:config];

    RKRequestDescriptor *descriptor = [factory createDescriptorNamed:@"desc" forMappings:mappingMap];
    RKRequestDescriptor * expectedDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:inversedFooMapping
                                                                                     objectClass:[ESFoo class]
                                                                                     rootKeyPath:@"keypath"
                                                                                          method:RKRequestMethodPOST];

    OCMStub([inversedFooMapping isEqualToMapping:OCMOCK_ANY]).andReturn(YES);

    XCTAssertTrue([expectedDescriptor isEqualToRequestDescriptor:descriptor]);
    OCMVerifyAll(fooMappingMock);
}

- (void)testDescriptorForName_withAnyMethod
{
    NSDictionary *config = @{
            @"desc": @{
                    @"keypath": @"keypath",
                    @"method" : @"Any",
                    @"mapping": @"foo",
                    @"object" : @"ESFoo"
            }
    };

    OCMExpect([fooMappingMock inverseMapping]).andReturn(inversedFooMapping);
    factory = [[ESPlistRequestDescriptorFactory alloc] initWithConfig:config];

    RKRequestDescriptor *descriptor = [factory createDescriptorNamed:@"desc" forMappings:mappingMap];
    RKRequestDescriptor *expectedDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:inversedFooMapping
                                                                                    objectClass:[ESFoo class]
                                                                                    rootKeyPath:@"keypath"
                                                                                         method:RKRequestMethodAny];

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

    factory = [[ESPlistRequestDescriptorFactory alloc] initWithConfig:config];

    NSArray<RKRequestDescriptor *> *descriptors = [factory createAllDescriptors:mappingMap];

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
