//
//  ESMappingFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKMapping;

NS_ASSUME_NONNULL_BEGIN

@protocol ESMappingFactory <NSObject>

- (RKMapping *)createMappingNamed:(NSString *)name;
- (NSArray<RKMapping*> * )createAllMappings;
- (NSDictionary<NSString *, RKMapping *> *)createMappings;

@end

NS_ASSUME_NONNULL_END
