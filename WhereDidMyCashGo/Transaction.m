//
//  Transaction.m
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 5/11/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self)
        return nil;
    
    self.purchase = [[aDecoder decodeObjectForKey:@"purchase"] copy];
    self.cost = [aDecoder decodeObjectForKey:@"cost"];
    
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.purchase forKey:@"purchase"];
    [aCoder encodeObject:self.cost forKey:@"cost"];
}

@end
