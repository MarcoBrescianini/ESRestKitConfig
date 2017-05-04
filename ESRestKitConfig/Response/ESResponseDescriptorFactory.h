//
//  ESResponseDescriptorFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKResponseDescriptor;
@class RKMapping;

NS_ASSUME_NONNULL_BEGIN

@protocol ESResponseDescriptorFactory <NSObject>

- (NSArray<RKResponseDescriptor *> *)createAllDescriptors:(NSDictionary<NSString *, RKMapping *> *)mappings;
- (RKResponseDescriptor *)createDescriptorNamed:(NSString *)name forMappings:(NSDictionary<NSString *, RKMapping *> *)mappings;

@end

NS_ASSUME_NONNULL_END
