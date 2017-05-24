//
//  RitmoCardiacoViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/23/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit

class RitmoCardiacoViewController: UIViewController {
    
    @IBOutlet weak var heartBeatLabel: UILabel!
    @IBOutlet weak var heartBeatView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heartBeatView.layer.cornerRadius = 120
        heartBeatView.layer.borderWidth = 2
        let c = GlobalVariables.sharedInstance.hexStringToUIColor(hex: "#c0392b")
        heartBeatView.layer.borderColor = c.cgColor
        heartBeatView.layer.shadowColor = c.cgColor
        heartBeatView.layer.shadowOffset = CGSize(width: -3.75, height: -4)
        heartBeatView.layer.shadowRadius = 1.7
        heartBeatView.layer.shadowOpacity = 0.55
        startHeartRate()
    }
    

    func startHeartRate(){
        print("onConnecteHeart..")
        
        mBand.requestUserConsent { (result) in
            if(result){
                print("requestUserConstent...\(result), callingHR")
                try! mBand.startHeartRateUpdates(completion: { (data, error) in
                    if error != nil {
                        print("heartRate error \(error)")
                    } else {
                        print("heartRate data \(data) \(data?.heartRate)")
                        self.heartBeatLabel.text = "\(data?.heartRate)"
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
