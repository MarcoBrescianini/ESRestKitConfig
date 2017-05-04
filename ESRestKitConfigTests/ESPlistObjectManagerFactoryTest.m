//
//  ESPlistObjectManagerFactoryTest.m
//  ESRestKitConfig
//
//  Created by Engineering Solutions on 09/12/2016.
//  Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

#import "ESPlistObjectManagerFactory.h"
#import "ESPlistMappingFactory.h"
#import "ESPlistResponseDescriptorFactory.h"
#import "ESPlistRoutesFactory.h"
#import "ESPlistRequestDescriptorFactory.h"
#import "ESDictionaryRoutesFactory.h"
#import "ESDictionaryRequestDescriptorFactory.h"
#import "ESDictionaryResponseDescriptorFactory.h"

@interface ESPlistObjectManagerFactoryTest : XCTestCase

@end

@implementation ESPlistObjectManagerFactoryTest
{
    NSDictionary * routesConfig;
    NSDictionary * mappingConfig;
    NSDictionary * responseConfig;
    NSDictionary * requestConfig;

    NSString * routesFilepath;
    NSString * mappingFilepath;
    NSString * responseFilepath;
    NSString * requestFilepath;
}

- (void)setUp
{
    [super setUp];

    [self createFiles];
}


- (void)tearDown
{
    [super tearDown];

    [RKObjectManager setSharedManager:nil];
    [RKManagedObjectStore setDefaultStore:nil];
    [self deleteFiles];
}


- (void)testInitWithConfig
{
    NSDictionary * config = @{
            @"baseURL" : @"https://localhost"
    };

    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];

    XCTAssertNotNil(factory);
    XCTAssertEqualObjects(config, factory.config);
}

- (void)testInitWithEmptyDictionary_throws
{
    XCTAssertThrows([[ESPlistObjectManagerFactory alloc] initWithConfig:@{}]);
}

- (void)testCreateManager_BaseUrlNotProvided_throws
{
    NSDictionary * config = @{
            @"foo" : @"bar"
    };

    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];

    XCTAssertThrowsSpecificNamed([factory createObjectManager], NSException, @"PlistMalformedException");
}

- (void)testCreateManager_withPersistentStoreInMemory
{
    NSDictionary * config = @{
            @"baseURL" : @"https://localhost",
            @"managedStore" : @{
                    @"modelName" : @"MappingTestModel",
                    @"inMemory" : @(YES)
            },
            @"routes" : routesFilepath,
            @"mappings" : mappingFilepath,
            @"responses" : responseFilepath,
    };

    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];

    RKObjectManager * manager = [factory createObjectManager];

    XCTAssertNotNil(manager);
    XCTAssertEqual([manager.HTTPClient.baseURL absoluteString], @"https://localhost");
    XCTAssertNotNil(manager.managedObjectStore);

    [self assertModelEqualsTestModel:manager.managedObjectStore.managedObjectModel];
    [self assertPersistentStoreInMemory:manager.managedObjectStore];
    [self assertManagedObjectContextCreated:manager];
}

- (void)testCreateManager_withSQLitePersistentStore
{
    NSDictionary * config = @{
            @"baseURL" : @"https://localhost",
            @"managedStore" : @{
                    @"modelName" : @"MappingTestModel",
                    @"sqliteFilename" : @"localStoreTest.sqlite"
            },
            @"routes" : routesFilepath,
            @"mappings" : mappingFilepath,
            @"responses" : responseFilepath,
    };

    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];

    RKObjectManager * manager = [factory createObjectManager];

    XCTAssertNotNil(manager);
    XCTAssertEqual([manager.HTTPClient.baseURL absoluteString], @"https://localhost");
    XCTAssertNotNil(manager.managedObjectStore);

    [self assertModelEqualsTestModel:manager.managedObjectStore.managedObjectModel];
    [self assertPersistentStoreSQLite:manager.managedObjectStore filename:@"localStoreTest.sqlite"];
    [self assertManagedObjectContextCreated:manager];
}

- (void)testCreateManager_persistentStoreInfoNotProvided
{
    NSDictionary * config = @{
            @"baseURL" : @"https://localhost",
            @"managedStore" : @{
                    @"modelName" : @"MappingTestModel",
            },
            @"routes" : routesFilepath,
            @"mappings" : mappingFilepath,
            @"responses" : responseFilepath,
    };

    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];

    XCTAssertThrowsSpecificNamed([factory createObjectManager], NSException, @"PlistMalformedException");
}

- (void)testCreateManager_withInMemoryCache
{
    NSDictionary * config = @{
            @"baseURL" : @"https://localhost",
            @"managedStore" : @{
                    @"modelName" : @"MappingTestModel",
                    @"inMemory" : @(YES),
                    @"cache" : @"memory"
            },
            @"routes" : routesFilepath,
            @"mappings" : mappingFilepath,
            @"responses" : responseFilepath,
    };

    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];

    RKObjectManager * manager = [factory createObjectManager];

    XCTAssertNotNil(manager);
    XCTAssertEqual([manager.HTTPClient.baseURL absoluteString], @"https://localhost");
    XCTAssertNotNil(manager.managedObjectStore);

    [self assertModelEqualsTestModel:manager.managedObjectStore.managedObjectModel];
    [self assertPersistentStoreInMemory:manager.managedObjectStore];
    [self assertManagedObjectContextCreated:manager];
    [self assertManagedObjectCacheInMemory:manager];
}

- (void)testCreateManager_routesAndDescriptorsLoaded
{
    NSDictionary * config = @{
            @"baseURL" : @"https://localhost",
            @"managedStore" : @{
                    @"modelName" : @"MappingTestModel",
                    @"inMemory" : @(YES)
            },
            @"routes" : routesFilepath,
            @"mappings" : mappingFilepath,
            @"responses" : responseFilepath,
            @"requests" : requestFilepath
    };



    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];
    RKObjectManager * manager = [factory createObjectManager];

    NSDictionary<NSString *, RKRoute *> * routes = [self createRoutesFromFile];
    NSDictionary<NSString *, RKMapping *> * mappings = [self createMappingsFromFile:manager];
    NSArray<RKResponseDescriptor *> * responseDescriptors = [self createResponseDescriptorsFromFileWith:mappings];
    NSArray<RKRequestDescriptor *> * requestDescriptors = [self createRequestDescriptorsFromFileWith:mappings];

    [self assertRoutes:routes addedToRouter:manager];
    [self assertResponseDescriptors:responseDescriptors addedToManager:manager];
    [self assertRequestDescriptors:requestDescriptors addedToManager:manager];
}

- (void)testCreateManager_withInlineConfiguration
{
    NSDictionary * config = @{
            @"baseURL" : @"https://localhost",
            @"managedStore" : @{
                    @"modelName" : @"MappingTestModel",
                    @"inMemory" : @(YES)
            },
            @"routes" : [self routesConfigDictionary],
            @"mappings" : [self mappingConfigDictionary],
            @"responses" : [self responseConfigDictionary],
            @"requests" : [self requestConfigDictionary]
    };


    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];
    RKObjectManager * manager = [factory createObjectManager];

    NSDictionary<NSString *, RKRoute *> * routes = [self createRoutesFromFile];
    NSDictionary<NSString *, RKMapping *> * mappings = [self createMappingsFromFile:manager];
    NSArray<RKResponseDescriptor *> * responseDescriptors = [self createResponseDescriptorsFromFileWith:mappings];
    NSArray<RKRequestDescriptor *> * requestDescriptors = [self createRequestDescriptorsFromFileWith:mappings];

    [self assertRoutes:routes addedToRouter:manager];
    [self assertResponseDescriptors:responseDescriptors addedToManager:manager];
    [self assertRequestDescriptors:requestDescriptors addedToManager:manager];
}


//===================================================================================
#pragma mark - Asserts

- (void)assertModelEqualsTestModel:(NSManagedObjectModel *)objectModel
{
    NSManagedObjectModel * model = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    NSAssert(model, @"Cannot load model");
    XCTAssertEqualObjects(objectModel, model);
}

- (void)assertPersistentStoreInMemory:(RKManagedObjectStore *)managedObjectStore
{
    NSPersistentStore * store = managedObjectStore.persistentStoreCoordinator.persistentStores.firstObject;
    XCTAssertTrue([[store.URL absoluteString] containsString:@"memory://"]);
}

- (void)assertPersistentStoreSQLite:(RKManagedObjectStore *)managedObjectStore filename:(NSString*)filename
{
    NSPersistentStore * store = managedObjectStore.persistentStoreCoordinator.persistentStores.firstObject;
    XCTAssertTrue([[store.URL absoluteString] containsString:@"file://"]);
    XCTAssertTrue([[store.URL absoluteString] containsString:filename]);
}

- (void)assertManagedObjectContextCreated:(RKObjectManager *)manager
{
    XCTAssertNotNil(manager.managedObjectStore.mainQueueManagedObjectContext);
    XCTAssertNotNil(manager.managedObjectStore.persistentStoreManagedObjectContext);
}

- (void)assertManagedObjectCacheInMemory:(RKObjectManager *)manager
{
    XCTAssertTrue([manager.managedObjectStore.managedObjectCache isKindOfClass:[RKInMemoryManagedObjectCache class]]);
}


-(void)assertRoutes:(NSDictionary<NSString*, RKRoute*> *)routes addedToRouter:(RKObjectManager*)manager
{
    XCTAssertTrue(manager.router.routeSet.allRoutes.count > 0);

    [routes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RKRoute * _Nonnull expected, BOOL * _Nonnull stop) {

        RKRoute * actual = [manager.router.routeSet routeForName:key];

        XCTAssertNotNil(actual);
        XCTAssertEqualObjects(actual.pathPattern, expected.pathPattern);
        XCTAssertEqual(actual.method, expected.method);
    }];
}

- (void)assertResponseDescriptors:(NSArray *)descriptors addedToManager:(RKObjectManager *)manager
{
    XCTAssertTrue(manager.responseDescriptors.count > 0);

    for (RKResponseDescriptor * descriptor in descriptors)
    {
        XCTAssertTrue([manager.responseDescriptors containsObject:descriptor]);
    }
}

- (void)assertRequestDescriptors:(NSArray<RKRequestDescriptor *> *)descriptors addedToManager:(RKObjectManager *)manager
{
    XCTAssertTrue(manager.requestDescriptors.count > 0);

    for (RKRequestDescriptor * requestDescriptor in descriptors)
    {
        XCTAssertTrue([manager.requestDescriptors containsObject:requestDescriptor]);
    }
}


//================================================================================
#pragma mark - Data


- (NSDictionary<NSString *, RKRoute *> *)createRoutesFromFile
{
    ESPlistRoutesFactory* routesFactory = [[ESPlistRoutesFactory alloc] initWithFilepath:routesFilepath];

    NSDictionary<NSString*, RKRoute*> * routes = [routesFactory createRoutes];
    return routes;
}

- (NSDictionary<NSString *, RKMapping *> *)createMappingsFromFile:(RKObjectManager*)manager
{
    ESPlistMappingFactory *mappingFactory = [[ESPlistMappingFactory alloc] initWithFilepath:mappingFilepath];
    NSDictionary<NSString *, RKMapping *> *mappings = [mappingFactory createMappingsInStore:manager.managedObjectStore];
    return mappings;
}

- (NSArray<RKResponseDescriptor *> *)createResponseDescriptorsFromFileWith:(NSDictionary<NSString *, RKMapping *> *)mappings
{
    ESPlistResponseDescriptorFactory *responseFactory = [[ESPlistResponseDescriptorFactory alloc] initWithFilepath:responseFilepath];

    NSArray<RKResponseDescriptor *> *descriptors = [responseFactory createAllDescriptors:mappings];
    return descriptors;
}

-(NSArray<RKRequestDescriptor*>*)createRequestDescriptorsFromFileWith:(NSDictionary<NSString *, RKMapping *> *)mappings
{
    ESPlistRequestDescriptorFactory *responseFactory = [[ESPlistRequestDescriptorFactory alloc] initWithFilepath:requestFilepath];

    NSArray<RKRequestDescriptor *> *descriptors = [responseFactory createAllDescriptors:mappings];
    return descriptors;
}

-(NSDictionary *)routesConfigDictionary
{
    return @{
            @"foo" : @{
                    @"path" : @"foo/",
                    @"method" : @"GET"

            },
            @"bar" : @{
                    @"path" : @"bar/",
                    @"method" : @"POST"
            }
    };
}

-(NSDictionary *)mappingConfigDictionary
{
    return @{
            @"foo" : @{
                    @"Identification" : @[@"identifier"],
                    @"Modification" : @"updatedAt",
                    @"Entity" : @"Foo",
                    @"Attributes" :  @{
                            @"id" : @"identifier",
                            @"firstname" : @"name",
                            @"lastname" : @"lastname",
                            @"information" : @"info",
                            @"created_at" : @"createdAt",
                            @"updated_at" : @"updatedAt"
                    }
            },
            @"bar" : @{
                    @"Identification" : @[@"identifier"],
                    @"Modification" : @"updatedAt",
                    @"Entity" : @"Bar",
                    @"Attributes" : @{
                            @"id" : @"identifier",
                            @"cost" : @"cost",
                            @"header_url" : @"headerURL",
                            @"name" : @"name",
                            @"created_at" : @"createdAt",
                            @"updated_at" : @"updatedAt"
                    }
            }
    };

}

-(NSDictionary *)responseConfigDictionary
{
    return @{

            @"foo" : @{
                    @"route" : @"foo",
                    @"keypath" : @"keypath",
                    @"method" : @"GET",
                    @"mapping" : @"foo",
                    @"statusCode" : @200
            },
            @"bar" : @{
                    @"route" : @"bar",
                    @"keypath" : @"keypath",
                    @"method" : @"POST",
                    @"mapping" : @"bar",
                    @"statusCode" : @200
            }
    };
}

-(NSDictionary *)requestConfigDictionary
{
    return @{

            @"foo" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"GET",
                    @"mapping" : @"foo",
                    @"object" : @"ESFoo"
            },
            @"bar" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"POST",
                    @"mapping" : @"bar",
                    @"object" : @"ESBar"
            }
    };
}

-(NSString *)writeRoutesFile:(NSDictionary*)config
{
    return [self writeFile:@"Routes.plist" forDictionary:config];
}


-(NSString *)writeMappingFile:(NSDictionary *)config
{
    return [self writeFile:@"Mapping.plist" forDictionary:config];
}

-(NSString *)writeResponseFile:(NSDictionary *)config
{
    return [self writeFile:@"Response.plist" forDictionary:config];
}

-(NSString *)writeRequestFile:(NSDictionary*)config
{
    return [self writeFile:@"Request.plist" forDictionary:config];
}

-(NSString*)writeFile:(NSString*)filename forDictionary:(NSDictionary*)config
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:filename];

    [config writeToFile:plistPath atomically: YES];

    return plistPath;
}

- (void)createFiles
{
    routesConfig = [self routesConfigDictionary];
    routesFilepath = [self writeRoutesFile:routesConfig];

    mappingConfig = [self mappingConfigDictionary];
    mappingFilepath = [self writeMappingFile:mappingConfig];

    responseConfig = [self responseConfigDictionary];
    responseFilepath = [self writeResponseFile:responseConfig];

    requestConfig = [self requestConfigDictionary];
    requestFilepath = [self writeRequestFile:requestConfig];
}


- (void)deleteFiles
{
    NSFileManager * filemanager = [[NSFileManager alloc] init];
    NSError* error;
    if([filemanager fileExistsAtPath:routesFilepath])
    {
        [filemanager removeItemAtPath:routesFilepath error:&error];
    }

    if([filemanager fileExistsAtPath:mappingFilepath])
    {
        [filemanager removeItemAtPath:mappingFilepath error:&error];
    }

    if([filemanager fileExistsAtPath:responseFilepath])
    {
        [filemanager removeItemAtPath:responseFilepath error:&error];
    }

    if([filemanager fileExistsAtPath:requestFilepath])
    {
        [filemanager removeItemAtPath:requestFilepath error:&error];
    }
}


@end
