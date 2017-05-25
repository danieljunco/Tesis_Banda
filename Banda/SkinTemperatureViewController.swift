//
//  SkinTemperatureViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/23/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit

var skinTemperature = ""

class SkinTemperatureViewController: UIViewController {

    @IBOutlet weak var skinView: UIView!
    @IBOutlet weak var skinLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skinView.layer.cornerRadius = 120
        skinView.layer.borderWidth = 2
        let c = GlobalVariables.sharedInstance.hexStringToUIColor(hex: "#f1c40f")
        skinView.layer.borderColor = c.cgColor
        skinView.layer.shadowColor = c.cgColor
        skinView.layer.shadowOffset = CGSize(width: -3.75, height: -4)
        skinView.layer.shadowRadius = 1.7
        skinView.layer.shadowOpacity = 0.55
        
        startSkinTemperature()
    }
    
    func startSkinTemperature(){
        print("onConnecteTemperature..")
        
        mBand.requestUserConsent { (result) in
            if(result){
                print("requestUserConstent...\(result), callingHR")
                try! mBand.startSkinTempUpdates(completion: { (data, error) in
                    if error != nil {
                        print("temperature error \(error)")
                    } else {
                        print("temperature data \(data) \(data?.temperature)")
                        let temperatura = "\(Double(round((100*data!.temperature)/100)))"
                        self.skinLabel.text = temperatura
                        skinTemperature = temperatura
                        
                    }
                })
            }
        }
        mBand.sendHaptic()
        mBand.sendHaptic() { error in
            print("[MSB] Error sendHaptic: \(error)")
            
        }
    }


}
