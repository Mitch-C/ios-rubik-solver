//
//  OpenCVWrapperViewController.m
//  RubikSolver-iOS
//
//  Created by Mitchell on 21/11/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import "OpenCVWrapperViewController.h"

#ifdef __cplusplus

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>
#include "EdgeBasedCubeDetector.hpp"
#include "ColorDetector.hpp"

#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

@interface OpenCVWrapperViewController ()<CvPhotoCameraDelegate>{
    cv::Mat currentImage, topImage, leftImage, rightImage;
    cv::Mat firstThreeFacesImage;
    cv::Mat lastThreeFacesImage;
    
    bool didTakeFirstPicture;
    int photoIndex;
}

@property CvPhotoCamera *photoCamera;
@property EdgeBasedCubeDetector cubeDetector;
@property ColorDetector colorDetector;

@property (nonatomic) UIImage *segmentationImage;

@property (nonatomic) NSMutableArray *computedColorsArray;
@property NSMutableArray *acceptedColorsArray;
@property NSMutableArray *faceImagesArray;
@property (nonatomic) UIImage *capturedImage;

@end



@implementation OpenCVWrapperViewController

#pragma mark - Protocol CvPhotoCameraDelegate

#ifdef __cplusplus

- (void)setupWithView:(UIView *)cameraImageView {
    // Load the SVM classifier
    NSString *svmClassifierPath = [[NSBundle mainBundle] pathForResource: @"color-classification-svm-2" ofType: @"yml"];
    std::string svmClassifierPathStd = std::string([svmClassifierPath UTF8String]);
    _colorDetector.LoadSVMFromFile(svmClassifierPathStd);
    
    // Alloc the detected colors array
    _acceptedColorsArray = [[NSMutableArray alloc] init];
    
    // Setup the camera parameters (force flash and 1280x720 resolution)
    _photoCamera = [[CvPhotoCamera alloc] initWithParentView:cameraImageView];
    _photoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    _photoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _photoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    // Set the camera delegate
    _photoCamera.delegate = self;
    
    // Start the aquisition process
    [_photoCamera start];
}

/**
 Saves a cv::Mat image to the documents folder (you can access it via iTunes)
 @param image The cv::Mat image to be saved
 @param imageName The name of the image, without extension (ex. "accepted_image")
 */
- (void)saveMatImageToDocumentsFolder:(const cv::Mat&)image named:(NSString*)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.jpg", imageName, photoIndex]];
    NSData *imageData = UIImageJPEGRepresentation(MatToUIImage(image), 1);
    [imageData writeToFile:appFile atomically:NO];
}

/**
 Saves an image of type <b>UIImage</b> to the documents folder (you can access it via iTunes)
 @param image The cv::Mat image to be saved
 @param imageName The name of the image, without extension (ex. "accepted_image")
 */
- (void)saveUIImageToDocumentsFolder:(UIImage*)image named:(NSString*)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.jpg", imageName, photoIndex]];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [imageData writeToFile:appFile atomically:NO];
}

/**
 Method invoked after taking a picture (CvPhotoCameraDelegate method)
 @param photoCamera The CvPhotoCamera object
 @param image The UIImage captured by the device
 */
- (void)photoCamera:(CvPhotoCamera*)photoCamera capturedImage:(UIImage *)image {
    try {
        [_photoCamera stop];
        
        //        self.captureImageButton.hidden = YES;
        //        self.acceptButton.hidden = NO;
        //        self.rejectButton.hidden = NO;
        //        self.instructionsLabel.text = @"Make sure that the corners are detected properly :)";
        
        self.capturedImage = image;
        
        // Convert the UIImage to a cv::Mat object
        cv::Mat capturedImageMat;
        UIImageToMat(image, capturedImageMat);
        
        // Rotate clockwise 90 degrees (portrait orientation in iOS...)
        cv::transpose(capturedImageMat, capturedImageMat);
        cv::flip(capturedImageMat, capturedImageMat, 1);
        
        // Convert the image from RGBA (device color format) to BGR (default OpenCV color format)
        cv::Mat bgrImage, outputImage, rgbaImage;
        cv::cvtColor(capturedImageMat, bgrImage, CV_RGBA2BGR);
        
        // Apply the segmentation algorithm
        _cubeDetector.SegmentFaces(bgrImage, outputImage, topImage, leftImage, rightImage, !didTakeFirstPicture);
        
        
        auto topColors = _colorDetector.RecognizeColors(topImage);
        auto leftColors = _colorDetector.RecognizeColors(leftImage);
        auto rightColors = _colorDetector.RecognizeColors(rightImage);
        
        _computedColorsArray = [[NSMutableArray alloc] init];
        
        std::cout << std::endl;
        for (int i = 0; i < topColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:topColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
            std::cout << topColors[i] << " ";
        }
        std::cout << std::endl;
        for (int i = 0; i < leftColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:leftColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
            std::cout << leftColors[i] << " ";
        }
        std::cout << std::endl;
        for (int i = 0; i < rightColors.size(); i++) {
            [_computedColorsArray addObject: [NSString stringWithCString:rightColors[i].c_str() encoding:[NSString defaultCStringEncoding]]];
            std::cout << rightColors[i] << " ";
        }
        
        //        [_acceptedColorsArray addObjectsFromArray:_computedColorsArray];
        
        cv::cvtColor(outputImage, rgbaImage, CV_BGR2RGBA);
        cv::cvtColor(topImage, topImage, CV_BGR2RGBA);
        cv::cvtColor(leftImage, leftImage, CV_BGR2RGBA);
        cv::cvtColor(rightImage, rightImage, CV_BGR2RGBA);
        
        
        _segmentationImage = MatToUIImage(rgbaImage);
        
        
        photoIndex++;
        
        //        self.overlayImageView.image = segmentationImage;
        //        self.overlayImageView.alpha = 1.0;
        
    } catch (const std::out_of_range &exception) {
        // TODO: display error
        std::cout << exception.what() << std::endl;
        //
        //        NSString *errorMessage = [NSString stringWithUTF8String:exception.what()];
        //        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ooops :-(" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        //        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //            [self didPressRetakeImage:nil];
        //        }];
        //
        //        [alertController addAction:okAction];
        //        [self presentViewController:alertController animated:YES completion:nil];
    }
}



/// Declared to conform to the delegation pattern (not used)
- (void)photoCameraCancel:(CvPhotoCamera*)photoCamera {
    
}

#endif


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)takePicture {
    [self.photoCamera takePicture];
}

- (void)start {
    [self.photoCamera start];
}

- (UIImage *)topImage {
    return MatToUIImage(topImage);
}

- (UIImage *)leftImage {
    return MatToUIImage(leftImage);
}

- (UIImage *)rightImage {
    return MatToUIImage(rightImage);
}

- (UIImage *)capturedImage {
    return _capturedImage;
}

-(NSMutableArray * )computedColorsArray {
    return _computedColorsArray;
}

- (UIImage *)segmentationImage {
    return _segmentationImage;
}

@end
