//
//  ESPlistResponseDescriptorFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESResponseDescriptionFactory.h"

@class RKRoute;
@class RKMapping;

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSString*, RKRoute*> *ESRouteMap;
typedef NSDictionary<NSString*, RKMapping*> *ESMappingMap;

@interface ESPlistResponseDescriptorFactory : NSObject<ESResponseDescriptionFactory>

@property (nonatomic, strong, readonly, nonnull) ESRouteMap routes; //TODO: SHOULD BE READWRITE AND MOVED IN INTERFACE
@property (nonatomic, strong, readonly, nonnull) ESMappingMap mappings; //TODO: SHOULD BE READWRITE AND MOVED IN INTERFACE
@property (nonatomic, strong, readonly, nonnull) NSDictionary * config;

-(instancetype)initWithRoutes:(ESRouteMap)routes mappings:(ESMappingMap)mappings config:(NSDictionary*)config;
-(instancetype)initWithRoutes:(ESRouteMap)routes mappings:(ESMappingMap)mappings filepath:(NSString*)filepath;
-(instancetype)initWithRoutes:(ESRouteMap)routes mappings:(ESMappingMap)mappings fromMainBundle:(NSString*)filename;

-(RKResponseDescriptor*)createDescriptorNamed:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
