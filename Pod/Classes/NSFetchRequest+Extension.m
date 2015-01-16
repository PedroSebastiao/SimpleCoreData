//
//  NSFetchRequest+Extension.m
//  
//
//  Created by Pedro Sebastião on 16/12/13.
//

#import "NSFetchRequest+Extension.h"
#import "PSCoreDataStackManager.h"

@implementation NSFetchRequest (Extension)

- (NSUInteger)count {
    return [[PSCoreDataStackManager sharedManager].managedObjectContext
            countForFetchRequest:self
            error:nil];
}

- (NSArray *)executeWithError:(NSError **)error
{
    NSArray *fetchResults = [[PSCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:self error:error];
    return fetchResults;
}

@end
