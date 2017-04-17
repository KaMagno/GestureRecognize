//
//  ViewController.swift
//  GestureRecognizer
//
//  Created by Kaique Magno Dos Santos on 17/04/17.
//  Copyright © 2017 Dreams n' Makers. All rights reserved.
//
//  By RayWenderlich Tutorial - https://www.raywenderlich.com/76020/using-uigesturerecognizer-with-swift-tutorial

import UIKit
import AVFoundation

class ViewController: UIViewController,UIGestureRecognizerDelegate {
    
    var chompPlayer:AVAudioPlayer? = nil
    
    @IBOutlet var outletMonkeyPan: UIPanGestureRecognizer!
    @IBOutlet var outletBananaPan: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Filter Array of UIImageView
        let filteredSubview = self.view.subviews.filter { (view) -> Bool in
            return view is UIImageView
        }
        
        //For in to access each view
        for aView in filteredSubview {
            //
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(recognizer:)))
            //
            recognizer.delegate = self
            aView.addGestureRecognizer(recognizer)
            
            recognizer.require(toFail: self.outletMonkeyPan)
            recognizer.require(toFail: self.outletBananaPan)
        }
        self.chompPlayer = self.loadSound(fileAssetName: "chomp")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: - Functions
    func loadSound(fileAssetName:String) -> AVAudioPlayer? {
        
        guard let data = NSDataAsset(name: fileAssetName) else{
            print("Sound file not found")
            return nil
        }
        
        do{
            let player = try AVAudioPlayer(data: data.data)
            player.prepareToPlay()
            return player
        }catch{
            print("Error: \(error)")
            return nil
        }
        
        
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.chompPlayer?.play()
    }
    
    //
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let aView = recognizer.view {
            aView.center = CGPoint(
                x: aView.center.x + translation.x,
                y: aView.center.y + translation.y
            )
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        //Deceleration
        if recognizer.state == .ended {
            // Verify the vector velcoity
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y)) //Velocidade.x^2 + Velocidade.y^2
            let slideMultiplier = magnitude / 1000
            print("magnitude: \(magnitude), slideMultiplier:\(slideMultiplier)")
            
            // If the magnitude is less than 200 (magnitude < 200) then decrease the base speed, otherwise increase it.
            let slideFactor = 0.1 * slideMultiplier
            
            // Calculate a final point based on the velocity and the slideFactor
            let finalPoint = CGPoint(
                x: recognizer.view!.center.x + (velocity.x * slideFactor),
                y: recognizer.view!.center.y + (velocity.y * slideFactor)
            )
            
            //Animating the view to the final resting place
            UIView.animate(
                withDuration: Double(slideFactor * 2),
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    recognizer.view!.center = finalPoint
            },
                completion:nil
            )
        }
    }
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer){
        
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotate(recognizer: UIRotationGestureRecognizer){
        
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    // TODO: Custom Gesture
}

