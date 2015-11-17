//
//  ESPlistMappingFactoryTest.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

#import "ESPlistMappingFactory.h"
#import "ESConfigFixtures.h"

@interface ESPlistMappingFactoryTest : XCTestCase
{
    ESPlistMappingFactory *factory;

    NSString *fooEntityName;
    NSDictionary<NSString *, NSString *> *fooAttributes;
    NSArray<NSString *> *fooIdentificationAttrs;
    NSString *fooModificationAttr;

    NSString *barEntityName;
    NSDictionary<NSString *, NSString *> *barAttributes;
    NSArray<NSString *> *barIdentificationAttrs;
    NSString *barModificationAttr;

    NSString *multipleEntityName;
    NSDictionary<NSString *, NSString *> *multipleAttributes;
    NSArray<NSString *> *multipleIdentificationAttrs;
    NSString *multipleModificationAttr;
}

@end

@implementation ESPlistMappingFactoryTest


static NSManagedObjectModel *managedObjectModel;
static RKManagedObjectStore *managedObjectStore;

+ (void)setUp
{
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle bundleForClass:[self class]]]];
    NSAssert(managedObjectModel, @"Managed Model Not Found");

    managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    [managedObjectStore createPersistentStoreCoordinator];

    NSError *error;
    NSPersistentStore *ps = [managedObjectStore addInMemoryPersistentStore:&error];
    NSAssert(ps, @"Failed to add persistent store with error: %@", error);

    [managedObjectStore createManagedObjectContexts];
}

+ (void)tearDown
{
    managedObjectStore = nil;
    managedObjectModel = nil;
}

- (void)setUp
{
    [super setUp];


    fooAttributes = @{
            @"id"          : @"identifier",
            @"firstname"   : @"name",
            @"lastname"    : @"lastname",
            @"information" : @"info",
            @"created_at"  : @"createdAt",
            @"updated_at"  : @"updatedAt"
    };
    fooIdentificationAttrs = @[@"identifier"];
    fooEntityName = @"Foo";
    fooModificationAttr = @"updatedAt";

    barAttributes = @{
            @"id"         : @"identifier",
            @"cost"       : @"cost",
            @"header_url" : @"headerURL",
            @"name"       : @"name",
            @"created_at" : @"createdAt",
            @"updated_at" : @"updatedAt"
    };
    barIdentificationAttrs = @[@"identifier"];
    barEntityName = @"Bar";
    barModificationAttr = @"updatedAt";

    multipleEntityName = @"Multiple";
    multipleAttributes = @{
            @"id"         : @"identifier",
            @"name"       : @"name",
            @"detail"     : @"detail",
            @"created_at" : @"createdAt",
            @"updated_at" : @"updatedAt"
    };

    multipleIdentificationAttrs = @[@"identifier"];
    multipleModificationAttr = @"updatedAt";
}

- (void)testInitNilStoreThrows
{
    XCTAssertThrows([[ESPlistMappingFactory alloc] initWithDictionary:@{} store:nil]);
}

#warning Skipped Test
- (void)_testInitFromMainBundle
{
    factory = [[ESPlistMappingFactory alloc] initFromMainBundle:@"Mapping" store:managedObjectStore];

    XCTAssertNotNil(factory);
    XCTAssertNotNil(factory.config);
}

- (void)testInitWithPlistFile
{
    NSString *filepath;

    @try
    {
        NSDictionary *config = [ESConfigFixtures mappingConfigDictionary];
        filepath = [ESConfigFixtures writeMappingFile:config];

        factory = [[ESPlistMappingFactory alloc] initWithPlistFile:filepath store:managedObjectStore];

        XCTAssertNotNil(factory);
        XCTAssertNotNil(factory.config);

    }
    @finally
    {

        if (filepath)
        {
            NSFileManager *manager = [NSFileManager new];
            if ([manager fileExistsAtPath:filepath])
            {
                [manager removeItemAtPath:filepath error:nil];
            }
        }
    }
}

- (void)testInitWithDictionary
{
    factory = [[ESPlistMappingFactory alloc] initWithDictionary:@{} store:managedObjectStore];

    XCTAssertNotNil(factory);
    XCTAssertNotNil(factory.config);
}

- (void)testInitWithNotExistingFilePathThrows
{
    XCTAssertThrows([[ESPlistMappingFactory alloc] initFromMainBundle:@"Not existing" store:managedObjectStore]);
}

- (void)testInitWithNilDictionaryThrows
{
    XCTAssertThrows([[ESPlistMappingFactory alloc] initWithDictionary:nil store:managedObjectStore]);
}

//TODO: Gestire le relazioni. Ossia i mapping referenziati nei mapping di relazione non devono essere ricorsivi

- (void)testMappingWithName
{
    //Given

    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Modification"   : fooModificationAttr,
                    @"Entity"         : fooEntityName,
                    @"Attributes"     : fooAttributes
            }
    };


    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];


    //When
    RKEntityMapping *mapping = [factory mappingWithName:@"foo"];

    //Then
    [self assertMapping:mapping equalsExpectedConfig:conf[@"foo"]];

    //TODO: TEST VALUE TRANSFORMERS ADDED PROPERLY!!!
}

- (void)testMissingEntityName
{
    NSDictionary *conf = @{

            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Attributes"     : fooAttributes
            }
    };


    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];
    XCTAssertThrowsSpecificNamed([factory mappingWithName:@"foo"], NSException, @"PlistMalformedException");
}

- (void)testEntityNameNotString
{
    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Attributes"     : @[[fooAttributes allValues]],
                    @"Entity"         : @[fooEntityName]
            }
    };
    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];
    XCTAssertThrowsSpecificNamed([factory mappingWithName:@"foo"], NSException, @"PlistMalformedException");
}

- (void)testMissingAttributes
{
    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Entity"         : fooEntityName
            }
    };

    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];
    XCTAssertThrowsSpecificNamed([factory mappingWithName:@"foo"], NSException, @"PlistMalformedException");
}

- (void)testAttributesKeyPathNotDictionary
{
    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Attributes"     : @[[fooAttributes allValues]],
                    @"Entity"         : fooEntityName
            }
    };
    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];
    XCTAssertThrowsSpecificNamed([factory mappingWithName:@"foo"], NSException, @"PlistMalformedException");
}

- (void)testIdentificationAttributesKeyPathNotArray
{
    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : @"string",
                    @"Attributes"     : fooAttributes,
                    @"Entity"         : fooEntityName
            }
    };
    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];
    XCTAssertThrowsSpecificNamed([factory mappingWithName:@"foo"], NSException, @"PlistMalformedException");

}

- (void)testModificationAttributeKeyPathNotString
{
    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Modification"   : @[fooModificationAttr],
                    @"Entity"         : fooEntityName,
                    @"Attributes"     : fooAttributes
            }
    };

    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];
    XCTAssertThrowsSpecificNamed([factory mappingWithName:@"foo"], NSException, @"PlistMalformedException");

}

- (void)testMappingWithRelationship_inlineMapping
{

    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Modification"   : fooModificationAttr,
                    @"Entity"         : fooEntityName,
                    @"Attributes"     : fooAttributes,
                    @"Relationships"  : @[
                            @{
                                    @"source"      : @"sourceKeyPath",
                                    @"destination" : @"destinationKeyPath",
                                    @"mapping"     : @{
                                            @"Identification" : multipleIdentificationAttrs,
                                            @"Modification"   : multipleModificationAttr,
                                            @"Entity"         : multipleEntityName,
                                            @"Attributes"     : multipleAttributes
                                    }
                            }
                    ]
            },
    };


    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];

    RKEntityMapping *mapping = [factory mappingWithName:@"foo"];

    [self assertRelationships:mapping equalsDefinedInConf:conf];
}


- (void)testMappingWithRelationship_mappingReference
{
    NSDictionary *conf = @{
            @"foo"      : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Modification"   : fooModificationAttr,
                    @"Entity"         : fooEntityName,
                    @"Attributes"     : fooAttributes,
                    @"Relationships"  : @[
                            @{
                                    @"source"      : @"sourceKeyPath",
                                    @"destination" : @"destinationKeyPath",
                                    @"mapping_ref" : @"multiple"
                            }
                    ]
            },
            @"multiple" : @{
                    @"Identification" : multipleIdentificationAttrs,
                    @"Modification"   : multipleModificationAttr,
                    @"Entity"         : multipleEntityName,
                    @"Attributes"     : multipleAttributes,
            }
    };

    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];

    RKEntityMapping *mapping = [factory mappingWithName:@"foo"];

    [self assertRelationships:mapping equalsDefinedInConf:conf];

}


-(void)testMappingWithConnections
{
    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Modification"   : fooModificationAttr,
                    @"Entity"         : fooEntityName,
                    @"Attributes"     : fooAttributes,
                    @"Connections"  : @[
                            @{
                                    @"relationshipName" : @"bar",
                                    @"source"      : @"barId",
                                    @"destination" : @"identifier",

                            }
                    ]
            },
    };

    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];

    RKEntityMapping *mapping = [factory mappingWithName:@"foo"];

    NSArray * connections = [mapping connections];

    RKConnectionDescription * connection = [connections firstObject];

    NSEntityDescription * fooEntity = [NSEntityDescription entityForName:@"Foo"
                inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
    NSEntityDescription * barEntity = [NSEntityDescription entityForName:@"Bar"
                                                  inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
    NSArray * relationships = [fooEntity relationshipsWithDestinationEntity:barEntity];
    XCTAssertEqualObjects(connection.relationship, [relationships firstObject]);
    XCTAssertEqualObjects(connection.attributes, @{@"barId" : @"identifier"});
}

- (void)testCreateMappings
{
    NSDictionary *conf = @{
            @"foo" : @{
                    @"Identification" : fooIdentificationAttrs,
                    @"Modification"   : fooModificationAttr,
                    @"Entity"         : fooEntityName,
                    @"Attributes"     : fooAttributes
            },
            @"bar" : @{
                    @"Identification" : barIdentificationAttrs,
                    @"Modification"   : barModificationAttr,
                    @"Entity"         : barEntityName,
                    @"Attributes"     : barAttributes
            }
    };


    factory = [[ESPlistMappingFactory alloc] initWithDictionary:conf store:managedObjectStore];


    //When
    NSDictionary<NSString *, RKEntityMapping *> *mappings = [factory createMappings];

    XCTAssertNotNil(mappings);
    XCTAssertTrue(mappings.count > 0);

    [mappings enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, RKEntityMapping *_Nonnull obj, BOOL *_Nonnull stop) {

        [self assertMapping:obj equalsExpectedConfig:conf[key]];
    }];
}


- (void)assertMapping:(RKEntityMapping *)mapping equalsExpectedConfig:(NSDictionary *)config
{
    [self assertEntityNameInMapping:mapping equals:config[@"Entity"]];
    [self assertAttributeFromMapping:mapping equalsAttributes:config[@"Attributes"]];
    [self assertIdentificationAttributesFromMapping:mapping equals:config[@"Identification"]];
    [self assertModificationAttrForMapping:mapping equals:config[@"Modification"]];
}

- (void)assertEntityNameInMapping:(RKEntityMapping *)mapping equals:(NSString *)entity
{
    NSEntityDescription *expectedEntity = [NSEntityDescription entityForName:entity
                                                      inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
    XCTAssertEqualObjects(mapping.entity.name, expectedEntity.name);
}

- (void)assertAttributeFromMapping:(RKEntityMapping *)mapping
                  equalsAttributes:(NSDictionary<NSString *, NSString *> *)expectedAttributes
{
    XCTAssertEqual(expectedAttributes.count, mapping.attributeMappings.count);

    for (RKPropertyMapping *property in mapping.attributeMappings)
    {
        NSString *destinationKeyPath = [expectedAttributes objectForKey:property.sourceKeyPath];
        XCTAssertNotNil(destinationKeyPath);
        XCTAssertEqualObjects(destinationKeyPath, property.destinationKeyPath);
    }
}

- (void)assertIdentificationAttributesFromMapping:(RKEntityMapping *)mapping equals:(NSArray<NSString *> *)identifiers
{
    NSArray *mappingIdentificationAttributes = mapping.identificationAttributes;

    XCTAssertEqual(mappingIdentificationAttributes.count, identifiers.count);

    for (NSString *identifier in identifiers)
    {
        NSAttributeDescription *attributeDesc = mapping.entity.attributesByName[identifier];
        XCTAssertNotNil(attributeDesc);
        XCTAssertTrue([mappingIdentificationAttributes containsObject:attributeDesc]);
    }
}

- (void)assertModificationAttrForMapping:(RKEntityMapping *)mapping equals:(NSString *)attribute
{
    NSAttributeDescription *attrDesc = mapping.entity.attributesByName[attribute];
    XCTAssertNotNil(attrDesc);
    XCTAssertNotNil(mapping.modificationAttribute);
    XCTAssertEqualObjects(mapping.modificationAttribute, attrDesc);
}

- (void)assertRelationships:(RKEntityMapping *)mapping equalsDefinedInConf:(NSDictionary *)conf
{
    for (NSInteger i = 0; i < mapping.relationshipMappings.count; ++i)
    {
        RKRelationshipMapping *relationshipMapping = [mapping.relationshipMappings objectAtIndex:i];

        XCTAssertNotNil(relationshipMapping);

        XCTAssertEqualObjects(relationshipMapping.sourceKeyPath, conf[@"foo"][@"Relationships"][i][@"source"]);
        XCTAssertEqualObjects(relationshipMapping.destinationKeyPath, conf[@"foo"][@"Relationships"][i][@"destination"]);

        if (conf[@"foo"][@"Relationships"][i][@"mapping"])
        {
            [self assertMapping:(RKEntityMapping *) relationshipMapping.mapping
           equalsExpectedConfig:conf[@"foo"][@"Relationships"][i][@"mapping"]];
        } else if (conf[@"foo"][@"Relationships"][i][@"mapping_ref"])
        {
            [self assertMapping:(RKEntityMapping *) relationshipMapping.mapping
           equalsExpectedConfig:conf[conf[@"foo"][@"Relationships"][i][@"mapping_ref"]]];
        } else
        {
            XCTFail(@"Mapping conf not found");
        }
    }
}

@end
