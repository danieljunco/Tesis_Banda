//
//  GlobalVariables.swift
//  Banda
//
//  Created by Daniel Junco on 5/23/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking

class GlobalVariables: NSObject {
    
    
    static let sharedInstance = GlobalVariables()
    //Previene otras calses usar el '()' inicializador de esta clase.
    private override init() {}
    
    
    func registrarCalorias(calorias: String){
        let params: [String:Any] = [
            "Calorias": calorias
        ]
        
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.post("/m2m/applications/DroneFit/containers/CaloriasContainer/contentInstances", parameters: params, progress: { (progress) in
            
        }, success: { (task:URLSessionDataTask, response) in
            let dictionaryResponse: NSDictionary = response! as! NSDictionary
            print(dictionaryResponse)
        }) { (task: URLSessionDataTask?, error: Error) in
            print("Error")
        }

    }
    
    func registrarRitmoCardiaco(ritmo: String){
        let params: [String:Any] = [
            "Ritmo": ritmo
        ]
        
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.post("/m2m/applications/DroneFit/containers/RitmoCardiacoContainer/contentInstances", parameters: params, progress: { (progress) in
            
        }, success: { (task:URLSessionDataTask, response) in
            let dictionaryResponse: NSDictionary = response! as! NSDictionary
            print(dictionaryResponse)
        }) { (task: URLSessionDataTask?, error: Error) in
            print("Error")
        }

    }
    
    
    func registrarSensores(calorias: String, ritmo: String, pasos: String, temperatura: String){
        let params: [String:Any] = [
            "Calorias":calorias,
            "Ritmo": ritmo,
            "Pasos":pasos,
            "Temperatura":temperatura
            
            
        ]
        
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.post("/m2m/applications/DroneFit/containers/SensoresContainer/contentInstances", parameters: params, progress: { (progress) in
            
        }, success: { (task:URLSessionDataTask, response) in
            let dictionaryResponse: NSDictionary = response! as! NSDictionary
            print(dictionaryResponse)
        }) { (task: URLSessionDataTask?, error: Error) in
            print("Error")
        }
        
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func displayAlertMessage(view: UIViewController, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: "Alert", message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("Ok button tapped");
            
        }
        
        alertController.addAction(OKAction)
        
        view.present(alertController, animated: true, completion:nil)
    }
    
    
}

