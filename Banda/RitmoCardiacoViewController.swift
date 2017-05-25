//
//  RitmoCardiacoViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/23/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit
import AFNetworking

var ritmoNumero = ""

class RitmoCardiacoViewController: UIViewController {
    
    @IBOutlet weak var heartBeatLabel: UILabel!
    @IBOutlet weak var heartBeatView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crearContenedor()
        
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
                        let ritmoCard = "\(data!.heartRate)"
                        self.heartBeatLabel.text = ritmoCard
                        ritmoNumero = ritmoCard
                        DispatchQueue.main.async {
                            GlobalVariables.sharedInstance.registrarRitmoCardiaco(ritmo: ritmoCard)
                        }
                    }
                })
            }
        }
        mBand.sendHaptic()
        mBand.sendHaptic() { error in
            print("[MSB] Error sendHaptic: \(error)")
            
        }
    }
    
    func crearContenedor(){
        let params: [String:Any] = [
            "container": [
                "id":"RitmoCardiacoContainer"
            ]
        ]
        
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.post("/m2m/applications/DroneFit/containers", parameters: params, progress: { (progress) in
            
        }, success: { (task:URLSessionDataTask, response) in
            let dictionaryResponse: NSDictionary = response! as! NSDictionary
            print(dictionaryResponse)
            let alertController = UIAlertController(title: "Contenedor Creado", message: dictionaryResponse["contentInstance"] as? String, preferredStyle: .alert)
            
            let volverAction = UIAlertAction(title: "Regresar", style: .default) { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(volverAction)
            self.present(alertController, animated: true)
        }) { (task: URLSessionDataTask?, error: Error) in
            GlobalVariables.sharedInstance.displayAlertMessage(view: self, messageToDisplay: "Error en la solicitud")
        }
    }
    
    
}
