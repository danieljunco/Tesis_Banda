//
//  PasosViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/24/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit
import AFNetworking

class PasosViewController: UIViewController {

    @IBOutlet weak var pasosLabel: UILabel!
    @IBOutlet weak var pasosView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crearContenedor()
        
        pasosView.layer.cornerRadius = 120
        pasosView.layer.borderWidth = 2
        let c = GlobalVariables.sharedInstance.hexStringToUIColor(hex: "#34495e")
        pasosView.layer.borderColor = c.cgColor
        pasosView.layer.shadowColor = c.cgColor
        pasosView.layer.shadowOffset = CGSize(width: -3.75, height: -4)
        pasosView.layer.shadowRadius = 1.7
        pasosView.layer.shadowOpacity = 0.55
        
        startStepsCount()

    }
    
    func startStepsCount(){
        print("onConnecteSteps..")
        
        mBand.requestUserConsent { (result) in
            if(result){
                print("requestUserConstent...\(result), callingHR")
                try! mBand.startPedometerUpdates(completion: { (data, error) in
                    if error != nil {
                        print("temperature error \(error)")
                    } else {
                        print("temperature data \(data) \(data?.stepsToday)")
                        let pasos = "\(data!.stepsToday)"
                        self.pasosLabel.text = pasos
                        DispatchQueue.main.async {
                            GlobalVariables.sharedInstance.registrarSensores(calorias: caloriesNumero, ritmo: ritmoNumero, pasos: pasos, temperatura: skinTemperature)
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
                "id":"SensoresContainer"
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
