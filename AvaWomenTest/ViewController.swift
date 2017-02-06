//
//  ViewController.swift
//  AvaWomenTest
//
//  Created by Milan Prijic on 2/4/17.
//  Copyright © 2017 Milan Prijic. All rights reserved.
//

import UIKit
import FSCalendar
import CoreData

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var uiCalendar: FSCalendar!
    
    @IBOutlet weak var uiHearthButton: UIButton!
    @IBOutlet weak var uiMenstruationButton: UIButton!
    
    @IBOutlet weak var uiHearthRateLabel: UILabel!
    @IBOutlet weak var uiCycleNumberLabel: UILabel!
    
    @IBOutlet weak var uiResponseLabel: UILabel!
    
    var selected = false;
    var markedSexDates:[String] = []
    var markedMenstruationDates:[String] = []
    
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.White()]
        
        self.navigationController?.navigationBar.barTintColor = Colors.ButterflyBush()
        self.navigationController?.view.backgroundColor = Colors.ButterflyBush()
        
        uiCalendar.appearance.weekdayTextColor = Colors.ButterflyBush()
        uiCalendar.appearance.headerTitleColor = Colors.ButterflyBush()
        
        uiCalendar.appearance.titleTodayColor = Colors.Black()
        uiCalendar.appearance.todayColor = UIColor.clear
        uiCalendar.allowsMultipleSelection = false
        uiCalendar.setCurrentPage(Date(), animated: false)
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        
        uiHearthRateLabel.textColor = Colors.ButterflyBush()
        uiCycleNumberLabel.textColor = Colors.ButterflyBush()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentDates")
        
        request.returnsObjectsAsFaults = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        do{
            
            let results = try context.fetch(request)
            
            if(results.count > 0){
                
                for result in results as! [NSManagedObject]{
                    
                    let newDate = CurrentDate()
                    newDate.date = result.value(forKey: "date") as! String
                    newDate.menstruation = result.value(forKey: "menstruation") as! Bool
                    newDate.sex = result.value(forKey: "sex") as! Bool
                    
                    currentDates.append(newDate)
                }
                
                for date in currentDates{
                    if(date.menstruation == true){
                        self.markedMenstruationDates.append(date.date)
                    }else{
                        self.markedSexDates.append(date.date)
                    }
                }
                
                uiCalendar.reloadData()
                
            }
            
        }catch{
            
            let alert = Alerts.unableToFetchResultsAlert(from: "dates")
            
            self.present(alert, animated: true, completion: nil)
            
        }
 
        
    }

    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selected = true
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selected = false
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if(self.markedSexDates.contains(dateFormatter.string(from: date))){
            return UIImage(named: "small sex")
        }
        else if(self.markedMenstruationDates.contains(dateFormatter.string(from: date))){
            return UIImage(named: "small menst")
        }
        else{
            return nil
        }
    }

    @IBAction func hearthButtonClicked(_ sender: UIButton) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if selected == true{
            
            if(self.markedMenstruationDates.contains(dateFormatter.string(from: uiCalendar.selectedDate))){
                
                let alert = Alerts.createAlertWithOkButton("Can not execute that!", message: "It is not recommended that you have sex during menstruation period, please remove menstruation mark from this date and try again!")
                
                self.present(alert, animated: true, completion: nil)
                
            }else{
            
            if(self.markedSexDates.contains(dateFormatter.string(from: uiCalendar.selectedDate))){
                if let itemToRemoveIndex = self.markedSexDates.index(of: dateFormatter.string(from: uiCalendar.selectedDate)){
                    self.markedSexDates.remove(at: itemToRemoveIndex)
                    
                    self.deleteBoomerang(type: "sex", date: dateFormatter.string(from: uiCalendar.selectedDate))
                }
            }else{
                self.markedSexDates.append(dateFormatter.string(from: uiCalendar.selectedDate))
                
                 self.postBoomerang(type: "sex", date: dateFormatter.string(from: uiCalendar.selectedDate))
            }
            
            uiCalendar.reloadData()
                
            }
        }
    }
    @IBAction func menstruationButtonClicked(_ sender: UIButton) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if selected == true{
        
            if(self.markedSexDates.contains(dateFormatter.string(from: uiCalendar.selectedDate))){
                
                let alert = Alerts.createAlertWithOkButton("Can not execute that!", message: "It is not recommended that you have sex during menstruation period, please remove sex mark from this date and try again!")
                
                self.present(alert, animated: true, completion: nil)
                
            }else{
            
            if(self.markedMenstruationDates.contains(dateFormatter.string(from: uiCalendar.selectedDate))){
                if let itemToRemoveIndex = self.markedMenstruationDates.index(of: dateFormatter.string(from: uiCalendar.selectedDate)){
                    self.markedMenstruationDates.remove(at: itemToRemoveIndex)
                    
                    self.deleteBoomerang(type: "mens", date: dateFormatter.string(from: uiCalendar.selectedDate))
                }
            }else{
                self.markedMenstruationDates.append(dateFormatter.string(from: uiCalendar.selectedDate))
                
                self.postBoomerang(type: "mens", date: dateFormatter.string(from: uiCalendar.selectedDate))
            }
            
            uiCalendar.reloadData()
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func updateTimer(){
        
        if(currentUser.appCredentials != nil){
            
            let postEndPoint: String = "https://test.avawomen.com/user/results"
            let url = URL(string: postEndPoint)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.setValue(currentUser.appCredentials, forHTTPHeaderField: "X-Auth-Token")
            
            let session = URLSession.shared
            session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    
                do{
                    
                    if let _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                        let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        var message = ""
                        
                        for (key,value) in jsonResult{
                            
                            if(key as! String == "heartRate"){
                                
                                DispatchQueue.main.async { [unowned self] in
                                    
                                    self.uiHearthRateLabel.text = String(describing: value)
                                    
                                }
                                
                            }
                            
                            if(key as! String == "cycleNumber"){
                                
                                DispatchQueue.main.async { [unowned self] in
                                    
                                    self.uiCycleNumberLabel.text = String(describing: value)
                                    
                                }
                                
                            }
                            
                            if(key as! String == "errorMessage"){
                                
                                message = value as! String
                                
                                let alert = Alerts.serverResponseError(message: message)
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                    }else{
                        DispatchQueue.main.async { [unowned self] in
                            
                            let alert = Alerts.unableToParseResponseAlert()
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    }
                }catch{
                    
                    DispatchQueue.main.async { [unowned self] in
                        
                        let alert = Alerts.unableToCatchResponseAlert()
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }).resume()
            
        }
        
    }

    
    func postBoomerang(type: String, date: String){
    
        self.showOverlay()
        
        let postEndpoint: String = "https://test.avawomen.com/user/boomerang"
        let url = URL(string: postEndpoint)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(currentUser.appCredentials, forHTTPHeaderField: "X-Auth-Token")
        
        let postParamaters: [String : String] = [type : "1", "date" : date]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: postParamaters, options: JSONSerialization.WritingOptions())
        } catch {
            DispatchQueue.main.async { [unowned self] in
                
                let alert = Alerts.unableToSendRequestAlert()
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        session.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard let status200 = response as? HTTPURLResponse,
                status200.statusCode >= 200 && status200.statusCode < 300
                else{
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        var message = ""
                        
                        for (key,value) in json!{
                            if(key as! String == "errorMessage"){
                                message = value as! String
                                
                                let alert = Alerts.serverResponseError(message: message)
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                        }
                        
                    } catch {
                        
                        DispatchQueue.main.async { [unowned self] in
                            
                            let alert = Alerts.unableToParseResponseAlert()
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                    return
                    
            }
            
            
            if let _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                
                DispatchQueue.main.async { [unowned self] in
                    
                    self.uiResponseLabel.text = "Server response 200 (\(type) 1)"
                    
                    self.hideOverlay()
                    
                }
                
            }
            
            self.postInDatabase(type: type)

        }).resume()
    }

    
    func deleteBoomerang(type: String, date: String){
        
        self.showOverlay()
        
        let postEndpoint: String = "https://test.avawomen.com/user/boomerang"
        let url = URL(string: postEndpoint)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(currentUser.appCredentials, forHTTPHeaderField: "X-Auth-Token")
        
        let postParamaters: [String : String] = [type : "0", "date" : date]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: postParamaters, options: JSONSerialization.WritingOptions())
        } catch {
            DispatchQueue.main.async { [unowned self] in
                
                let alert = Alerts.unableToSendRequestAlert()
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        session.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard let status200 = response as? HTTPURLResponse,
                status200.statusCode >= 200 && status200.statusCode < 300
                else{
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        var message = ""
                        
                        for (key,value) in json!{
                            if(key as! String == "errorMessage"){
                                
                                message = value as! String
                                
                                let alert = Alerts.serverResponseError(message: message)
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                        }
                        
                    } catch {
                        
                        DispatchQueue.main.async { [unowned self] in
                            
                            let alert = Alerts.unableToParseResponseAlert()
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                    return
                    
            }
            
            
            if let _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                
                DispatchQueue.main.async { [unowned self] in
                    
                    self.uiResponseLabel.text = "Server response 200 (\(type) 0)"
                    
                    self.hideOverlay()
                    
                }
                
            }
            
            self.deleteFromDatabase(date: date)
            
            
        }).resume()
    }
    
    func postInDatabase(type: String){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentDates")
        
        request.returnsObjectsAsFaults = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        do{
            
            let results = try context.fetch(request)
            
            if(results.count > 0){
                
                for result in results as! [NSManagedObject]{
                    
                    if(result.value(forKey: "date") as! String == dateFormatter.string(from: self.uiCalendar.selectedDate)){
                        context.delete(result)
                    }
                }
                
                let newDate = NSEntityDescription.insertNewObject(forEntityName: "CurrentDates", into: context)
                
                newDate.setValue(dateFormatter.string(from: self.uiCalendar.selectedDate), forKey: "date")
                if(type == "sex"){
                    newDate.setValue(1, forKey: "sex")
                    newDate.setValue(0, forKey: "menstruation")
                }else{
                    newDate.setValue(0, forKey: "sex")
                    newDate.setValue(1, forKey: "menstruation")
                }
                
                do{
                    
                    try context.save()
                    
                }catch{
                    
                    let alert = Alerts.unableToSaveData(from: "date")
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }else{
                
                let newDate = NSEntityDescription.insertNewObject(forEntityName: "CurrentDates", into: context)
                
                newDate.setValue(dateFormatter.string(from: self.uiCalendar.selectedDate), forKey: "date")
                if(type == "sex"){
                    newDate.setValue(1, forKey: "sex")
                    newDate.setValue(0, forKey: "menstruation")
                }else{
                    newDate.setValue(0, forKey: "sex")
                    newDate.setValue(1, forKey: "menstruation")
                }
                
                do{
                    
                    try context.save()
                    
                }catch{
                    
                    let alert = Alerts.unableToSaveData(from: "date")
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        }catch{
            
            let alert = Alerts.unableToFetchResultsAlert(from: "dates")
            
            self.present(alert, animated: true, completion: nil)
            
        }

    }

    func deleteFromDatabase(date: String){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentDates")
        
        request.returnsObjectsAsFaults = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        do{
            
            let results = try context.fetch(request)
            
            if(results.count > 0){
                
                for result in results as! [NSManagedObject]{
                    
                    if(dateFormatter.string(from: result.value(forKey: "date") as! Date) == date){
                        context.delete(result)
                    }
                }
                
                do{
                    
                    try context.save()
                    
                }catch{
                    
                    let alert = Alerts.unableToSaveDeletedData(from: "date")
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        }catch{
            
            let alert = Alerts.unableToFetchResultsAlert(from: "dates")
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
}

