//
//  ESRoutesFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKRoute;

NS_ASSUME_NONNULL_BEGIN

@protocol ESRoutesFactory <NSObject>

- (NSDictionary<NSString *, RKRoute *> *)createRoutes;
- (RKRoute *)createRouteNamed:(NSString *)routeName;
- (NSArray<RKRoute*> * )createAllRoutes;

@end

NS_ASSUME_NONNULL_END
