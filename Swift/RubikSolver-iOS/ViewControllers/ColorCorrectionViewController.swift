//
//  ColorCorrectionViewControllerSwift.swift
//  RubikSolver-iOS
//
//  Created by Mitchell on 20/11/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

import UIKit

class ColorCorrectionViewController: UIViewController {

    @IBOutlet weak var faceIndexLabel: UILabel!
    @IBOutlet weak var faceImageView: UIImageView!
    
    @IBOutlet weak var firstPatchButton: UIButton!
    @IBOutlet weak var secondPatchButton: UIButton!
    @IBOutlet weak var thirdPatchButton: UIButton!
    @IBOutlet weak var fourthPatchButton: UIButton!
    @IBOutlet weak var fithPatchButton: UIButton!
    @IBOutlet weak var sixthPatchButton: UIButton!
    @IBOutlet weak var seventhPatchButton: UIButton!
    @IBOutlet weak var eightPatchButton: UIButton!
    @IBOutlet weak var ninthPatchButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextBUtton: UIButton!
    
    var currentFaceIndex: Int = 0
    var faceImages = [UIImage]()
    var faceColors = [String]()
    var selectedButton: UIButton?
    var currentSquareIndexInCube: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setColorsFromArray()
        faceImageView.image = faceImages[currentFaceIndex]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "correctionToSolveSegue" {
            let solverViewController =
            segue.destination as? CubeSolverViewController
            solverViewController?.allColorsArray = self.faceColors
            
        }
    }
    
    func color(fromString stringRepresentation: String) -> UIColor {
        switch stringRepresentation {
        case "R":
            return .red
        case "G":
            return .green
        case "B":
            return .blue
        case "O":
            return .orange
        case "W":
            return .white
        case "Y":
            return .yellow
        default:
            return .black
        }
    }
    
    func setColorsFromArray() {
        let startIndex = currentFaceIndex * 9
        
        firstPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 0])
        secondPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 1])
        thirdPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 2])
        fourthPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 3])
        fithPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 4])
        sixthPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 5])
        seventhPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 6])
        eightPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 7])
        ninthPatchButton.backgroundColor = color(fromString: faceColors[startIndex + 8])
    }
    
    func removeButtonBorder() {
        firstPatchButton.layer.borderWidth = 0
        secondPatchButton.layer.borderWidth = 0
        thirdPatchButton.layer.borderWidth = 0
        fourthPatchButton.layer.borderWidth = 0
        fithPatchButton.layer.borderWidth = 0
        sixthPatchButton.layer.borderWidth = 0
        seventhPatchButton.layer.borderWidth = 0
        eightPatchButton.layer.borderWidth = 0
        ninthPatchButton.layer.borderWidth = 0
    }
        
    func addBorder(toButton button: UIButton) {
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func firstPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9
        addBorder(toButton: sender)
    }
    
    @IBAction func secondPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9 + 1
        addBorder(toButton: sender)
    }
    
    @IBAction func thirdPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9 + 2
        addBorder(toButton: sender)
    }
    
    @IBAction func fourthPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9 + 3
        addBorder(toButton: sender)
    }
    
    @IBAction func fifthPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9 + 4
        addBorder(toButton: sender)
    }
    
    @IBAction func sixthPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9 + 5
        addBorder(toButton: sender)
    }
    @IBAction func seventhPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9 + 6
        addBorder(toButton: sender)
    }
    
    @IBAction func eightPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9 + 7
        addBorder(toButton: sender)
    }
    
    @IBAction func ninthPatchButtonTap(_ sender: UIButton) {
        removeButtonBorder()
        selectedButton = sender
        currentSquareIndexInCube = currentFaceIndex * 9 + 8
        addBorder(toButton: sender)
    }
    
    @IBAction func redActionButtonTap(_ sender: Any) {
        selectedButton?.backgroundColor = .red
        faceColors[currentSquareIndexInCube] = "R"
    }
    
    @IBAction func orangeActionButtonTap(_ sender: Any) {
        selectedButton?.backgroundColor = .orange
        faceColors[currentSquareIndexInCube] = "O"
    }
    
    @IBAction func greenActionButtonTap(_ sender: Any) {
        selectedButton?.backgroundColor = .green
        faceColors[currentSquareIndexInCube] = "G"
    }
    
    @IBAction func blueActionButtonTap(_ sender: Any) {
        selectedButton?.backgroundColor = .blue
        faceColors[currentSquareIndexInCube] = "B"
    }
    
    @IBAction func yellowActionButtonTap(_ sender: Any) {
        selectedButton?.backgroundColor = .yellow
        faceColors[currentSquareIndexInCube] = "Y"
    }
    
    @IBAction func whiteActionButtonTap(_ sender: Any) {
        selectedButton?.backgroundColor = .white
        faceColors[currentSquareIndexInCube] = "W"
    }
    
    @IBAction func previousButtonTap(_ sender: Any) {
        if currentFaceIndex > 0 {
            currentFaceIndex -= 1
            setColorsFromArray()
            faceImageView.image = faceImages[currentFaceIndex]
        }
        faceIndexLabel.text = "Face \(currentFaceIndex+1) /6"
        if currentFaceIndex < 5 {
            nextBUtton.setTitle("Next", for: .normal)
            nextBUtton.setTitle("Next", for: .highlighted)
        }
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        if nextBUtton.title(for: .normal) == "DONE" {
            for var color in faceColors {
                print(color)
            }
            performSegue(withIdentifier: "correctionToSolveSegue", sender: self)
            return
        }
        if currentFaceIndex < 5 {
            currentFaceIndex += 1
            setColorsFromArray()
            faceImageView.image = faceImages[currentFaceIndex]
            
        }
        if currentFaceIndex == 5 {
            nextBUtton.setTitle("DONE", for: .normal)
            nextBUtton.setTitle("DONE", for: .highlighted)
        }
        
    }
    
}
