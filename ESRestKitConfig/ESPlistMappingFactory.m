//
//  ESPlistMappingFactory.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ESPlistMappingFactory.h"

@implementation ESPlistMappingFactory

//-------------------------------------------------------------------------------------------
#pragma mark - Inits

- (instancetype)initFromMainBundle:(NSString *)filename store:(RKManagedObjectStore *)store
{
    NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];

    if (!path)
        @throw [NSException exceptionWithName:@"PlistNotFoundException" reason:@"File not found" userInfo:nil];

    return [self initWithPlistFile:path store:store];
}

- (instancetype)initWithPlistFile:(NSString *)filepath store:(RKManagedObjectStore *)store
{
    return [self initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filepath] store:store];
}

- (instancetype)initWithDictionary:(NSDictionary *)config store:(RKManagedObjectStore *)store
{
    NSAssert(store, @"A managed object store must be provided");
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

- (RKMapping *)createMappingNamed:(NSString *)name
{
    NSDictionary * mappingDictionary = self.config[name];

    RKMapping * mapping;
    if (mappingDictionary[@"Entity"])
        mapping = [self createEntityMappingFrom:mappingDictionary];
    else if (mappingDictionary[@"Object"])
        mapping = [self createObjectMappingFrom:mappingDictionary];
    else if (mappingDictionary[@"Dynamic"])
        mapping = [self createDynamicMappingFrom:mappingDictionary];
    else
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Mapping Target type not specified should be either Object, Entity or Dynamic" userInfo:nil];

    return mapping;
}

- (RKMapping *)createDynamicMappingFrom:(NSDictionary *)dictionary
{
    RKDynamicMapping * mapping = [RKDynamicMapping new];

    [self addMatchersToMapping:mapping fromConf:dictionary];

    return mapping;
}

- (void)addMatchersToMapping:(RKDynamicMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSArray * matchersConf = conf[@"Matchers"];

    for (NSDictionary * matcherConf in matchersConf)
    {
        [self addMatcherToMapping:mapping fromConf:matcherConf];
    }
}

- (void)addMatcherToMapping:(RKDynamicMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSString * keyPath = conf[@"keyPath"];
    id expectedValue = conf[@"expectedValue"];
    NSString * mappingRef = conf[@"mapping_ref"];
    RKMapping * objectMapping = [self createMappingNamed:mappingRef];

    if ([objectMapping isKindOfClass:[RKObjectMapping class]])
    {
        RKObjectMappingMatcher * matcher = [RKObjectMappingMatcher matcherWithKeyPath:keyPath expectedValue:expectedValue objectMapping:(RKObjectMapping *) objectMapping];

        [mapping addMatcher:matcher];
    }

}

- (RKObjectMapping *)createObjectMappingFrom:(NSDictionary *)dictionary
{
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:NSClassFromString(dictionary[@"Object"])];
    [self addAttributesToMapping:mapping fromConf:dictionary];
    [self addRelationshipsToMapping:mapping conf:dictionary];
    return mapping;
}

- (RKEntityMapping *)createEntityMappingFrom:(NSDictionary *)mappingDictionary
{
    RKEntityMapping * mapping = [self createEntityMappingFromConf:mappingDictionary];

    [self addAttributesToMapping:mapping fromConf:mappingDictionary];
    [self addIdentificationAttributesToMapping:mapping conf:mappingDictionary];
    [self addModificationAttributeToMapping:mapping conf:mappingDictionary];
    [self addRelationshipsToMapping:mapping conf:mappingDictionary];
    [self addConnectionsToMapping:mapping conf:mappingDictionary];
    return mapping;
}

- (RKEntityMapping *)createEntityMappingFromConf:(NSDictionary *)conf
{
    NSString * entityName = conf[@"Entity"];

    if (![entityName isKindOfClass:[NSString class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Entity name must be a string: %@", entityName] userInfo:nil];


    if (!entityName || [entityName isEqualToString:[NSString string]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Missing entity name for mapping"] userInfo:nil];

    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:conf[@"Entity"] inManagedObjectStore:self.store];
    return mapping;
}

- (void)addAttributesToMapping:(RKObjectMapping *)mapping fromConf:(NSDictionary *)conf
{
    NSDictionary * attributesDictionary = conf[@"Attributes"];

    if (![attributesDictionary isKindOfClass:[NSDictionary class]])
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Attributes configuration must be a dictionary"] userInfo:nil];

    if (!attributesDictionary || attributesDictionary.count <= 0)
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Missing attributes for mapping"] userInfo:nil];

    [mapping addAttributeMappingsFromDictionary:attributesDictionary];
}


- (void)addIdentificationAttributesToMapping:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    NSArray * identificationAttributes = conf[@"Identification"];

    if (identificationAttributes && ![identificationAttributes isKindOfClass:[NSArray class]])
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Identification attributes must be provided in array"] userInfo:nil];
    }

    if (identificationAttributes && identificationAttributes.count > 0)
    {
        [mapping setIdentificationAttributes:identificationAttributes];
    }
}

- (void)addModificationAttributeToMapping:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    NSString * modificationAttribute = conf[@"Modification"];

    if (modificationAttribute && ![modificationAttribute isKindOfClass:[NSString class]])
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:[NSString stringWithFormat:@"Modification attribute must be provided as string"] userInfo:nil];
    }

    if (modificationAttribute && ![modificationAttribute isEqualToString:@""])
    {
        [mapping setModificationAttributeForName:modificationAttribute];
    }
}

- (void)addRelationshipsToMapping:(RKObjectMapping *)mapping conf:(NSDictionary *)conf
{
    NSArray * relationships = conf[@"Relationships"];

    for (NSDictionary * relationshipConf in relationships)
    {
        RKRelationshipMapping * relationshipMapping = [self createRelationshipMappingFrom:relationshipConf];

        [mapping addPropertyMapping:relationshipMapping];
    }
}

- (RKRelationshipMapping *)createRelationshipMappingFrom:(NSDictionary *)conf
{
    NSString * sourceKeyPath = conf[@"source"];
    NSString * destinationKeyPath = conf[@"destination"];
    RKMapping * mappingForRelationship;

    if (conf[@"mapping"])
    {
        mappingForRelationship = [self createEntityMappingFrom:conf[@"mapping"]];
    } else if (conf[@"mapping_ref"])
    {
        mappingForRelationship = [self createMappingNamed:conf[@"mapping_ref"]];
    } else
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Mapping for relationship not found" userInfo:nil];
    }

    RKRelationshipMapping * relationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:sourceKeyPath toKeyPath:destinationKeyPath withMapping:mappingForRelationship];
    return relationshipMapping;
}

- (void)addConnectionsToMapping:(RKEntityMapping *)mapping conf:(NSDictionary *)conf
{
    NSArray * connections = conf[@"Connections"];

    for (NSDictionary * connection in connections)
    {
        NSString * relationshipName = connection[@"relationshipName"];
        NSString * sourceAttr = connection[@"source"];
        NSString * destAttr = connection[@"destination"];

        [mapping addConnectionForRelationship:relationshipName connectedBy:@{sourceAttr : destAttr}];
    }
}


- (NSDictionary<NSString *, RKMapping *> *)createMappings
{
    NSMutableDictionary<NSString *, RKMapping *> * mappings = [[NSMutableDictionary alloc] initWithCapacity:self.config.count];

    [self.config enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        RKMapping * mapping = [self createMappingNamed:key];

        [mappings setValue:mapping forKey:key];
    }];

    return mappings;
}

@end
