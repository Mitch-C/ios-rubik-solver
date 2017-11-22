//
//  KociembaWrapper.m
//  RubikSolver-iOS
//
//  Created by Mitchell on 14/11/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//
#ifdef __cplusplus
#include "search.hpp"
#endif
#import "KociembaWrapper.h"

@implementation KociembaWrapper

- (NSString*) SolveCubeWithConfiguration: (const char*) cubeConfiguration {
    
    char* solutionArray = ApplyKociembaAlgorithm(strdup(cubeConfiguration), 24, 1000, 0, "cache");
    if(solutionArray == NULL) {
        return @"Configuration Error. Please check the cube faces again.";
    }
    
    NSString *solutionString = [NSString stringWithUTF8String:solutionArray];
    solutionString = [solutionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"Solution: %@", solutionString);
    return solutionString;
}
- (char *)solveExampleCubeConfiguration {
    char* solutionArray = ApplyKociembaAlgorithm(strdup("ULURURRLDLDLBRUDBUUUFDFLDBRBUFBDDDRFLUBDLFBRLFFBFBLRFR"), 24, 1000, 0, "cache");
    NSLog(@"Solution: %@", [NSString stringWithUTF8String:solutionArray]);
    return solutionArray;
}

@end
