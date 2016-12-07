//
//  ESRoutesFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKRoute;

@protocol ESRoutesFactory <NSObject>

-(NSDictionary<NSString*, RKRoute*>*)createRoutes;
-(RKRoute*)createRouteNamed:(NSString*)routeName;

@end
