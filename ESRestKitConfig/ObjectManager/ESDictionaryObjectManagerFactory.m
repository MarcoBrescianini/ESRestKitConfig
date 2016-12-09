//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

#import "ESDictionaryObjectManagerFactory.h"

#import "ESPlistRequestDescriptorFactory.h"
#import "ESPlistResponseDescriptorFactory.h"
#import "ESPlistRoutesFactory.h"
#import "ESPlistMappingFactory.h"
#import "ESMappingFactory.h"
#import "ESRoutesFactory.h"
#import "ESResponseDescriptorFactory.h"
#import "ESRequestDescriptorFactory.h"


static NSString * const kBaseURLKey = @"baseURL";

static NSString * const kManagedStoreKey = @"managedStore";

static NSString * const kModelNameKey = @"modelName";

static NSString * const kInMemoryKey = @"inMemory";

static NSString * const kSQLiteNameKey = @"sqliteFilename";

static NSString * const kCacheKey = @"cache";

static NSString * const kCacheMemoryValue = @"memory";

static NSString * const kRoutesKey = @"routes";

static NSString * const kMappingsKey = @"mappings";

static NSString * const kResponsesKey = @"responses";

static NSString * const kRequestsKey = @"requests";

@implementation ESDictionaryObjectManagerFactory

- (instancetype)initWithConfig:(NSDictionary *)config
{
    NSAssert(config.count > 0, @"Must provide a non empty dictionary");

    self = [super init];

    if(self)
    {
        _config = config;
    }
    return self;
}

- (RKObjectManager *)createObjectManager
{
    NSString * urlString = self.config[kBaseURLKey];

    if(!urlString || urlString.length == 0)
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:@"Base URL not provided"
                                     userInfo:nil];

    RKObjectManager * manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:urlString]];


    NSDictionary * storeConfig = self.config[kManagedStoreKey];

    if(storeConfig && storeConfig.count > 0)
    {
        manager.managedObjectStore = [self createManagedObjectStore:storeConfig];
    }

    [self loadRoutesAndDescriptorsIn:manager];

    return manager;

}

- (RKManagedObjectStore *)createManagedObjectStore:(NSDictionary *)storeConfig
{
    NSManagedObjectModel * model = [self loadManagedObjectModel:storeConfig];

    RKManagedObjectStore * store = [[RKManagedObjectStore alloc] initWithManagedObjectModel:model];
    [self createCoreDataStack:storeConfig store:store];
    [self setupStoreCache:storeConfig store:store];

    return store;
}

- (NSManagedObjectModel *)loadManagedObjectModel:(NSDictionary *)storeConfig
{
    NSString * modelName = storeConfig[kModelNameKey];

    NSArray<NSBundle *> * bundles = [NSBundle allBundles];

    __block NSURL * managedObjectModelURL;
    [bundles enumerateObjectsUsingBlock:^(NSBundle * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            managedObjectModelURL = [obj URLForResource:modelName withExtension:@"momd"];

            if (managedObjectModelURL)
            {
                *stop = YES;
            }

        }];

    if (!managedObjectModelURL)
        {
            [bundles enumerateObjectsUsingBlock:^(NSBundle * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                managedObjectModelURL = [obj URLForResource:modelName withExtension:@"mom"];

                if (managedObjectModelURL)
                {
                    *stop = YES;
                }

            }];
        }

    return [[NSManagedObjectModel alloc] initWithContentsOfURL:managedObjectModelURL];
}

- (void)createCoreDataStack:(NSDictionary *)storeConfig store:(RKManagedObjectStore *)store
{
    [store createPersistentStoreCoordinator];

    if([storeConfig[kInMemoryKey] boolValue])
    {
        NSError * error;
        NSPersistentStore * persistentStore = [store addInMemoryPersistentStore:&error];
        NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    } else if(storeConfig[kSQLiteNameKey])
    {
        NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:storeConfig[kSQLiteNameKey]];

        NSError *error;
        NSPersistentStore *persistentStore = [store addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
        NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    } else
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:@"Must provide a persistent store filename or set inMemory flag to true"
                                     userInfo:nil];
    }

    [store createManagedObjectContexts];
}

- (void)setupStoreCache:(NSDictionary *)storeConfig store:(RKManagedObjectStore *)store
{
    if([storeConfig[kCacheKey] isEqualToString:kCacheMemoryValue])
    {
        store.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:store.persistentStoreManagedObjectContext];
    }
}

- (void)loadRoutesAndDescriptorsIn:(RKObjectManager *)manager
{
    NSDictionary<NSString *, RKRoute *> * routes = [self createRoutes];
    NSDictionary<NSString *, RKEntityMapping *> * mappings = [self createMappings:manager];
    NSArray * responseDescriptors = [self createResponseDescriptors:mappings];
    NSArray * requestDescriptors = [self createRequestDescriptors:mappings];

    [manager.router.routeSet addRoutes:routes.allValues];
    [manager addResponseDescriptorsFromArray:responseDescriptors];

    if([requestDescriptors count] > 0)
        [manager addRequestDescriptorsFromArray:requestDescriptors];
}

- (NSDictionary<NSString *, RKRoute *> *)createRoutes
{
    id<ESRoutesFactory>  routesFactory = [self createRoutesFactory];
    return [routesFactory createRoutes];
}

- (id <ESRoutesFactory>)createRoutesFactory
{
    id <ESRoutesFactory> routesFactory;

    id routes = self.config[kRoutesKey];
    if(routes)
    {
        if([routes isKindOfClass:[NSDictionary class]])
        {
            routesFactory = [[ESDictionaryRoutesFactory alloc] initWithDictionary:routes];
        }else if([routes isKindOfClass:[NSString class]])
        {
            NSArray * components = [routes pathComponents];
            if(components.count == 1)
            {
                routesFactory = [[ESPlistRoutesFactory alloc] initWithFilename:routes];
            } else
            {
                routesFactory = [[ESPlistRoutesFactory alloc] initWithFilepath:routes];
            }

        }
    } else
    {
        routesFactory = [[ESPlistRoutesFactory alloc] init];
    }
    return routesFactory;
}

- (NSDictionary<NSString *, RKMapping *> *)createMappings:(RKObjectManager *)manager
{
    id <ESMappingFactory> mappingFactory = [self createMappingsFactory:manager];
    return [mappingFactory createMappings];
}

- (id <ESMappingFactory>)createMappingsFactory:(RKObjectManager *)manager
{
    id<ESMappingFactory> mappingFactory = nil;
    RKManagedObjectStore * store = manager.managedObjectStore;

    id mappings = self.config[kMappingsKey];

    if(mappings)
    {

        if([mappings isKindOfClass:[NSDictionary class]])
        {
            mappingFactory = [[ESDictionaryMappingFactory alloc] initWithDictionary:mappings store:store];
        } else if([mappings isKindOfClass:[NSString class]])
        {
            NSArray * components = [mappings pathComponents];
            if(components.count == 1)
            {
                mappingFactory = [[ESPlistMappingFactory alloc] initWithFilename:mappings store:store];
            } else
            {
                mappingFactory = [[ESPlistMappingFactory alloc] initWithFilepath:mappings store:store];
            }

        }
    } else
    {
        mappingFactory = [[ESPlistMappingFactory alloc] initWithStore:store];
    }

    return mappingFactory;
}

- (NSArray *)createResponseDescriptors:(NSDictionary<NSString *, RKEntityMapping *> *)mappings
{
    id<ESResponseDescriptorFactory> responseFactory = [self createResponseDescriptorFactory:mappings];
    return [responseFactory createAllDescriptors];
}

- (id <ESResponseDescriptorFactory>)createResponseDescriptorFactory:(NSDictionary<NSString *, RKEntityMapping *> *)mappings
{
    id<ESResponseDescriptorFactory> responseFactory = nil;

    id response = self.config[kResponsesKey];
    if(response)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            responseFactory = [[ESDictionaryResponseDescriptorFactory alloc] initWithMappings:mappings config:response];
        } else if([response isKindOfClass:[NSString class]])
        {
            NSArray * components = [response pathComponents];
            if(components.count == 1)
            {
                responseFactory = [[ESPlistResponseDescriptorFactory alloc] initWithMappings:mappings filename:response];
            } else
            {
                responseFactory = [[ESPlistResponseDescriptorFactory alloc] initWithMappings:mappings filepath:response];
            }

        }
    } else
    {
        responseFactory = [[ESPlistResponseDescriptorFactory alloc] initWithMappings:mappings];
    }

    return responseFactory;
}

- (NSArray *)createRequestDescriptors:(NSDictionary<NSString *, RKEntityMapping *> *)mappings
{
    id<ESRequestDescriptorFactory> requestFactory = [self createRequestDescriptorFactory:mappings];
    return [requestFactory createAllDescriptors];
}

- (id <ESRequestDescriptorFactory>)createRequestDescriptorFactory:(NSDictionary<NSString *, RKEntityMapping *> *)mappings
{
    id<ESRequestDescriptorFactory> requestFactory = nil;

    id response = self.config[kRequestsKey];

    @try
    {
        if(response)
        {
            if ([response isKindOfClass:[NSDictionary class]])
            {
                requestFactory = [[ESDictionaryRequestDescriptorFactory alloc] initWithMappings:mappings config:response];
            } else if([response isKindOfClass:[NSString class]])
            {
                NSArray * components = [response pathComponents];
                if(components.count == 1)
                {
                    requestFactory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappings filename:response];
                } else
                {
                    requestFactory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappings filepath:response];
                }


            }
        } else
        {
            requestFactory = [[ESPlistRequestDescriptorFactory alloc] initWithMappings:mappings];
        }
    }
    @catch (NSException * exception)
    {
    }

    return requestFactory;
}
@end
