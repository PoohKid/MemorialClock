//
//  NSDictionary+Null.m
//  lographsPrototype
//
//  Created by プー坊 on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Null.h"


//NSDictionaryはnil値を受け取らないため自動的にNSNullと変換するメソッドを追加
@implementation NSMutableDictionary (NSDictionary_Null)

- (void)setObjectNull:(id)anObject forKey:(id)aKey
{
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    } else {
        [self setObject:[NSNull null] forKey:aKey];
    }
}

@end

@implementation NSDictionary (NSDictionary_Null)

- (id)objectForKeyNull:(id)aKey
{
    id anObject = [self objectForKey:aKey];
    if (anObject == [NSNull null]) {
        return nil;
    } else {
        return anObject;
    }
}

@end
