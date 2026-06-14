#import "OrderedDictionary.h"

@implementation OrderedDictionary

- (id)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self != nil) {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        array = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    if (![dictionary objectForKey:aKey]) {
        [array addObject:aKey];
    }
    [dictionary setObject:anObject forKey:aKey];
}

- (void)setObject:(id)anObject forKeyedSubscript:(id<NSCopying>)key {
    [self setObject:anObject forKey:(id)key];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)removeObjectForKey:(id)aKey {
    [dictionary removeObjectForKey:aKey];
    [array removeObject:aKey];
}

- (NSUInteger)count {
    return [dictionary count];
}

- (id)objectForKey:(id)aKey {
    return [dictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return [array objectEnumerator];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [array countByEnumeratingWithState:state objects:buffer count:len];
}

@end