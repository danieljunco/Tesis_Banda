import Foundation

@objc public enum SensorType: UInt {
    case Accelerometer, SkinTemperature, Humidity, Magnetometer, Gyroscope, Altimeter, Barometer, AmbientLight, Calories, GSR, Pedometer, HeartRate, RRInterval, UV, Contact, Distance
}

func getCurrentMillis()->NSInteger{
    return  NSInteger(NSDate().timeIntervalSince1970 * 1000)
}

@objc  public class  SensorData : NSObject {
    private(set) public var timestamp: NSInteger = getCurrentMillis()
    private(set) public var type: SensorType
    
    public init (type: SensorType) {
        self.type = type
    }
    
}

@objc  public class AccelerometerData: SensorData {
    private(set) public var x:Double
    private(set) public var y:Double
    private(set) public var z:Double
    

    public init(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
        super.init(type: SensorType.Accelerometer)
    }
}

@objc public class GyroscopeData : SensorData{
    public let x:Double
    public let y:Double
    public let z:Double
    
    public init(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
        super.init(type: SensorType.Gyroscope)
    }
}

@objc public class MagnetometerData : SensorData{
    public let x:Double
    public let y:Double
    public let z:Double
    
    public init(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
        super.init(type: SensorType.Magnetometer)
    }
}

@objc public class AltimeterData : SensorData{
    public let totalGain:UInt
    public let totalGainToday:UInt
    public let totalLoss:UInt
    public let steppingGain:UInt
    public let steppingLoss:UInt
    public let stepsAscended:UInt
    public let stepsDescended:UInt
    public let rate:Float
    public let flightsAscended:UInt
    public let flightsAscendedToday:UInt
    public let flightsDescended:UInt
    
    public init(totalGain:UInt, totalGainToday:UInt, totalLoss:UInt,
        steppingGain:UInt, steppingLoss:UInt, stepsAscended:UInt,
        stepsDescended:UInt, rate:Float, flightsAscended:UInt,
        flightsAscendedToday:UInt, flightsDescended:UInt) {
        self.totalGain          = totalGain
        self.totalGainToday     = totalGainToday
        self.totalLoss          = totalLoss
        self.steppingGain       = steppingGain
        self.steppingLoss       = steppingLoss
        self.stepsAscended      = stepsAscended
        self.stepsDescended     = stepsDescended
        self.rate               = rate
        self.flightsAscended    = flightsAscended
        self.flightsAscendedToday = flightsAscendedToday
        self.flightsDescended   = flightsDescended
        super.init(type: SensorType.Altimeter)
    }
}

@objc public class AmbientLightData : SensorData{
    public let brightness:Int32
    public init(brightness:Int32) {
        self.brightness = brightness
        super.init(type: SensorType.AmbientLight)
    }
}

@objc public class ContactData : SensorData{
    
    @objc public enum WornState: UInt {
        case NotWorn, Worn, Unknown
    }

    public let wornState:WornState
    public init(wornState:WornState) {
        self.wornState = wornState
        super.init(type: SensorType.Contact)
    }
}

@objc public class BarometerData : SensorData{
    public let airPressure:Double
    public let temperature:Double
    
    public init(temperature:Double, airPressure:Double) {
        self.temperature = temperature
        self.airPressure = airPressure
        super.init(type: SensorType.Barometer)
    }
}

@objc public class CaloriesData : SensorData{
    public let calories:UInt
    public let caloriesToday:UInt
    
    public init(calories:UInt,caloriesToday:UInt) {
        self.calories = calories
        self.caloriesToday = caloriesToday
        super.init(type: SensorType.Calories)
    }
}

@objc public class DistanceData : SensorData{
    @objc public enum MotionType: UInt {
        case Unknown, Idle, Walking, Jogging, Running
    }
    
    public let totalDistance:UInt
    public let distanceToday:UInt
    public let speed:Double
    public let pace:Double
    public let motionType:MotionType
    
    public init(totalDistance:UInt, distanceToday:UInt,
                speed:Double, pace:Double, motionType:MotionType) {
        self.totalDistance  = totalDistance
        self.distanceToday  = distanceToday
        self.speed          = speed
        self.pace           = pace
        self.motionType     = motionType
        super.init(type: SensorType.Distance)
    }
 
}

@objc public class GSRData : SensorData{
    public let resistance:UInt
    
    public init(resistance:UInt) {
        self.resistance = resistance
        super.init(type: SensorType.GSR)
    }
    
}

@objc public class HeartRateData : SensorData {
    
    @objc public enum Quality: UInt {
        case Acquiring, Locked
    }

    public let heartRate:UInt
    public let quality:Quality
    
    public init(heartRate:UInt, quality:Quality) {
        self.heartRate  = heartRate
        self.quality    = quality
        super.init(type: SensorType.HeartRate)
    }
}

@objc public class RRIntervalData : SensorData {
    public let interval:Double
    
    public init(interval:Double) {
        self.interval  = interval
        super.init(type: SensorType.RRInterval)
    }
}


@objc public class SkinTemperatureData : SensorData {
    public let temperature:Double
    public init(temperature:Double) {
        self.temperature  = temperature
        super.init(type: SensorType.SkinTemperature)
    }
}


@objc public class HumidityData : SensorData {
    public let humidity:Double
    
    public init(humidity:Double) {
        self.humidity  = humidity
        super.init(type: SensorType.Humidity)
    }
}

@objc public class PedometerData : SensorData {
    public let totalSteps:UInt
    public let stepsToday:UInt
    
    public init(totalSteps:UInt, stepsToday:UInt) {
        self.totalSteps  = totalSteps
        self.stepsToday  = stepsToday
        super.init(type: SensorType.Pedometer)
    }
}


@objc public class UVData : SensorData {
    @objc public enum IndexLevel: UInt {
        case None, Low, Medium, High, VeryHigh
    }
    
    // Total UV exposure today in minutes
    public let exposureToday:UInt
    public let uvIndexLevel:IndexLevel

    
    public init(exposureToday:UInt, uvIndexLevel:IndexLevel) {
        self.exposureToday  = exposureToday
        self.uvIndexLevel  = uvIndexLevel
        super.init(type: SensorType.UV)
    }
}
