//
//  EPEqualizerConfigurationViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 03/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPEqualizerConfigurationViewController: UIViewController {

    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet var verticalBandSliders: [EPVerticalBandSlider]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultButton.tintColor = UIView.defaultTintColor()
        drawRightMenuButton()
        self.navigationItem.title = "EQ"
        if let options = EPMusicPlayer.sharedInstance.audioStreamSTK?.options {
            print("options: \(options)")
//            let frequencies = options.equalizerBandFrequencies
            
            verticalBandSliders[0].bandFrequencyString = "50" //"\(Int(frequencies.0) > 1000 ? frequencies.0 / 1000 : frequencies.0)\(Int(frequencies.0) > 1000 ? "K" : "")"
            verticalBandSliders[1].bandFrequencyString = "100" //"\(Int(frequencies.1) > 1000 ? frequencies.1 / 1000 : frequencies.1)\(Int(frequencies.1) > 1000 ? "K" : "")"
            verticalBandSliders[2].bandFrequencyString = "200" //"\(Int(frequencies.2) > 1000 ? frequencies.2 / 1000 : frequencies.2)\(Int(frequencies.2) > 1000 ? "K" : "")"
            verticalBandSliders[3].bandFrequencyString = "400" //"\(Int(frequencies.3) > 1000 ? frequencies.3 / 1000 : frequencies.3)\(Int(frequencies.3) > 1000 ? "K" : "")"
            verticalBandSliders[4].bandFrequencyString = "800" //"\(Int(frequencies.4) > 1000 ? frequencies.4 / 1000 : frequencies.4)\(Int(frequencies.4) > 1000 ? "K" : "")"
            verticalBandSliders[5].bandFrequencyString = "1.6K" //"\(Int(frequencies.5) > 1000 ? frequencies.5 / 1000 : frequencies.5)\(Int(frequencies.5) > 1000 ? "K" : "")"
            verticalBandSliders[6].bandFrequencyString = "2.6K" //"\(Int(frequencies.6) > 1000 ? frequencies.6 / 1000 : frequencies.6)\(Int(frequencies.6) > 1000 ? "K" : "")"
            verticalBandSliders[7].bandFrequencyString = "16K" //"\(Int(frequencies.7) > 1000 ? frequencies.7 / 1000 : frequencies.7)\(Int(frequencies.7) > 1000 ? "K" : "")"
            
            displayEQSettings()
            
            for bandSlider in self.verticalBandSliders {
                bandSlider.addTarget(self, action: #selector(bandSliderValueChanged), for: UIControlEvents.editingDidEnd)
            }
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bandSliderValueChanged(_ bandSlider: EPVerticalBandSlider) {
        print("Range slider #\(self.verticalBandSliders.index(of: bandSlider)) value changed: (\(bandSlider.currentValue))")
        switch Int(self.verticalBandSliders.index(of: bandSlider)!) {
            
        case 0:
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(bandSlider.currentValue), forEqualizerBand: 0)
            break
        case 1:
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(bandSlider.currentValue), forEqualizerBand: 1)
            break
        case 2:
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(bandSlider.currentValue), forEqualizerBand: 2)
            break
        case 3:
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(bandSlider.currentValue), forEqualizerBand: 3)
            break
        case 4:
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(bandSlider.currentValue), forEqualizerBand: 4)
            break
        case 5:
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(bandSlider.currentValue), forEqualizerBand: 5)
            break
        case 6:
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(bandSlider.currentValue), forEqualizerBand: 6)
            break
        case 7:
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(bandSlider.currentValue), forEqualizerBand: 7)
            break
            
        default:
            
            break
        }
        
    }

    func saveEQSettings() {
        
        let EQGains = [
            verticalBandSliders[0].currentValue,
            verticalBandSliders[1].currentValue,
            verticalBandSliders[2].currentValue,
            verticalBandSliders[3].currentValue,
            verticalBandSliders[4].currentValue,
            verticalBandSliders[5].currentValue,
            verticalBandSliders[6].currentValue,
            verticalBandSliders[7].currentValue
        ]
        
        UserDefaults.standard.set(EQGains, forKey: "EQGains")
    }
    
    func displayEQSettings() {
        let EQGains = self.loadEQSettings()
        
        verticalBandSliders[0].currentValue = EQGains[0]
        verticalBandSliders[1].currentValue = EQGains[1]
        verticalBandSliders[2].currentValue = EQGains[2]
        verticalBandSliders[3].currentValue = EQGains[3]
        verticalBandSliders[4].currentValue = EQGains[4]
        verticalBandSliders[5].currentValue = EQGains[5]
        verticalBandSliders[6].currentValue = EQGains[6]
        verticalBandSliders[7].currentValue = EQGains[7]
    }
    
    func loadEQSettings() -> [Double] {
        if let EQGains = UserDefaults.standard.object(forKey: "EQGains") as? [Double] {
           return EQGains
        } else {
            
            let EQGains = [
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0
            ]
            
            UserDefaults.standard.set(EQGains, forKey: "EQGains")
            
            return EQGains
        }
    }
    @IBAction func presetButtonTap(_ sender: AnyObject) {
        if true {//default
            let EQGains = [
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0
            ]

            self.verticalBandSliders[0].setValue(EQGains[0], animated: true)
            self.verticalBandSliders[1].setValue(EQGains[1], animated: true)
            self.verticalBandSliders[2].setValue(EQGains[2], animated: true)
            self.verticalBandSliders[3].setValue(EQGains[3], animated: true)
            self.verticalBandSliders[4].setValue(EQGains[4], animated: true)
            self.verticalBandSliders[5].setValue(EQGains[5], animated: true)
            self.verticalBandSliders[6].setValue(EQGains[6], animated: true)
            self.verticalBandSliders[7].setValue(EQGains[7], animated: true)
            
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(EQGains[0]), forEqualizerBand: 0)
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(EQGains[1]), forEqualizerBand: 1)
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(EQGains[2]), forEqualizerBand: 2)
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(EQGains[3]), forEqualizerBand: 3)
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(EQGains[4]), forEqualizerBand: 4)
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(EQGains[5]), forEqualizerBand: 5)
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(EQGains[6]), forEqualizerBand: 6)
            EPMusicPlayer.sharedInstance.audioStreamSTK!.setGain(Float(EQGains[7]), forEqualizerBand: 7)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveEQSettings()
    }
    
}
