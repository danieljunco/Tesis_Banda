import Foundation
import MicrosoftBandKit_iOS

public typealias ErrorBlock = (Error?) -> Void

@objc public enum ConnectionStatus: UInt {
    case Connected
    case Disconnected
}

@objc public enum ConnectionError:UInt, Error {
    case BluetoothUnavailable
    case DeviceUnavailable
}

@objc public enum UserConsent:UInt {
    case NotSpecified
    case Granted
    case Declined
}


@objc public protocol Peripheral {
    
    var name: String { get }
    var deviceIdentifier: UUID { get }
    var hardwareVersion: String { get }
    var firmwareVersion: String { get }
    
    func connect() throws
    func disconnect()
}


@objc public protocol ConnectionDelegate {
    @objc optional  func onConnecte()
    @objc optional  func onDisconnecte()
    @objc optional  func onError(error: Error)
}

@objc(MicrosoftBand)
public class MicrosoftBand: NSObject, Peripheral, MSBClientManagerDelegate {
    
    var client: MSBClient!

    public var name: String {
         if let currentClient = self.client {
            return currentClient.name
         } else {
            return "Microsoft Band"
        }
    }
    
    public var deviceIdentifier: UUID {
        if let currentClient = self.client {
            return currentClient.connectionIdentifier
        } else {
            return UUID()
        }
    }
    
    public var isDeviceConnected: Bool {
        if let currentClient = self.client {
            return currentClient.isDeviceConnected
        } else {
            return false
        }
    }
    
    public var userConsent: UserConsent {
        if let currentClient = self.client {
            let consent = currentClient.sensorManager.heartRateUserConsent()
            switch (consent) {
                case MSBUserConsent.granted : return UserConsent.Granted
                case MSBUserConsent.notSpecified: return UserConsent.NotSpecified
                case MSBUserConsent.declined: return UserConsent.Declined
            }
        } else {
            return UserConsent.NotSpecified
        }
    }
    
    private(set) public var hardwareVersion:   String = "NotSet-ConnectFirst"
    private(set) public var firmwareVersion:   String = "NotSet-ConnectFirst"
    
    public var connectDelegate: ConnectionDelegate?
    
    public override init() {
        super.init()
        MSBClientManager.shared().delegate = self
    }
    
    public func isBluetoothOn()-> Bool {
        return MSBClientManager.shared().isPowerOn
    }
    
    
    public func connect() throws {
        MSBClientManager.shared().delegate = self
        if let client = MSBClientManager.shared().attachedClients().first as? MSBClient {
            self.client = client
            MSBClientManager.shared().connect(self.client)
            print("\(self.name) Connecting....")

        } else {
            if(!MSBClientManager.shared().isPowerOn) {
                throw ConnectionError.BluetoothUnavailable
            } else {
                throw ConnectionError.DeviceUnavailable
            }
        }
    }
    
    public func disconnect() {
        if let currentClient = self.client {
            MSBClientManager.shared().cancelClientConnection(currentClient)
        }
    }
    
    public func requestUserConsent(userConsent: @escaping (_ isGranted: Bool) -> Void) {
        switch (self.userConsent) {
        case .Granted:
            userConsent(true)
            break
        case .NotSpecified, .Declined:
            self.client?.sensorManager.requestHRUserConsent(completion: { (isGranted:Bool, error:Error?) -> Void in
                if(error == nil) {
                    userConsent(isGranted)
                } else {
                    print("[MSB] Error requestHRUserConsent: \(error)")
                    userConsent(false)
                }
            })
        }
    }
    
    public func startAccelerometerUpdates(completion: @escaping ((_ data: AccelerometerData?, _ error : Error?) -> ()) ) throws{
        try self.client.sensorManager.startAccelerometerUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( AccelerometerData(x: data.x,y: data.y,z: data.z), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopAccelerometerUpdates() throws {
        try self.client.sensorManager.stopAccelerometerUpdatesErrorRef()
    }
    
    public func startGyroscopeUpdates(completion: @escaping ((_ data: GyroscopeData?, _ error : Error?) -> ()) ) throws{
        try self.client.sensorManager.startGyroscopeUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( GyroscopeData(x: data.x,y: data.y,z: data.z), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopGyroscopeUpdates() throws {
        try self.client.sensorManager.stopGyroscopeUpdatesErrorRef()
    }
    
    public func startHeartRateUpdates(completion: @escaping ((_ data: HeartRateData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startHeartRateUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                
                let quality : HeartRateData.Quality = {
                    switch data.quality {
                    case .acquiring:
                        return HeartRateData.Quality.Acquiring
                    case .locked:
                        return  HeartRateData.Quality.Locked
                    }
                }()
                completion( HeartRateData(heartRate: data.heartRate,  quality:quality), nil)
            } else {
                completion(nil, error)
            }
        })
    }

    public func stopHeartRateUpdates() throws {
        try self.client.sensorManager.stopHeartRateUpdatesErrorRef()
    }

    public func startCaloriesUpdates(completion: @escaping ((_ data: CaloriesData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startCaloriesUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( CaloriesData(calories: data.calories,caloriesToday: data.caloriesToday), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopCaloriesUpdates() throws {
        try self.client.sensorManager.stopCaloriesUpdatesErrorRef()
    }
    
    public func startDistanceUpdates(completion: @escaping ((_ data: DistanceData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startDistanceUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                
                let motionType : DistanceData.MotionType = {
                    switch data.motionType {
                    case .unknown:
                        return DistanceData.MotionType.Unknown
                    case .idle:
                        return DistanceData.MotionType.Idle
                    case .walking:
                        return DistanceData.MotionType.Walking
                    case .jogging:
                        return DistanceData.MotionType.Jogging
                    case .running:
                        return DistanceData.MotionType.Running
                    }
                }()
                completion( DistanceData(totalDistance: data.totalDistance , distanceToday: data.distanceToday,
                                         speed:data.speed, pace:data.pace, motionType: motionType), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopDistanceUpdates() throws {
        try self.client.sensorManager.stopDistanceUpdatesErrorRef()
    }
    
    
    public func startPedometerUpdates(completion: @escaping ((_ data: PedometerData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startPedometerUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( PedometerData(totalSteps: data.totalSteps,stepsToday: data.stepsToday), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopPedometerUpdates() throws {
        try self.client.sensorManager.stopPedometerUpdatesErrorRef()
    }
    
 
    public func startSkinTempUpdates(completion: @escaping ((_ data: SkinTemperatureData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startSkinTempUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( SkinTemperatureData(temperature: data.temperature), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopSkinTempUpdates() throws {
        try self.client.sensorManager.stopSkinTempUpdatesErrorRef()
    }
    
    
    public func startUVUpdates(completion: @escaping ((_ data: UVData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startUVUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                
                let uvIndexLevel : UVData.IndexLevel = {
                    switch data.uvIndexLevel {
                    case .none:
                        return UVData.IndexLevel.None
                    case .low:
                        return UVData.IndexLevel.Low
                    case .medium:
                        return UVData.IndexLevel.Medium
                    case .high:
                        return UVData.IndexLevel.High
                    case .veryHigh:
                        return UVData.IndexLevel.VeryHigh
                    }
                }()
                
                completion( UVData(exposureToday: data.exposureToday, uvIndexLevel: uvIndexLevel), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopUVUpdates() throws {
        try self.client.sensorManager.stopUVUpdatesErrorRef()
    }
    
    public func startBandContactUpdates(completion: @escaping ((_ data: ContactData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startBandContactUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                
                let wornState : ContactData.WornState = {
                    switch data.wornState {
                    case .notWorn:
                        return ContactData.WornState.NotWorn
                    case .worn:
                        return ContactData.WornState.Worn
                    case .unknown:
                        return ContactData.WornState.Unknown
                    }
                }()
                
                completion( ContactData(wornState: wornState), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopBandContactUpdates() throws {
        try self.client.sensorManager.stopBandContactUpdatesErrorRef()
    }
    
    public func startGSRUpdates(completion: @escaping ((_ data: GSRData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startGSRUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( GSRData(resistance: data.resistance), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopGSRUpdates() throws {
        try self.client.sensorManager.stopGSRUpdatesErrorRef()
    }
    
 
    public func startRRIntervalUpdates(completion: @escaping ((_ data: RRIntervalData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startRRIntervalUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( RRIntervalData(interval: data.interval), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopRRIntervalUpdates() throws {
        try self.client.sensorManager.stopRRIntervalUpdatesErrorRef()
    }
 
    
    public func startAmbientLightUpdates(completion: @escaping ((_ data: AmbientLightData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startAmbientLightUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( AmbientLightData(brightness: data.brightness), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopAmbientLightUpdates() throws {
        try self.client.sensorManager.stopAmbientLightUpdatesErrorRef()
    }
    
    public func startBarometerUpdates(completion: @escaping ((_ data: BarometerData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startBarometerUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( BarometerData(temperature: data.temperature,airPressure: data.airPressure), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopBarometerUpdates() throws {
        try self.client.sensorManager.stopBarometerUpdatesErrorRef()
    }
    
    public func startAltimeterUpdates(completion: @escaping ((_ data: AltimeterData?, _ error : Error?) -> ()) ) throws {
        try self.client.sensorManager.startAltimeterUpdates(to: nil,  withHandler: { (data, error) in
            if let data = data {
                completion( AltimeterData(totalGain:data.totalGain,totalGainToday:data.totalGain,
                                          totalLoss:data.totalLoss,steppingGain:data.steppingGain,
                                          steppingLoss:data.steppingLoss,stepsAscended:data.stepsAscended,
                                          stepsDescended:data.stepsDescended,rate:data.rate,
                                          flightsAscended:data.flightsAscended,flightsAscendedToday:data.flightsAscendedToday,
                                          flightsDescended:data.flightsDescended), error)
            } else {
                completion(nil, error)
            }
        })
    }
    
    public func stopAltimeterUpdates() throws {
        try self.client.sensorManager.stopAltimeterUpdatesErrorRef()
    }
    
    
    
    public func addTile(tileId : UUID, tileName: String , tileIcon : String, smallIcon: String, completion: ErrorBlock? = nil) {
        if let currentClient = self.client {
            if currentClient.isDeviceConnected {
                
                let tileIcon    = try? MSBIcon(uiImage: UIImage(named:tileIcon))
                let smallIcon   = try? MSBIcon(uiImage: UIImage(named: smallIcon))

                let tile = try? MSBTile(id: tileId, name: tileName, tileIcon: tileIcon, smallIcon: smallIcon)
                
                currentClient.tileManager.add(tile){ error in
                    if error != nil && (error as! NSError).code != MSBErrorType.tileAlreadyExist.rawValue {
                         completion?(error)
                    }
                }
            }
        }
    }
    
    public func sendHaptic(completion: ((Error?) -> ())? = nil) {
        if let currentClient = self.client {
            currentClient.notificationManager.vibrate(with: MSBNotificationVibrationType.twoToneHigh) { error in
                if (error != nil) {
                    completion?(error)
                }
            }
        }
    }
    
    public func sendBandNotification(tileId : UUID, title: String, body: String, completion: ErrorBlock? = nil) {
        if let currentClient = self.client {
            currentClient.notificationManager.sendMessage(withTileID: tileId, title: title, body: body, timeStamp: Date(), flags: .showDialog){ error in
                if (error != nil) {
                    completion?(error)
                }
            }
        }
    }

    public func clientManager(_ clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        client.firmwareVersion(completionHandler: { (version, error) -> Void in
            self.firmwareVersion = version!
            client.hardwareVersion(completionHandler: { (version, error) -> Void in
                self.hardwareVersion = version!
                self.connectDelegate?.onConnecte?()
            })
        })
    }
    
    public func clientManager(_ clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        self.connectDelegate?.onDisconnecte?()
    }
    
    public func clientManager(_ clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: Error!) {
        self.connectDelegate?.onError?(error: error)
    }
    
}
