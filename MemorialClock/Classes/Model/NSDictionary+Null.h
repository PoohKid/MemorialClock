//
//  NSDictionary+Null.h
//  lographsPrototype
//
//  Created by プー坊 on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableDictionary (NSDictionary_Null)
- (void)setObjectNull:(id)anObject forKey:(id)aKey;
@end

@interface NSDictionary (NSDictionary_Null)
- (id)objectForKeyNull:(id)aKey;
@end
