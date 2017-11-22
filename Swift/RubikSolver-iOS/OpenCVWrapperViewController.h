//
//  OpenCVWrapperViewController.h
//  RubikSolver-iOS
//
//  Created by Mitchell on 21/11/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenCVWrapperViewController : NSObject

- (void)setupWithView:(UIView *)cameraImageView;

- (void)saveUIImageToDocumentsFolder:(UIImage*)image named:(NSString*)imageName;

- (void)takePicture;

- (void)start;

- (UIImage *)topImage;

- (UIImage *)leftImage;

- (UIImage *)rightImage;

- (UIImage *)capturedImage;

- (UIImage *)segmentationImage;

-(NSMutableArray * )computedColorsArray;



@end
