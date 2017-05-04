//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

#import "ESDictionaryMappingFactory.h"

static NSString *const kEntityKey = @"Entity";
static NSString *const kObjectKey = @"Object";
static NSString *const kDynamicKey = @"Dynamic";
static NSString *const kMatchersKey = @"Matchers";
static NSString *const kKeyPathKey = @"keyPath";
static NSString *const kExpectedValueKey = @"expectedValue";
static NSString *const kMappingRefKey = @"mapping_ref";
static NSString *const kAttributesKey = @"Attributes";
static NSString *const kRelationshipsKey = @"Relationships";
static NSString *const kSourceKey = @"source";
static NSString *const kDestinationKey = @"destination";
static NSString *const kMappingKey = @"mapping";
static NSString *const kIdentificationKey = @"Identification";
static NSString *const kModificationKey = @"Modification";
static NSString *const kConnectionsKey = @"Connections";
static NSString *const kRelationshipNameKey = @"relationshipName";


@implementation ESDictionaryMappingFactory

- (instancetype)initWithDictionary:(NSDictionary *)config
{
    NSAssert(config, @"Config dictionary must be provided");

    self = [super init];

    if (self)
    {
        _config = config;
    }

    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Business Logic

- (NSDictionary<NSString *, RKMapping *> *)createMappings
{
    return [self createMappingsInStore:nil];
}

- (NSDictionary<NSString *, RKMapping *> *)createMappingsInStore:(RKManagedObjectStore *)store
{
    NSMutableDictionary<NSString *, RKMapping *> *mappings = [[NSMutableDictionary alloc] initWithCapacity:self.config.count];

    [self.config enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        RKMapping *mapping = [self createMappingNamed:key inStore:store];

        [mappings setValue:mapping forKey:key];
    }];

    return mappings;
}


- (NSArray<RKMapping *> *)createAllMappings
{
    return [self createAllMappingsInStore:nil];
}

- (NSArray<RKMapping *> *)createAllMappingsInStore:(RKManagedObjectStore *)store
{
    return [[self createMappingsInStore:store] allValues];
}


- (RKMapping *)createMappingNamed:(NSString *)name
{
    NSDictionary *mappingDictionary = self.config[name];

    return [self createMappingFromDictionary:mappingDictionary];
}

- (RKMapping *)createMappingFromDictionary:(NSDictionary *)mappingDictionary
{
    return [self createMappingFromDictionary:mappingDictionary inStore:nil];
}

- (RKMapping *)createMappingNamed:(NSString *)name inStore:(RKManagedObjectStore *)store
{
    NSDictionary *mappingDictionary = self.config[name];

    return [self createMappingFromDictionary:mappingDictionary inStore:store];
}

- (RKMapping *)createMappingFromDictionary:(NSDictionary *)mappingDictionary inStore:(RKManagedObjectStore *)store
{
    RKMapping *mapping;
    if (mappingDictionary[kEntityKey])
        mapping = [self createEntityMappingFrom:mappingDictionary inStore:store];
    else if (mappingDictionary[kObjectKey])
        mapping = [self createObjectMappingFrom:mappingDictionary];
    else if (mappingDictionary[kDynamicKey])
        mapping = [self createDynamicMappingFrom:mappingDictionary];
    else
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Mapping Target type not specified should be either Object, Entity or Dynamic" userInfo:nil];

    return mapping;
}

//============================================================================
#pragma mark - Dynamic Mapping

- (RKDynamicMapping *)createDynamicMappingFrom:(NSDictionary *)dictionary
{
    RKDynamicMapping *mapping = [RKDynamicMapping new];

    [self addMatchersToMapping:mapping fromConf:dictionary];

    return mapping;
}

- (void)addMatchersToMapping:(RKDynamicMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSArray *matchersConf = conf[kMatchersKey];

    for (NSDictionary *matcherConf in matchersConf)
        [self addMatcherToMapping:mapping fromConf:matcherConf];
}

- (void)addMatcherToMapping:(RKDynamicMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSString *keyPath = conf[kKeyPathKey];
    id expectedValue = conf[kExpectedValueKey];
    NSString *mappingRef = conf[kMappingRefKey];
    RKMapping *objectMapping = [self createMappingNamed:mappingRef];

    if ([objectMapping isKindOfClass:[RKObjectMapping class]])
    {
        RKObjectMappingMatcher *matcher = [RKObjectMappingMatcher matcherWithKeyPath:keyPath expectedValue:expectedValue objectMapping:(RKObjectMapping *) objectMapping];

        [mapping addMatcher:matcher];
    }

}

//========================================================================================
#pragma mark - Object Mapping

- (RKObjectMapping *)createObjectMappingFrom:(NSDictionary *)dictionary
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:NSClassFromString(dictionary[kObjectKey])];
    [self addAttributesToMapping:mapping fromConf:dictionary];
    [self addRelationshipsToMapping:mapping conf:dictionary inStore:nil];

    NSNumber *forceCollection = dictionary[@"ForceCollection"];

    if ([forceCollection boolValue])
    {
        mapping.forceCollectionMapping = YES;
    }

    return mapping;
}

- (void)addAttributesToMapping:(RKObjectMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSDictionary *attributesDictionary = conf[kAttributesKey];

    if (![attributesDictionary isKindOfClass:[NSDictionary class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Attributes configuration must be a dictionary, an empty dictionary is allowed"] userInfo:nil];

    if (attributesDictionary.count > 0)
        [mapping addAttributeMappingsFromDictionary:attributesDictionary];
}

- (void)addRelationshipsToMapping:(RKObjectMapping *)mapping conf:(NSDictionary *)conf inStore:(RKManagedObjectStore *)store
{
    NSArray *relationships = conf[kRelationshipsKey];

    for (NSDictionary *relationshipConf in relationships)
    {
        RKRelationshipMapping *relationshipMapping = [self createRelationshipMappingFrom:relationshipConf inStore:store];

        [mapping addPropertyMapping:relationshipMapping];
    }
}

- (RKRelationshipMapping *)createRelationshipMappingFrom:(NSDictionary *)conf inStore:(RKManagedObjectStore *)store
{
    NSString *sourceKeyPath = conf[kSourceKey];
    NSString *destinationKeyPath = conf[kDestinationKey];
    RKMapping *mappingForRelationship;

    if (conf[kMappingKey])
        mappingForRelationship = [self createMappingFromDictionary:conf[kMappingKey] inStore:store];
    else if (conf[kMappingRefKey])
        mappingForRelationship = [self createMappingNamed:conf[kMappingRefKey] inStore:store];
    else
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Mapping for relationship not found" userInfo:nil];

    RKRelationshipMapping *relationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:sourceKeyPath toKeyPath:destinationKeyPath withMapping:mappingForRelationship];
    return relationshipMapping;
}

//==================================================================================
#pragma mark - Entity Mapping

- (RKEntityMapping *)createEntityMappingFrom:(NSDictionary *)mappingDictionary inStore:(RKManagedObjectStore *)store
{
    RKEntityMapping *mapping = [self createEntityMappingByNameFrom:mappingDictionary inStore:store];

    [self addAttributesToMapping:mapping fromConf:mappingDictionary];
    [self addIdentificationAttributesTo:mapping conf:mappingDictionary];
    [self addModificationAttributeTo:mapping conf:mappingDictionary];
    [self addRelationshipsToMapping:mapping conf:mappingDictionary inStore:store];
    [self addConnectionsTo:mapping conf:mappingDictionary];
    return mapping;
}

- (RKEntityMapping *)createEntityMappingByNameFrom:(NSDictionary *)conf inStore:(RKManagedObjectStore *)store
{
    NSParameterAssert(store);

    NSString *entityName = conf[kEntityKey];

    if (![entityName isKindOfClass:[NSString class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Entity name must be a string: %@", entityName] userInfo:nil];


    if ([entityName isEqualToString:[NSString string]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Missing entity name for mapping"] userInfo:nil];

    return [RKEntityMapping mappingForEntityForName:entityName inManagedObjectStore:store];
}

- (void)addIdentificationAttributesTo:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    id identificationAttribute = conf[kIdentificationKey];

    if (!identificationAttribute)
        return;

    if ([identificationAttribute isKindOfClass:[NSString class]])
    {
        if ([identificationAttribute isEqualToString:@""])
            return;

        identificationAttribute = @[identificationAttribute];
    }

    if (![identificationAttribute isKindOfClass:[NSArray class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Identification attributes must be provided in array"] userInfo:nil];

    if ([identificationAttribute count] > 0)
        [mapping setIdentificationAttributes:identificationAttribute];
}

- (void)addModificationAttributeTo:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    id modificationAttribute = conf[kModificationKey];

    if (!modificationAttribute)
        return;

    if (![modificationAttribute isKindOfClass:[NSString class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Modification attribute must be provided as string"] userInfo:nil];

    if (![modificationAttribute isEqualToString:@""])
        [mapping setModificationAttributeForName:modificationAttribute];
}


- (void)addConnectionsTo:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    NSArray *connections = conf[kConnectionsKey];

    for (NSDictionary *connection in connections)
        [self addConnectionTo:mapping conf:connection];
}

- (void)addConnectionTo:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    NSString *relationshipName = conf[kRelationshipNameKey];
    NSString *sourceAttr = conf[kSourceKey];
    NSString *destAttr = conf[kDestinationKey];

    [mapping addConnectionForRelationship:relationshipName connectedBy:@{sourceAttr: destAttr}];
}
@end
