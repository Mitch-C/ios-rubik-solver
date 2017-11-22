//
//  CubeCaptureViewControllerSwift.swift
//  RubikSolver-iOS
//
//  Created by Mitchell on 20/11/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

import UIKit
import AVFoundation


class CubeCaptureViewController: UIViewController {

    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var capturePhotoButton: UIButton!
    
    var acceptedColorsArray = [String]()
    var faceImagesArray = [UIImage]()
    
    var didTakeFirstPicture: Bool = false
    
    var openCVWrapper = OpenCVWrapperViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openCVWrapper.setup(with: cameraImageView)
        self.acceptButton.isHidden = false
        self.rejectButton.isHidden = false

        // Force the camera to use the flash (if available)
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if device?.isFlashAvailable == true {
            do {
                try device?.lockForConfiguration()
                device?.flashMode = AVCaptureFlashMode.on
                device?.unlockForConfiguration()
                
            } catch {
                print("unable to lock device for flash configuration")
            }
        
        }
    }
    
    @IBAction func captureButtonTap(_ sender: Any) {
        openCVWrapper.takePicture()
        self.acceptButton.isHidden = false
        self.rejectButton.isHidden = false
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.overlayImageView.image = self.openCVWrapper.segmentationImage()
        }
    }
    
    @IBAction func acceptButtonTap(_ sender: Any) {
        // Add the accepted colors to the accepted array
//        acceptedColorsArray.append(openCVWrapper.computedColorsArray())
        for var color in openCVWrapper.computedColorsArray() {
            acceptedColorsArray.append(color as! String)
        }
        
        // Add the face images to the array
        faceImagesArray.append(openCVWrapper.topImage())
        faceImagesArray.append(openCVWrapper.leftImage())
        faceImagesArray.append(openCVWrapper.rightImage())
        
        
        // If the user has taken the second photo, go to the correction view
        if didTakeFirstPicture {

            for var faceImage in faceImagesArray {
                let filename = "color_recognition_\(arc4random())"
                openCVWrapper.saveUIImage(toDocumentsFolder: faceImage, named: filename)
                
            }
            performSegue(withIdentifier: "captureToCorrectionSegue" , sender: self)
        } else {
            didTakeFirstPicture = true
            rejectButtonTap(self)
        }
    }
    
    @IBAction func rejectButtonTap(_ sender: Any) {
        let filename = "rejected_photo_\(arc4random())"
        openCVWrapper.saveUIImage(toDocumentsFolder: openCVWrapper.capturedImage(), named: filename)
        
        if !didTakeFirstPicture {
            self.instructionsLabel.text = "Take the picture of the first three faces."
        } else {
            self.instructionsLabel.text = "Take the picture of the last three faces."
        }
        
        overlayImageView.image = UIImage(named: "guide-overlay")
        overlayImageView.alpha = 0.5
        
        openCVWrapper.start()
        
        
        capturePhotoButton.isHidden = false
        acceptButton.isHidden = true
        rejectButton.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "captureToCorrectionSegue" {
            let destinationVC = segue.destination as? ColorCorrectionViewController
            
            destinationVC?.faceColors = acceptedColorsArray
            destinationVC?.faceImages = faceImagesArray
        }
    }

}
