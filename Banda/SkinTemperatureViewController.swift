//
//  SkinTemperatureViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/23/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit

class SkinTemperatureViewController: UIViewController {

    @IBOutlet weak var skinLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
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
                        self.skinLabel.text = "\(data?.temperature)"
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
