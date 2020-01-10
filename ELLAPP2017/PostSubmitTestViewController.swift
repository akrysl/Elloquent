//
//  PostSubmitTestViewController.swift
//  ELLAPP2017
//
//  Created by Andy Tran Nguyen on 2/11/19.
//  Copyright © 2019 Ellokids. All rights reserved.
//

import UIKit
import Parse

class PostSubmitTestViewController: UIViewController {
    
    
    var waitInt = 10
    var waitTimer = Timer()
    

    
    var currentUser = PFUser.current()!
//    var players = [String]()
//    var done = 0;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        waitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PostSubmitTestViewController.waitCount), userInfo: nil, repeats: true)
        
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
        
        print("post submit test view controller screen")
        timeToMoveOn()

//        waitForPlayers()
//        beforeUpdateTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(PostSubmitTestViewController.waitForPlayers), userInfo: nil, repeats: true)
        
    }
    
//    @objc func waitForPlayers() {
//        print("start waiting for players")
//
//        // wait for players to finish drawing
//        done = 0
//        players = currentUser["PictionaryGame"] as! [String]
//        checkPlayers()
//        while (done != 3) {
//            print("call doLoop")
//            doLoop()
//        }
//        self.performSegue(withIdentifier: "guessDrawing", sender: self)
//}
//    func checkPlayers() {
//        var ID = players[0]
//
//        print("done", self.done, "current id", ID)
//        let query = PFUser.query()!
//        query.whereKey("objectId", equalTo: ID)
//        query.getFirstObjectInBackground { newUser, error in
//            if error == nil {
//                print("username", newUser!["username"] as! String)
//                if ((newUser!["doneDrawing"] as! Bool) == true) {
//                    self.done = self.done + 1
//                    print("done", self.done, newUser!["username"] as! String, "IS done drawing")
//                }
//                else {
//                    print(newUser!["username"] as! String, "NOT done drawing")
//                }
//            }
//            else {
//                print(error?.localizedDescription)
//            }
//        }
    
//        for ID in players {
//            print("done", self.done, "current id", ID)
//            let query = PFUser.query()!
//            query.whereKey("objectId", equalTo: ID)
//            query.getFirstObjectInBackground { newUser, error in
//                if error == nil {
//                    print(newUser!["username"] as! String)
//                    if ((newUser!["doneDrawing"] as! Bool) == true) {
//                        self.done = self.done + 1
//                        print(newUser!["username"] as! String, " IS done drawing")
//                    }
//                    else {
//                        print(newUser!["username"] as! String, " NOT done drawing")
//                    }
//                }
//                else {
//                    print(error?.localizedDescription)
//                }
//            }
//        }
//    }

    @objc func waitCount()
    {
        waitInt -= 1
        if (waitInt == 0)
        {
            waitTimer.invalidate()
        }
    }
    
    // Makes players wait an alloted amount of time after submitting their drawings before
    // segueing into a new scene
    
    @objc func timeToMoveOn() {
        self.performSegue(withIdentifier: "guessDrawing", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
