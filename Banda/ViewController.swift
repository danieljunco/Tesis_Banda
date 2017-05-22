//
//  ViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/22/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit
import MicrosoftBand

class ViewController:UIViewController, ConnectionDelegate {
    
    var mBand: MicrosoftBand!
    let titleId = UUID(uuidString: "")!
    let titleName = "Wereable Hub"
    let titleIcon = "A"
    let smallIcon = "Aa"
    

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let mBand = MicrosoftBand()
        self.mBand = mBand
        self.mBand.connectDelegate = self
        
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
        
        print("isBluetooth \(self.mBand.isBluetoothOn())")
        print("name \(self.mBand.name)")
        print("deviceIdentifier \(self.mBand.deviceIdentifier)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 80.0){
            do {
                try self.mBand.stopAccelerometerUpdates()
                try self.mBand.stopHeartRateUpdates()
            }catch {
                print("Stop Error ....\(error)")
            }
            print("Disconnecting...")
            self.mBand.disconnect()
        }
        print("UserConsent...\(self.mBand.userConsent.rawValue)")
    }
    
    func onConnecte() {
        print("onConnecte..")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0 ){
            print("hardwareVersion \(self.mBand.hardwareVersion)")
            print("firmwareVersion \(self.mBand.firmwareVersion)")
        }
        self.mBand.requestUserConsent { (result) in
            if(result){
                print("requestUserConstent...\(result), callingHR")
                try! self.mBand.startHeartRateUpdates(completion: { (data, error) in
                    if error != nil {
                        print("heartRate error \(error)")
                    } else {
                        print("heartRate data \(data) \(data?.heartRate) \(data?.quality)")
                    }
                })
            }
        }
        self.mBand.sendHaptic()
        self.mBand.sendHaptic() { error in
            print("[MSB] Error sendHaptic: \(error)")
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0 ){
            self.mBand.sendBandNotification(tileId: self.titleId, title: "sumo", body: "good work 123 3333 3333 ", completion: { (error) in
                print("[MSB] Error sendBandNotification: \(error)")
            })
        }
        
    }
    
    func onDisconnecte() {
        print("onDiconnected...")
    }
    func onError(error: Error) {
        print("error11 \(error)")
    }

}

