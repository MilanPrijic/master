//
//  AppDelegate.swift
//  AvaWomenTest
//
//  Created by Milan Prijic on 2/4/17.
//  Copyright © 2017 Milan Prijic. All rights reserved.
//

import UIKit
import CoreData

let Colors = ColorHelper()
let Alerts = AlertHelper()

var currentUser:CurrentUser = CurrentUser()
var currentDates:[CurrentDate] = []

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

            self.callLoginUser()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AvaWomenTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func callLoginUser(){
        
        let postEndpoint: String = "https://test.avawomen.com/user/login"
        let url = URL(string: postEndpoint)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("TestAndroid", forHTTPHeaderField: "X-Auth-Username")
        request.setValue("12345678", forHTTPHeaderField: "X-Auth-Password")
        request.setValue("00da10d4b1344cbba1e2e6669363f4ca", forHTTPHeaderField: "Push-Token")
        request.setValue("IPHONE", forHTTPHeaderField: "Phone-Type")
        
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
                            }
                        }
                        
                    } catch {
                        
                        print("Unable to get response from server while logging in!")
                    }
                    
                    return
                    
            }
            
            
            if let _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                
                do{
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    
                    for (key,value) in jsonResult!{
                        
                        if(key as! String == "token"){
                            
                            currentUser.appCredentials = value as! String
                            
                        }
                        
                        if(key as! String == "userData"){
                        
                            for (k,v) in value as! NSDictionary{
                            
                                switch k as! String{
                                
                                    case "country":
                                        currentUser.country = v as! String
                                    break
                                    case "email":
                                        currentUser.email = v as! String
                                        break
                                    case "firstName":
                                        currentUser.firstName = v as! String
                                        break
                                    case "lastName":
                                        currentUser.lastName = v as! String
                                        break
                                    case "username":
                                        currentUser.username = v as! String
                                        break
                                default:
                                    print("this should not happen!")
                                }
                                
                            }
                        
                        }
                        
                    }
                    
                }
                catch{
                        
                    print("Unable to parse reponse from server!")
                    
                }
                
            }
            
            self.tryWritingUserToDatabase()
            
            
        }).resume()
        
    }
    
    func tryWritingUserToDatabase(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentUser")
        
        request.returnsObjectsAsFaults = false
        
        do{
            
            let results = try context.fetch(request)
            
            if(results.count > 0){
                
                for result in results as! [NSManagedObject]{
                    
                    context.delete(result)
                }
                
                let newUser = NSEntityDescription.insertNewObject(forEntityName: "CurrentUser", into: context)
                
                newUser.setValue(currentUser.appCredentials, forKey: "appCredentials")
                newUser.setValue(currentUser.username, forKey: "username")
                newUser.setValue(currentUser.firstName, forKey: "firstName")
                newUser.setValue(currentUser.lastName, forKey: "lastName")
                newUser.setValue(currentUser.email, forKey: "email")
                newUser.setValue(currentUser.country, forKey: "country")
                
                do{
                    
                    try context.save()
                    
                }catch{
                    
                    print("unable to save context to databese!")
                    
                }
                
            }else{
                
                let newUser = NSEntityDescription.insertNewObject(forEntityName: "CurrentUser", into: context)
                
                newUser.setValue(currentUser.appCredentials, forKey: "appCredentials")
                newUser.setValue(currentUser.username, forKey: "username")
                newUser.setValue(currentUser.firstName, forKey: "firstName")
                newUser.setValue(currentUser.lastName, forKey: "lastName")
                newUser.setValue(currentUser.email, forKey: "email")
                newUser.setValue(currentUser.country, forKey: "country")
                
                do{
                    
                    try context.save()
                    
                }catch{
                    
                    print("unable to save context to databese!")
                    
                }
                
            }
            
        }catch{
            print("unable to fetch results for user table!")
        }
        
    }


}

extension ViewController{

    func showOverlay() {
        
        let overlayView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        overlayView.tag = 0xbadf00d
        overlayView.frame = self.view.frame
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = overlayView.center
        activityIndicator.color = UIColor.orange
        
        overlayView.addSubview(activityIndicator)
        
        view.addSubview(overlayView)
        
        activityIndicator.startAnimating()
        
        overlayView.alpha = 0.0
        overlayView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 1
        })
    }
    
    func hideOverlay() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.subviews.last?.alpha = 0.0
        }, completion: { (complete) -> Void in
            
            if self.view.subviews.last?.tag == 0xbadf00d {
                
                self.view.subviews.last?.removeFromSuperview()
                
            }
        })
        
    }

    
}

