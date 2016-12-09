//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

#import "ESDictionaryMappingFactory.h"

static NSString * const kEntityKey = @"Entity";
static NSString * const kObjectKey = @"Object";
static NSString * const kDynamicKey = @"Dynamic";
static NSString * const kMatchersKey = @"Matchers";
static NSString * const kKeyPathKey = @"keyPath";
static NSString * const kExpectedValueKey = @"expectedValue";
static NSString * const kMappingRefKey = @"mapping_ref";
static NSString * const kAttributesKey = @"Attributes";
static NSString * const kRelationshipsKey = @"Relationships";
static NSString * const kSourceKey = @"source";
static NSString * const kDestinationKey = @"destination";
static NSString * const kMappingKey = @"mapping";
static NSString * const kIdentificationKey = @"Identification";
static NSString * const kModificationKey = @"Modification";
static NSString * const kConnectionsKey = @"Connections";
static NSString * const kRelationshipNameKey = @"relationshipName";


@implementation ESDictionaryMappingFactory

- (instancetype)initWithDictionary:(NSDictionary *)config
{
    self = [self initWithDictionary:config store:nil];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)config store:(RKManagedObjectStore *)store
{
    NSAssert(config, @"Config dictionary must be provided");

    self = [super init];

    if (self)
    {
        _config = config;
        _store = store;
    }

    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Business Logic

- (NSDictionary<NSString *, RKMapping *> *)createMappings
{
    NSMutableDictionary<NSString *, RKMapping *> * mappings = [[NSMutableDictionary alloc] initWithCapacity:self.config.count];

    [self.config enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        RKMapping * mapping = [self createMappingNamed:key];

        [mappings setValue:mapping forKey:key];
    }];

    return mappings;
}

- (NSArray<RKMapping *> *)createAllMappings
{
    return [[self createMappings] allValues];
}

- (RKMapping *)createMappingNamed:(NSString *)name
{
    NSDictionary * mappingDictionary = self.config[name];

    RKMapping * mapping;
    if (mappingDictionary[kEntityKey])
        mapping = [self createEntityMappingFrom:mappingDictionary];
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
    RKDynamicMapping * mapping = [RKDynamicMapping new];

    [self addMatchersToMapping:mapping fromConf:dictionary];

    return mapping;
}

- (void)addMatchersToMapping:(RKDynamicMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSArray * matchersConf = conf[kMatchersKey];

    for (NSDictionary * matcherConf in matchersConf)
        [self addMatcherToMapping:mapping fromConf:matcherConf];
}

- (void)addMatcherToMapping:(RKDynamicMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSString * keyPath = conf[kKeyPathKey];
    id expectedValue = conf[kExpectedValueKey];
    NSString * mappingRef = conf[kMappingRefKey];
    RKMapping * objectMapping = [self createMappingNamed:mappingRef];

    if ([objectMapping isKindOfClass:[RKObjectMapping class]])
    {
        RKObjectMappingMatcher * matcher = [RKObjectMappingMatcher matcherWithKeyPath:keyPath expectedValue:expectedValue objectMapping:(RKObjectMapping *) objectMapping];

        [mapping addMatcher:matcher];
    }

}

//========================================================================================
#pragma mark - Object Mapping

- (RKObjectMapping *)createObjectMappingFrom:(NSDictionary *)dictionary
{
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:NSClassFromString(dictionary[kObjectKey])];
    [self addAttributesToMapping:mapping fromConf:dictionary];
    [self addRelationshipsToMapping:mapping conf:dictionary];
    return mapping;
}

- (void)addAttributesToMapping:(RKObjectMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSDictionary * attributesDictionary = conf[kAttributesKey];

    if (![attributesDictionary isKindOfClass:[NSDictionary class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Attributes configuration must be a dictionary"] userInfo:nil];

    if (attributesDictionary.count <= 0)
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Missing attributes for mapping"] userInfo:nil];

    [mapping addAttributeMappingsFromDictionary:attributesDictionary];
}

- (void)addRelationshipsToMapping:(RKObjectMapping *)mapping conf:(NSDictionary *)conf
{
    NSArray * relationships = conf[kRelationshipsKey];

    for (NSDictionary * relationshipConf in relationships)
    {
        RKRelationshipMapping * relationshipMapping = [self createRelationshipMappingFrom:relationshipConf];

        [mapping addPropertyMapping:relationshipMapping];
    }
}

- (RKRelationshipMapping *)createRelationshipMappingFrom:(NSDictionary *)conf
{
    NSString * sourceKeyPath = conf[kSourceKey];
    NSString * destinationKeyPath = conf[kDestinationKey];
    RKMapping * mappingForRelationship;

    if (conf[kMappingKey])
        mappingForRelationship = [self createEntityMappingFrom:conf[kMappingKey]];
    else if (conf[kMappingRefKey])
        mappingForRelationship = [self createMappingNamed:conf[kMappingRefKey]];
    else
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Mapping for relationship not found" userInfo:nil];

    RKRelationshipMapping * relationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:sourceKeyPath toKeyPath:destinationKeyPath withMapping:mappingForRelationship];
    return relationshipMapping;
}

//==================================================================================
#pragma mark - Entity Mapping

- (RKEntityMapping *)createEntityMappingFrom:(NSDictionary *)mappingDictionary
{
    return [self createEntityMappingFrom:mappingDictionary inStore:self.store];
}

- (RKEntityMapping *)createEntityMappingFrom:(NSDictionary *)mappingDictionary inStore:(RKManagedObjectStore*)store
{
    RKEntityMapping * mapping = [self createEntityMappingByNameFrom:mappingDictionary inStore:store];

    [self addAttributesToMapping:mapping fromConf:mappingDictionary];
    [self addIdentificationAttributesTo:mapping conf:mappingDictionary];
    [self addModificationAttributeTo:mapping conf:mappingDictionary];
    [self addRelationshipsToMapping:mapping conf:mappingDictionary];
    [self addConnectionsTo:mapping conf:mappingDictionary];
    return mapping;
}

- (RKEntityMapping *)instantiateEntityMappingFrom:(NSDictionary *)conf
{
    return [self createEntityMappingByNameFrom:conf inStore:self.store];
}

-(RKEntityMapping *)createEntityMappingByNameFrom:(NSDictionary *)conf inStore:(RKManagedObjectStore * )store
{
    NSParameterAssert(store);

    NSString * entityName = conf[kEntityKey];

    if (![entityName isKindOfClass:[NSString class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Entity name must be a string: %@", entityName] userInfo:nil];


    if ([entityName isEqualToString:[NSString string]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Missing entity name for mapping"] userInfo:nil];

    return [RKEntityMapping mappingForEntityForName:entityName inManagedObjectStore:store];
}

- (void)addIdentificationAttributesTo:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    id idAttr = conf[kIdentificationKey];

    if([idAttr isKindOfClass:[NSString class]])
    {
        idAttr = @[idAttr];
    }

    if (![idAttr isKindOfClass:[NSArray class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Identification attributes must be provided in array"] userInfo:nil];

    if ([idAttr count] > 0)
        [mapping setIdentificationAttributes:idAttr];
}

- (void)addModificationAttributeTo:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    id modificationAttribute = conf[kModificationKey];

    if (![modificationAttribute isKindOfClass:[NSString class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Modification attribute must be provided as string"] userInfo:nil];

    if (![modificationAttribute isEqualToString:@""])
        [mapping setModificationAttributeForName:modificationAttribute];
}


- (void)addConnectionsTo:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    NSArray * connections = conf[kConnectionsKey];

    for (NSDictionary * connection in connections)
        [self addConnectionTo:mapping conf:connection];
}

- (void)addConnectionTo:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    NSString * relationshipName = conf[kRelationshipNameKey];
    NSString * sourceAttr = conf[kSourceKey];
    NSString * destAttr = conf[kDestinationKey];

    [mapping addConnectionForRelationship:relationshipName connectedBy:@{sourceAttr : destAttr}];
}
@end
