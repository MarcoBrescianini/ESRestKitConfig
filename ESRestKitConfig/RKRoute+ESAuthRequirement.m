//
// Created by Marco Brescianini on 26/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <objc/runtime.h>
#import "RKRoute+ESAuthRequirement.h"


@implementation RKRoute (ESAuthRequirement)

@dynamic authScope;
@dynamic authRequired;

static char kAuthScopeKey;
static char kAuthRequiredKey;

-(void)setAuthRequired:(BOOL)authRequired
{
    objc_setAssociatedObject(self,  &kAuthRequiredKey, @(authRequired), OBJC_ASSOCIATION_ASSIGN );
}


-(BOOL)isAuthRequired
{
    NSNumber * authRequired = objc_getAssociatedObject(self, &kAuthRequiredKey);
    return [authRequired boolValue];
}

-(void)setAuthScope:(NSString *)scope
{
    objc_setAssociatedObject(self,  &kAuthScopeKey, scope, OBJC_ASSOCIATION_COPY_NONATOMIC );
}

-(NSString *)authScope
{
    return objc_getAssociatedObject(self, &kAuthScopeKey);
}


-(void)setAuthRequired:(BOOL)authRequired scope:(NSString *)scope
{
    [self setAuthRequired:authRequired];
    [self setAuthScope:scope];
}

+ (instancetype)routeWithName:(NSString *)name pathPattern:(NSString *)pathPattern method:(RKRequestMethod)method
                 authRequired:(BOOL)authRequired authScope:(NSString *)scope
{
    RKRoute * route = [self routeWithName:name pathPattern:pathPattern method:method];
    [route setAuthRequired:authRequired scope:scope];
    return route;
}

+ (instancetype)routeWithClass:(Class)objectClass pathPattern:(NSString *)pathPattern method:(RKRequestMethod)method
                  authRequired:(BOOL)authRequired authScope:(NSString *)scope
{
    RKRoute * route = [self routeWithClass:objectClass
                               pathPattern:pathPattern
                                    method:method];
    [route setAuthRequired:authRequired scope:scope];
    return route;
}

+ (instancetype)routeWithRelationshipName:(NSString *)relationshipName objectClass:(Class)objectClass
                              pathPattern:(NSString *)pathPattern method:(RKRequestMethod)method
                             authRequired:(BOOL)authRequired authScope:(NSString *)scope
{
    RKRoute * route = [self routeWithRelationshipName:relationshipName
                                          objectClass:objectClass
                                          pathPattern:pathPattern
                                               method:method];
    [route setAuthRequired:authRequired scope:scope];

    return route;
}

@end
