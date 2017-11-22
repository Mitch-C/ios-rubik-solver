//
//  CubeSOoverViewController.swift
//  RubikSolver-iOS
//
//  Created by Mitchell on 8/11/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

import UIKit
import SceneKit

class CubeSolverViewController: UIViewController {
    @IBOutlet weak var sceneKitView: SCNView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var rotationSequence = [String]()
    var rotationIndex: Int = 0
    var scene3D: SCNScene = SCNScene()
    var allColorsArray = [String]()
    
    var upFaceColors = [String]()
    var downFaceColors = [String]()
    var frontFaceColors = [String]()
    var backFaceColors = [String]()
    var leftFaceColors = [String]()
    var rightFaceColors = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rotationIndex = 0;
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        self.scene3D.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3Make(0, 0, 8)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        self.scene3D.rootNode .addChildNode(ambientLightNode)
        
        
        // Add the rubik cubelets to the scene
        addRubiksCubeNodeToScene()
        
        // Set scene properties
        let scnView = self.sceneKitView
        
        // set the scene to the view
        scnView?.scene = self.scene3D
        // allows the user to manipulate the camera
        scnView?.allowsCameraControl = true;
        
        // show statistics such as fps and timing information
        scnView?.showsStatistics = false;
        
        // configure the view
        let backgroundColor = UIColor(red: 30/255.0, green: 163/255.0, blue: 215/255.0, alpha: 1)
        scnView?.backgroundColor = backgroundColor;
        
        // Add the reflective floor under the cube
        let floor = SCNFloor()
        var floorMaterials = [SCNMaterial]()
        floorMaterials.append(material(withColor: backgroundColor))
        floor.materials = floorMaterials;
        
        let floorNode = SCNNode()
        floorNode.geometry = floor;
        floorNode.position = SCNVector3(0, -4, 0)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        scene3D.rootNode .addChildNode(floorNode)
        
        // Solve the cube and extract the rotation sequence
        let canonicalForm = prepareDataForSolver()
        let solvingSolution = KociembaWrapper().solveCube(withConfiguration: canonicalForm)
        print("CUBE STATE: \(canonicalForm)")
        if let solvingRotations = solvingSolution?.components(separatedBy: " ") {
            self.rotationSequence.append(contentsOf: solvingRotations)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: 3D Cube Creation
    
    func material(withColor materialColor: UIColor) -> SCNMaterial {
        let coloredMaterial = SCNMaterial()
        coloredMaterial.diffuse.contents = materialColor
        coloredMaterial.specular.contents = UIColor.white
        return coloredMaterial
    }
    
    func material(fromStringRepresentation stringColor: String) -> SCNMaterial {
        let coloredMaterial = SCNMaterial()
        var color: UIColor = UIColor()
        
        switch  stringColor {
        case "B":
            color = .blue
        case "W":
            color = .white
        case "O":
            color = .orange
        case "G":
            color = .green
        case "Y":
            color = .yellow
        case "R":
            color = .red
        default:
            color = .black
        }
        coloredMaterial.diffuse.contents = color
        coloredMaterial.specular.contents = UIColor.white
        
        return coloredMaterial;
    }
    
    func separateColorArrayIntoFaces() {
        var index = 0
        
        // Separate the large array into 6 smaller arrays and look at the center color
        while index < allColorsArray.count {
            
            var subArray = Array(allColorsArray[index...(index + 8)])
            let centerColor = subArray[4]
            
            switch centerColor {
            case "Y":
                self.upFaceColors = subArray
            case "G":
                self.leftFaceColors = subArray
            case "O":
                self.frontFaceColors = subArray
            case "W":
                self.downFaceColors = subArray
            case "R":
                backFaceColors = subArray
            default:
                rightFaceColors = subArray
            }
            index += 9
        }
        
    }
    
    func addRubiksCubeNodeToScene() {
        
        var cubeMaterials = [SCNMaterial]()
        cubeMaterials.append(material(withColor: .black))
        cubeMaterials.append(material(withColor: .black))
        cubeMaterials.append(material(withColor: .black))
        cubeMaterials.append(material(withColor: .black))
        cubeMaterials.append(material(withColor: .black))
        cubeMaterials.append(material(withColor: .black))
        
        separateColorArrayIntoFaces()
        
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    // Build the cube geometry
                    let cubeGeometry = SCNBox()
                    cubeGeometry.chamferRadius = 0.1
                    
                    //TOP FACE
                    if y == 1 {
                        var faceIndex = (abs(z + 1))
                        faceIndex = faceIndex * 3 + x + 1
                        let faceMaterial = material(fromStringRepresentation: upFaceColors[faceIndex])
                        cubeMaterials[4] = faceMaterial
                    }
                    
                    //BOTTOM FACE
                    if y == -1 {
                        var faceIndex = (abs(z - 1))
                        faceIndex = faceIndex * 3 + x + 1;
                        let faceMaterial = material(fromStringRepresentation: downFaceColors[faceIndex])
                        cubeMaterials[5] = faceMaterial
                    }
                    
                    // FRONT FACE
                    if z == 1 {
                        var faceIndex = (abs(y - 1))
                        faceIndex =  faceIndex * 3 + x + 1
                        let faceMaterial = material(fromStringRepresentation: frontFaceColors[faceIndex])
                        cubeMaterials[0] = faceMaterial
                    }
                    
                    // BACK FACE
                    if z == -1 {
                        var faceIndex = (abs(y - 1))
                        faceIndex = faceIndex  * 3 + abs(x - 1)
                        let faceMaterial = material(fromStringRepresentation: backFaceColors[faceIndex])
                        cubeMaterials[2] = faceMaterial
                    }
                    
                    // LEFT FACE
                    if x == -1 {
                        var faceIndex = (abs(y - 1))
                        faceIndex = faceIndex  * 3 + z + 1
                        let faceMaterial = material(fromStringRepresentation: leftFaceColors[faceIndex])
                        cubeMaterials[3] = faceMaterial
                    }
                    
                    // RIGHT FACE
                    if x == 1 {
                        var faceIndex = (abs(y - 1) * 3)
                        faceIndex = faceIndex + abs(z - 1)
                        let faceMaterial = material(fromStringRepresentation: rightFaceColors[faceIndex])
                        cubeMaterials[1] = faceMaterial
                    }
                    
                    cubeGeometry.materials = cubeMaterials
                    
                    // Build the cube node
                    let cubeNode = SCNNode()
                    cubeNode.geometry = cubeGeometry;
                    cubeNode.position = SCNVector3(x, y, z)
                    cubeNode.name = "cubelet \(x) \(y) \(z)"
                    scene3D.rootNode .addChildNode(cubeNode)
                }
            }
        }
    }
    
    
    //MARK: Cube Rotation
    
    func getRotationNode(fromMove moveString: String) -> SCNNode {
        // Add all the cubes into a node that represents the face
        let rotateNode = SCNNode()
        rotateNode.name = "RotateNode"
        // Get all the cubes in the scene
        let cubelets = self.scene3D.rootNode .childNodes { (child, stop) -> Bool in
            return (child.name?.contains("cubelet")) == true
        }
        
        // Categorize them by position (create the rotation node)
        if moveString.contains("L") {
            for var cubelet in cubelets {
                if cubelet.position.x < -0.9 {
                    rotateNode.addChildNode(cubelet)
                }
            }
        }
        else if moveString.contains("R") {
            // Take all the nodes with x ~= 1 (right side)
            for var cubelet in cubelets {
                if cubelet.position.x > 0.9 {
                    rotateNode.addChildNode(cubelet)
                }
            }
        } else if moveString.contains("U") {
            // Take all the nodes with y ~= 1 (up side)
            for var cubelet in cubelets {
                if cubelet.position.y > 0.9 {
                    rotateNode.addChildNode(cubelet)
                }
            }
        } else if moveString.contains("D") {
            // Take all the nodes with y ~= -1 (down side)
            for var cubelet in cubelets {
                if (cubelet.position.y < -0.9) {
                    rotateNode.addChildNode(cubelet)
                }
            }
        } else if moveString.contains("F") {
            // Take all the nodes with z ~= 1 (front side)
            for var cubelet in cubelets {
                if cubelet.position.z > 0.9 {
                    rotateNode.addChildNode(cubelet)
                }
            }
        } else if moveString.contains("B") {
            // Take all the nodes with y ~= 1 (back side)
            for var cubelet in cubelets {
                if cubelet.position.z < -0.9 {
                    rotateNode.addChildNode(cubelet)
                }
            }
        }
        
        return rotateNode
    }
    
    func getAnimation(fromMove moveString: String) -> SCNAction? {
        // Number and direction of rotation
        var nrOfRotations = 1.0
        var clockWise = 1.0
        
        if moveString.contains("2") {
            nrOfRotations = 2.0
        }
        if moveString.contains("'") {
            clockWise = -1.0
        }
        
        // Categorize them by position (create the rotation node)
        if moveString.contains("L") {
            return SCNAction.rotateBy(x: CGFloat(Double.pi / 2 * nrOfRotations) , y: 0, z: 0, duration: 2)
        } else if moveString.contains("R") {
            return SCNAction.rotateBy(x: CGFloat(Double.pi / 2 * nrOfRotations * -clockWise), y: 0, z: 0, duration: 2)
            
        } else if moveString.contains("U") {
            return SCNAction.rotateBy(x: 0, y: CGFloat(Double.pi / 2 * nrOfRotations * -clockWise), z: 0, duration: 2)
            
        } else if moveString.contains("D") {
            return SCNAction.rotateBy(x: 0, y: CGFloat(Double.pi / 2 * nrOfRotations * clockWise), z: 0, duration: 2)
            
        } else if moveString.contains("F") {
            return SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(Double.pi / 2 * nrOfRotations * -clockWise), duration: 2)
            
        } else if moveString.contains("B") {
            return SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(Double.pi / 2 * nrOfRotations * clockWise), duration: 2)
        }
        
        return nil;
    }
    
    //Mark: Cube Solving
    
    func prepareDataForSolver() -> String {
        var configuration = ""
        var allColors = upFaceColors
        allColors.append(contentsOf: rightFaceColors)
        allColors.append(contentsOf: frontFaceColors)
        allColors.append(contentsOf: downFaceColors)
        allColors.append(contentsOf: leftFaceColors)
        allColors.append(contentsOf: backFaceColors)
        
        for var color in allColors {
            if color == "Y" {
                configuration.append("U")
            } else if color == "G" {
                configuration.append("L")
            } else if color == "O" {
                configuration.append("F")
            } else if color == "B" {
                configuration.append("R")
            } else if color == "W" {
                configuration.append("D")
            } else if color == "R" {
                configuration.append("B")
            }
        }
        
        return configuration
    }
    
    //MARK: Application Lifecycle
    
    func shouldAutoRotate() -> Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func supportFaceOrientationMask() -> UIInterfaceOrientationMask {
        //        if UIDevice.current UIUserInterfaceIdiom {
        //            return .allButUpsideDown
        //        }
        return .allButUpsideDown
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        if rotationIndex >= rotationSequence.count {
            nextButton.isEnabled = false
            animateEnding()
            return
        }
        //                    self.solutionLabel.text = self.rotationSequence[self.rotationIndex];
        
        let rotationNode = getRotationNode(fromMove: rotationSequence[rotationIndex])
        guard let rotationSCNAction = getAnimation(fromMove: rotationSequence[rotationIndex]) else {
            return
        }
        
        scene3D.rootNode.addChildNode(rotationNode)
        nextButton.isEnabled = false;
        previousButton.isEnabled = false;
        
        rotationNode.runAction(rotationSCNAction) {
            rotationNode.enumerateChildNodes({ (child, stop) in
                child.transform = child.worldTransform
                child.removeFromParentNode()
                self.scene3D.rootNode .addChildNode(child)
            })
            
            rotationNode.removeFromParentNode()
            self.rotationIndex += 1
            
            self.nextButton.isEnabled = true
            self.previousButton.isEnabled = true
        }
    }
    
    @IBAction func previousButtonTap(_ sender: Any) {
        
        rotationIndex -= 1;
        
        print("Rotation index: \(rotationIndex)");
        
        if rotationIndex < 0 {
            rotationIndex = 0
            previousButton.isEnabled = false
            return;
        }
        
        //        self.solutionLabel.text = self.rotationSequence[self.rotationIndex];
        
        let rotationNode = getRotationNode(fromMove: rotationSequence[rotationIndex])
        guard let rotationSCNAction = getAnimation(fromMove: rotationSequence[rotationIndex]) else {
            return
        }
        
        scene3D.rootNode.addChildNode(rotationNode)
        
        nextButton.isEnabled = false
        previousButton.isEnabled = false
        
        
        rotationNode.runAction(rotationSCNAction) {
            rotationNode.enumerateChildNodes({ (child, stop) in
                child.transform = child.worldTransform
                child.removeFromParentNode()
                self.scene3D.rootNode.addChildNode(child)
            })
            
            rotationNode.removeFromParentNode()
            self.nextButton.isEnabled = true
            self.previousButton.isEnabled = true
        }
        
    }
    
    func animateEnding() {
        // Get all the cubes in the scene
        let cubelets = scene3D.rootNode.childNodes { (child, stop) -> Bool in
            return (child.name?.contains("cubelet")) == true
        }
        
        for var cube in cubelets {
            cube.physicsBody = SCNPhysicsBody.init(type: .dynamic, shape: nil)
        }
    }
    
}
