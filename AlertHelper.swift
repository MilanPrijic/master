//
//  AlertHelper.swift
//  VitalDoc
//
//  Created by Milan Prijic on 4/22/16.
//  Copyright © 2016 DigitalShare. All rights reserved.
//

import UIKit
import CoreData

class AlertHelper {
    
    func createAlertWithOkButton(_ title: String, message: String) -> UIAlertController{
        
        let alert = UIAlertController(title: title as String, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) -> Void in
            
        }
        alert.view.tintColor = UIColor.orange
        alert.addAction(okButton)
        
        return alert
    }
    
    func unableToCatchResponseAlert() -> UIAlertController{
        
        let alert = UIAlertController(title: "Oups...", message: "We were unable to catch response from the server, please try again or notify us about this error by email xxxx@xxxx.xxx!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) -> Void in
            
        }
        alert.view.tintColor = UIColor.orange
        alert.addAction(okButton)
        
        return alert
    }
    
    func unableToParseResponseAlert() -> UIAlertController{
        
        let alert = UIAlertController(title: "Oups...", message: "We were unable to parse response from the server, please try again or notify us about this error by email xxxx@xxxx.xxx!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) -> Void in
            
        }
        alert.view.tintColor = UIColor.orange
        alert.addAction(okButton)
        
        return alert
    }
    
    func unableToSendRequestAlert() -> UIAlertController{
        
        let alert = UIAlertController(title: "Oups...", message: "We were unable to send request to the server, please try again or notify us about this error by email xxxx@xxxx.xxx!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) -> Void in
            
        }
        alert.view.tintColor = UIColor.orange
        alert.addAction(okButton)
        
        return alert
    }
    
    func serverResponseError(message: String) -> UIAlertController{
        
        let alert = UIAlertController(title: "Validation failed!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) -> Void in
            
        }
        alert.view.tintColor = UIColor.orange
        alert.addAction(okButton)
        
        return alert
    }
    
    func unableToFetchResultsAlert(from: String) -> UIAlertController{
        
        let alert = UIAlertController(title: "Oups...", message: "We were unable to fetch results from \(from), please try again or notify us about this error by email xxxx@xxxx.xxx!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) -> Void in
            
        }
        alert.view.tintColor = UIColor.orange
        alert.addAction(okButton)
        
        return alert
    }
    
    func unableToSaveData(from: String) -> UIAlertController{
        
        let alert = UIAlertController(title: "Oups...", message: "We were unable to save \(from), please try again or notify us about this error by email xxxx@xxxx.xxx!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) -> Void in
            
        }
        alert.view.tintColor = UIColor.orange
        alert.addAction(okButton)
        
        return alert
    }
    
    func unableToSaveDeletedData(from: String) -> UIAlertController{
        
        let alert = UIAlertController(title: "Oups...", message: "We were unable to delete \(from), please try again or notify us about this error by email xxxx@xxxx.xxx!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) -> Void in
            
        }
        alert.view.tintColor = UIColor.orange
        alert.addAction(okButton)
        
        return alert
    }

}
