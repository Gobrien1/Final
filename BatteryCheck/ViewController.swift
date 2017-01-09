//
//  ViewController.swift
//  BatteryCheck
//
//  Created by Student on 10/12/2016.
//  Copyright © 2016 George O'Brien. All rights reserved.
//

import UIKit
import CoreBluetooth

struct beacon {
    var name:NSString
    var rssi:NSNumber
    var power:Int
}

class ViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var centralManager: CBCentralManager!
    var beacons: [beacon] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("did update state")
        
        if #available(iOS 10.0, *) {
            if central.state == CBManagerState.poweredOn
            {
                self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
  
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      
      if peripheral.name != "Kontakt" { return }
      let serviceData = advertisementData[ CBAdvertisementDataServiceDataKey ] as! Dictionary<CBUUID, Data>
      if let nameAndPower = serviceData[ CBUUID(string:"D00D") ] {
        
        let name = NSString(data: nameAndPower.subdata(in: Range(uncheckedBounds: (0,4))), encoding: String.Encoding.ascii.rawValue)!
        var power: Int = 0;
        (nameAndPower as NSData).getBytes(&power, range: NSMakeRange(6, 1))
        
        print( "\(name) \(power)%" )
        beacons.append( beacon(name: name, rssi: RSSI, power: power) )
        refreshTableView()
      }
    }
    
    func refreshTableView() {
        
        activityIndicator.stopAnimating()
        beacons.sort { (lhs, rhs) in return lhs.rssi.intValue > rhs.rssi.intValue }
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return beacons.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "beaconCell", for: indexPath)

        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            nameLabel.text = beacons[indexPath.row].name as String
        }
        
        if let rssiLabel = cell.viewWithTag(2) as? UILabel {
            rssiLabel.text = "rssi: \(beacons[indexPath.row].rssi)"
        }
        
        
        if let powerLabel = cell.viewWithTag(3) as? UILabel { 
            powerLabel.text = "\(beacons[indexPath.row].power)%"
        }

        return cell
        
    }


}

