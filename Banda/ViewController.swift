//
//  ViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/22/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit
import MicrosoftBandKit_iOS
import MicrosoftBand
import CoreBluetooth
import AVFoundation

class ViewController:UIViewController, ConnectionDelegate, UITableViewDelegate, UITableViewDataSource{
    
    var mBand: MicrosoftBand!
    let titleId = UUID(uuidString: "be2066df-306f-438e-860c-f82a8bc0bd6a")!
    let titleName = "Wereable Hub"
    let titleIcon = "A"
    let smallIcon = "Aa"
    
    let nombreCategorias = ["Ritmo Cardiaco","Actividad","Rutina","Ambiente"]
    let imagenes = [#imageLiteral(resourceName: "HeartbeatWhite"),#imageLiteral(resourceName: "Running2"),#imageLiteral(resourceName: "Running2"),#imageLiteral(resourceName: "Running2")]
    var valoresRitmo: [UInt] = [UInt]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
                        self.valoresRitmo.append((data?.heartRate)!)
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nombreCategorias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell")!
        
        let nombreCategoria: UILabel = cell.viewWithTag(1) as! UILabel
        nombreCategoria.text = nombreCategorias[indexPath.row]
        
        let imageView: UIImageView = cell.viewWithTag(3) as! UIImageView
        imageView.image = imagenes[indexPath.row]
        
        
        let valor: UILabel = cell.viewWithTag(2) as! UILabel
        if valoresRitmo.isEmpty {
            valor.isHidden = true
        }
        else {
            valor.isHidden = false
            valor.text = String(valoresRitmo.removeLast())
        }
        
        
        
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.mBand.disconnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.mBand.disconnect()
    }
    
    
    func onDisconnecte() {
        print("onDiconnected...")
    }
    func onError(error: Error) {
        print("error11 \(error)")
    }

}

