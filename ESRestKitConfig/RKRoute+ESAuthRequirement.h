//
// Created by Marco Brescianini on 26/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface RKRoute (ESAuthRequirement)


@property (nonatomic, assign, readonly, getter=isAuthRequired) BOOL authRequired;
@property (nonatomic, copy, readonly) NSString * authScope;


+ (instancetype)routeWithName:(NSString *)name pathPattern:(NSString *)pathPattern method:(RKRequestMethod)method authRequired:(BOOL)authRequired authScope:(NSString *)scope;
+ (instancetype)routeWithClass:(Class)objectClass pathPattern:(NSString *)pathPattern method:(RKRequestMethod)method authRequired:(BOOL)authRequired authScope:(NSString *)scope;
+ (instancetype)routeWithRelationshipName:(NSString *)relationshipName objectClass:(Class)objectClass pathPattern:(NSString *)pathPattern method:(RKRequestMethod)method authRequired:(BOOL)authRequired authScope:(NSString *)scope;

@end
