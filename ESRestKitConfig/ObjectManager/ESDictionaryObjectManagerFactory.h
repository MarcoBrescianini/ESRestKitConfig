//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESObjectManagerFactory.h"

@class RKManagedObjectStore;
@class RKEntityMapping;
@class NSManagedObjectModel;

@protocol ESMappingFactory;
@protocol ESRoutesFactory;
@protocol ESResponseDescriptorFactory;
@protocol ESRequestDescriptorFactory;

NS_ASSUME_NONNULL_BEGIN

@interface ESDictionaryObjectManagerFactory : NSObject <ESObjectManagerFactory>

@property (nonatomic, strong, readonly) NSDictionary * config;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithConfig:(NSDictionary *)config;
- (instancetype)initWithConfig:(NSDictionary *)config baseURL:(nullable NSString *)baseURL;
- (instancetype)initWithConfig:(NSDictionary *)config
                       baseURL:(nullable NSString *)baseURL
                  routeFactory:(nullable id <ESRoutesFactory>)routesFactory
                mappingFactory:(nullable id <ESMappingFactory>)mappingFactory
     responseDescriptorFactory:(nullable id <ESResponseDescriptorFactory>)responseDescriptorFactory
      requestDescriptorFactory:(nullable id <ESRequestDescriptorFactory>)requestDescriptorFactory NS_DESIGNATED_INITIALIZER;

- (RKManagedObjectStore *)createManagedObjectStore:(NSDictionary *)storeConfig;
- (NSManagedObjectModel *)loadManagedObjectModel:(NSDictionary *)storeConfig;

- (void)createCoreDataStack:(NSDictionary *)storeConfig store:(RKManagedObjectStore *)store;
- (void)setupStoreCache:(NSDictionary *)storeConfig store:(RKManagedObjectStore *)store;
- (void)loadRoutesAndDescriptorsIn:(RKObjectManager *)manager;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
