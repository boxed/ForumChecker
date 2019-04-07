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


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
            timer in

            let session = URLSession.shared
            let url = URL(string: "https://forum.killingar.net/api/0/unread_simple/?username=möller&password=q".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!

            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                guard error == nil else { return }

                if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
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

