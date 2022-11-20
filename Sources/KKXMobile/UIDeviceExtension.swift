//
//  UIDeviceExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit
import CoreTelephony

// MARK: - -------- 网络运营商信息 --------

extension UIDevice {
    
    /// 运营商列表
    public static var carriers: [CTCarrier]? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            return networkInfo.serviceSubscriberCellularProviders?.map { $0.value }
        } else if let provider = networkInfo.subscriberCellularProvider {
            return [provider]
        }
        return nil
    }
    
    /// 主号运营商
    public static var currentCarrier: CTCarrier? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 13.0, *),
           let identifier = networkInfo.dataServiceIdentifier {
            return networkInfo.serviceSubscriberCellularProviders?[identifier]
        } else if #available(iOS 12.0, *) {
            return networkInfo.serviceSubscriberCellularProviders?.map { $0.value }.first
        } else {
            return networkInfo.subscriberCellularProvider
        }
    }
    
    public static var radioAccessTechnologys: [String]? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            return networkInfo.serviceCurrentRadioAccessTechnology?.map { $0.value }
        } else if let technology = networkInfo.currentRadioAccessTechnology {
            return [technology]
        }
        return nil
    }
    
    public static var currentRadioAccessTechnology: String? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 13.0, *),
           let identifier = networkInfo.dataServiceIdentifier {
            return networkInfo.serviceCurrentRadioAccessTechnology?[identifier]
        } else if #available(iOS 12.0, *) {
            return networkInfo.serviceCurrentRadioAccessTechnology?.map { $0.value }.first
        } else {
            return networkInfo.currentRadioAccessTechnology
        }
    }
}

//import System
//import MachO

// MARK: - -------- Memory Usage --------

/// 设备内存使用情况
public struct DeviceMemoryUsage {
    /// 内存总容量
    public var total: UInt = 0
    /// 未使用的RAM容量，随时可以被应用分配使用
    public var free: UInt = 0
    /// 用来存放内核代码和数据结构，主要为内核服务，如负责网络、文件系统之类的；对于应用、framework、一些用户级别的软件是没办法分配次内存的。但是应用程序也会对Wired Memory的分配有所影响
    public var wired: UInt = 0
    /// 活跃的内存，正在被使用或很短时间内被使用过
    public var active: UInt = 0
    /// 最近被使用过，但是目前处于不活跃状态。
    /// 例如，如果您使用了邮件然后退出，则邮件曾经使用的RAM会标记为“不活跃”内存。“不活跃“可供其他应用软件使用，就像”可用“内存一样。但是，如果在其他应用软件占用邮件的”不活跃“内存之前打开了邮件，邮件的打开速度会很快，因为其”不活跃“内存会转换为”活跃“内存，而不是从较慢的驱动器进行载入
    public var inactive: UInt = 0
    
    /// 使用过的内存，包括Wired Memory、Active Memory、Inactive Memory等
    public var used: UInt {
        total - free
    }
    
    public init(total: UInt = 0, free: UInt = 0, wired: UInt = 0, active: UInt = 0, inactive: UInt = 0) {
        self.total = total
        self.free = free
        self.wired = wired
        self.active = active
        self.inactive = inactive
    }
}

/*
public var totalMemory: Int64 {
    var size: Int = MemoryLayout<Int>.size
    var results: Int = 0
    var mib = [CTL_HW, HW_PHYSMEM]
    sysctl(&mib, 2, &results, &size, nil, 0);
    return Int64(results)
}
*/
extension UIDevice {
    /// 内存使用信息
    public class var memoryInfo: DeviceMemoryUsage {
        let hostPort = mach_host_self()
        var hostSize = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride/MemoryLayout<integer_t>.stride)
        var pageSize: vm_size_t = 0
        host_page_size(hostPort, &pageSize)
        
        var vmStat: vm_statistics = vm_statistics_data_t()
        let capacity = MemoryLayout.size(ofValue: vmStat) / MemoryLayout<Int32>.stride
        let kernReturn: kern_return_t = withUnsafeMutableBytes(of: &vmStat) { str in
            let boundPtr = str.baseAddress?.bindMemory(to: Int32.self, capacity: capacity)
            return host_statistics(hostPort, HOST_VM_INFO, boundPtr, &hostSize)
        }
        
        var usage = DeviceMemoryUsage()
        if kernReturn == KERN_SUCCESS {
            let total = ProcessInfo.processInfo.physicalMemory
            let freeMemory = vm_size_t(vmStat.free_count) * pageSize
            let wiredMemory = vm_size_t(vmStat.wire_count) * pageSize
            let activeMemory = vm_size_t(vmStat.active_count) * pageSize
            let inactiveMemory = vm_size_t(vmStat.inactive_count) * pageSize
            usage.total = UInt(total)
            usage.free = freeMemory
            usage.wired = wiredMemory
            usage.active = activeMemory
            usage.inactive = inactiveMemory
        }
        return usage
    }
}

// MARK: - -------- Disk Usage --------

/// 设备磁盘使用情况
public struct DeviceDiskUsage {
    /// 磁盘总容量
    public var total: UInt = 0
    /// 未使用磁盘容量
    public var free: UInt = 0
    
    public init(total: UInt = 0, free: UInt = 0) {
        self.total = total
        self.free = free
    }
}

/// 硬盘使用情况
extension UIDevice {
    /// 磁盘使用信息
    public class var diskInfo: DeviceDiskUsage {
        var usage = DeviceDiskUsage()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let path = paths.last {
            let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: path)
            if let total = dictionary?[.systemSize] as? UInt,
               let free = dictionary?[.systemFreeSize] as? UInt {
                usage.total = total
                usage.free = free
            }
        }
        return usage
    }
}

extension UIDevice {
    
    /// 系统名 + 系统版本，如：iOS 11.0
    public var systemNameVersion: String {
        systemName + " " + systemVersion
    }
    
    public static var machine: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machine = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return machine
    }
    
    /// 设备型号
    public var machineType: String {
        let identifier = UIDevice.machine
        switch identifier {
        
        // MARK: - iPhone
        
        case "i386", "x86_64": return "iPhone Simulator"
        
        case "iPhone1,1": return "iPhone"
        case "iPhone1,2": return "iPhone 3G"
        case "iPhone2,1": return "iPhone 3GS"
            
        case "iPhone3,1",
             "iPhone3,2",
             "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
            
        case "iPhone5,1": return "iPhone 5"
        case "iPhone5,2": return "iPhone 5c (GSM+CDMA)"
        case "iPhone5,3": return "iPhone 5c (GSM)"
        case "iPhone5,4": return "iPhone 5c (GSM+CDMA)"
            
        case "iPhone6,1": return "iPhone 5s (GSM)"
        case "iPhone6,2": return "iPhone 5s (GSM+CDMA)"
            
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone7,2": return "iPhone 6"
            
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE"
            
        case "iPhone9,1",
             "iPhone9,3": return "iPhone 7"
        case "iPhone9,2",
             "iPhone9,4": return "iPhone 7 Plus"
            
        case "iPhone10,1",
             "iPhone10,4": return "iPhone 8"
        case "iPhone10,2",
             "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3",
             "iPhone10,6": return "iPhone X"
            
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4",
             "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
            
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd generation)"
            
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
            
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 minu"
        case "iPhone14,5": return "iPhone 13"
            
        // MARK: - iPad
        
        case "iPad1,1": return "iPad"
        case "iPad1,2": return "iPad 3G"
            
        case "iPad2,1",
             "iPad2,2",
             "iPad2,3",
             "iPad2,4": return "iPad 2"
        case "iPad2,5",
             "iPad2,6",
             "iPad2,7": return "iPad Mini"
            
        case "iPad3,1",
             "iPad3,2",
             "iPad3,3": return "iPad 3"
        case "iPad3,4",
             "iPad3,5",
             "iPad3,6": return "iPad 4"
            
        case "iPad4,1",
             "iPad4,2",
             "iPad4,3": return "iPad Air"
        case "iPad4,4",
             "iPad4,5",
             "iPad4,6": return "iPad Mini 2"
        case "iPad4,7",
             "iPad4,8",
             "iPad4,9": return "iPad Mini 3"
            
        case "iPad5,1",
             "iPad5,2": return "iPad Mini 4"
        case "iPad5,3",
             "iPad5,4": return "iPad Air 2"
            
        case "iPad6,3",
             "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad6,7",
             "iPad6,8": return "iPad Pro (12.9-inch)"
        case "iPad6,11",
             "iPad6,12": return "iPad 5"
            
        case "iPad7,1",
             "iPad7,2": return "iPad Pro 2 (12.9-inch)"
        case "iPad7,3",
             "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad7,5",
             "iPad7,6": return "iPad 6"
        case "iPad7,11",
             "iPad7,12": return "iPad 7"
            
        case "iPad8,1",
             "iPad8,2",
             "iPad8,3",
             "iPad8,4": return "iPad Pro (11-inch)"
        case "iPad8,5",
             "iPad8,6",
             "iPad8,7",
             "iPad8,8": return "iPad Pro 3 (12.9-inch)"
        case "iPad8,9",
             "iPad8,10": return "iPad Pro 2 (11-inch)"
        case "iPad8,11",
             "iPad8,12": return "iPad Pro 4 (12.9-inch)"
            
        case "iPad11,1",
             "iPad11,2": return "iPad mini 5"
        case "iPad11,3",
             "iPad11,4": return "iPad Air 3"
        case "iPad11,6",
             "iPad11,7": return "iPad 8"
            
        case "iPad12,1",
             "iPad12,2": return "iPad 9"
            
        case "iPad13,1",
             "iPad13,2": return "iPad Air 4"
        case "iPad13,4",
             "iPad13,5",
             "iPad13,6",
             "iPad13,7": return "iPad Pro 4 (11-inch)"
        case "iPad13,8",
             "iPad13,9",
             "iPad13,10",
             "iPad13,11": return "iPad Pro 5 (12.9-inch)"
            
        case "iPad14,1",
             "iPad14,2": return "iPad mini 6"
            
        // MARK: - iPod
        
        case "iPod1,1": return "iPod Touch 1"
        case "iPod2,1": return "iPod Touch 2"
        case "iPod3,1": return "iPod Touch 3"
        case "iPod4,1": return "iPod Touch 4"
        case "iPod5,1": return "iPod Touch 5"
        case "iPod7,1": return "iPod Touch 6"
        case "iPod9,1": return "iPod Touch 7"
            
        // MARK: - AppleTV
        
        case "AppleTV2,1": return "Apple TV 2"
        case "AppleTV3,1",
             "AppleTV3,2": return "Apple TV 3"
        case "AppleTV5,3": return "Apple TV 4"
            
        default:  return identifier
        }
    }
}
