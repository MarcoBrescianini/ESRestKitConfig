//
//  ESMappingFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKMapping;
@class RKManagedObjectStore;

NS_ASSUME_NONNULL_BEGIN

@protocol ESMappingFactory <NSObject>

- (RKMapping *)createMappingNamed:(NSString *)name;
- (RKMapping *)createMappingNamed:(NSString *)name inStore:(RKManagedObjectStore *)store;
- (NSArray<RKMapping *> *)createAllMappings;
- (NSArray<RKMapping *> *)createAllMappingsInStore:(RKManagedObjectStore *)store;
- (NSDictionary<NSString *, RKMapping *> *)createMappings;
- (NSDictionary<NSString *, RKMapping *> *)createMappingsInStore:(RKManagedObjectStore *)store;

@end

NS_ASSUME_NONNULL_END
