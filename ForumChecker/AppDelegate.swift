//
//  AppDelegate.swift
//  ForumChecker
//
//  Created by Anders Hovmöller on 2019-03-08.
//  Copyright © 2019 Anders Hovmöller. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var statusBarItem : NSStatusItem?
    let read = NSImage.init(named: "read.png")
    let unread = NSImage.init(named: "unread.png")
    let menu = NSMenu.init()
    
    @objc
    func showPreferences(sender: Any?) {
        self.window!.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        menu.addItem(NSMenuItem.init(title: "Preferences", action: #selector(showPreferences), keyEquivalent: ""))
        
        statusBarItem!.menu = menu
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
            timer in
            
            let defaults = UserDefaults.standard
            let username : String = defaults.string(forKey: "username") ?? ""
            let password : String = (defaults.string(forKey: "password") ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            let session = URLSession.shared
            
            // Lots of trial and error to get to this point. URLComponents didn't work...
            let u = "https://forum.killingar.net/api/0/unread_simple/?username=\(username.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)&password=\(password.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)".replacingOccurrences(of: "%25", with: "%")
            let url = URL(string: u)!

            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                guard error == nil else { return }

                if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
                        if httpResponse.statusCode == 403 {
                            self.statusBarItem?.button!.image = nil
                            self.statusBarItem?.button!.title = "⚠️"
                            return
                        }
                        
                        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
                            self.statusBarItem?.button!.image = nil
                            self.statusBarItem?.button!.title = "💥"
                            return
                        }
                        
                        let image = httpResponse.statusCode == 204 ? self.read : self.unread
                        image!.isTemplate = true
                        self.statusBarItem?.button!.image = image;
                        self.statusBarItem?.button!.imageScaling = .scaleProportionallyDown
                    }
                }
            })
            task.resume()

        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

