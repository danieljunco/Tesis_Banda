//
//  BandillaViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/23/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit
import MicrosoftBandKit_iOS
import MicrosoftBand
import AFNetworking

var mBand: MicrosoftBand!

var caloriesNumero = ""

class BandillaViewController: UIViewController, ConnectionDelegate {
    
    
    
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var viewCalories: UIView!
    
    let titleId = UUID(uuidString: "be2066df-306f-438e-860c-f82a8bc0bd6a")!
    let titleName = "Wereable Hub"
    let titleIcon = "A"
    let smallIcon = "Aa"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crearContenedor()
        GlobalVariables.sharedInstance.displayAlertMessage(view: self, messageToDisplay: "Connecting to Microsoft Band 2......")
        viewCalories.layer.cornerRadius = 120
        viewCalories.layer.borderWidth = 2
        let c = GlobalVariables.sharedInstance.hexStringToUIColor(hex: "#d35400")
        viewCalories.layer.borderColor = c.cgColor
        viewCalories.layer.shadowColor = c.cgColor
        viewCalories.layer.shadowOffset = CGSize(width: -3.75, height: -4)
        viewCalories.layer.shadowRadius = 1.7
        viewCalories.layer.shadowOpacity = 0.55

        

        
        connection()
    }
    
    func connection(){
        
        let mBand2 = MicrosoftBand()
        mBand = mBand2
        mBand.connectDelegate = self
        
        do {
            _ = try mBand.connect()
        } catch ConnectionError.BluetoothUnavailable{
            print("BluetoothUnavailable...")
        }
        catch ConnectionError.DeviceUnavailable{
            print("DeviceUnavailable...")
        }
        catch {
            print ("Any Error")
        }
        
        print("isBluetooth \(mBand.isBluetoothOn())")
        print("name \(mBand.name)")
        print("deviceIdentifier \(mBand.deviceIdentifier)")
    }
    
    func onConnecte() {
        print("onConnecte..")
        
        mBand.requestUserConsent { (result) in
            if(result){
                print("requestUserConstent...\(result), callingHR")
                try! mBand.startCaloriesUpdates(completion: { (data, error) in
                    if error != nil {
                        print("calories error \(error)")
                    } else {
                        print("calories data \(data) \(data?.caloriesToday)")
                        let numerocalorias = "\(data!.caloriesToday)"
                        self.caloriesLabel.text = numerocalorias
                        caloriesNumero = numerocalorias
                        DispatchQueue.main.async {
                            GlobalVariables.sharedInstance.registrarCalorias(calorias: numerocalorias)
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
                "id":"CaloriasContainer"
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
