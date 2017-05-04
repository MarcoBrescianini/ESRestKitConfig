//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESMappingFactory.h"

@class RKManagedObjectStore;
@class RKDynamicMapping;
@class RKObjectMapping;
@class RKEntityMapping;

NS_ASSUME_NONNULL_BEGIN

@interface ESDictionaryMappingFactory : NSObject <ESMappingFactory>

@property (nonatomic, strong, readonly) NSDictionary * config;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDictionary:(NSDictionary *)config NS_DESIGNATED_INITIALIZER;

- (RKDynamicMapping *)createDynamicMappingFrom:(NSDictionary *)dictionary inStore:(RKManagedObjectStore *)store;
- (RKObjectMapping *)createObjectMappingFrom:(NSDictionary *)dictionary inStore:(RKManagedObjectStore *)store;
- (RKEntityMapping *)createEntityMappingFrom:(NSDictionary *)mappingDictionary inStore:(RKManagedObjectStore *)store;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
