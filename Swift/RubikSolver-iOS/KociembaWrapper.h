//
//  KociembaWrapper.h
//  RubikSolver-iOS
//
//  Created by Mitchell on 14/11/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KociembaWrapper : NSObject

- (NSString*) SolveCubeWithConfiguration: (const char*) cubeConfiguration;

- (char *)solveExampleCubeConfiguration;

@end
