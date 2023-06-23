//
//  ViewController.swift
//  ARRuler
//
//  Created by Kelvin KUCH on 23.06.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var pointNodes = [SCNNode]()
    var textNode = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            /*
             let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)    // returns [ARHitTestResult]
             The above code displays the following error: 'hitTest(_:types:)' was deprecated in iOS 14.0: Use [ARSCNView raycastQueryFromPoint:allowingTarget:alignment]
             */
            let hitTestResult = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any)
            if let hitResult = hitTestResult {
                addDot(at: hitResult)
            }
        }
        
        if pointNodes.count >= 2 {
            for point in pointNodes {
                point.removeFromParentNode()
            }
            
            pointNodes.removeAll()
        }
    }
    
    func addDot(at hitResult: ARRaycastQuery) {
        let dotGeometry = SCNSphere(radius: 0.002)
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.brown
        dotGeometry.materials = [material]
        
        
        let pointNode = SCNNode(geometry: dotGeometry)
        pointNode.position = SCNVector3(x: hitResult.origin.x , y: hitResult.origin.y, z: hitResult.origin.z)
        
        sceneView.scene.rootNode.addChildNode(pointNode)
        
        pointNodes.append(pointNode)
        
        if pointNodes.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let m1 = pointNodes[0]
        let m2 = pointNodes[1]
        
        let a = m2.position.x - m1.position.x
        let b = m2.position.y - m1.position.y
        let c = m2.position.z - m1.position.z
        
        let distance = sqrt(pow(a, 2.00) + pow(b, 2.00) + pow(c, 2.00))
        
        print("distance: \(distance)")
        
        
        // display distance in space
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: "\(abs(distance))", extrusionDepth: 1.00)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(m2.position.x + 0.05, m2.position.y + 0.05, m2.position.z - 0.07)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
