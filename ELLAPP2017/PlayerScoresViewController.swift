//
//  PlayerScoresViewController.swift
//  ELLAPP2017
//
//  Created by Andy Tran Nguyen on 3/1/19.
//  Copyright © 2019 Ellokids. All rights reserved.
//

import UIKit
import Parse

class PlayerScoresViewController: UIViewController {
    
    @IBOutlet weak var playerScore: UILabel!
    var currentUser = PFUser.current()!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //let score = currentUser["Score"]
    }
    
    @IBAction func playAgain(_ sender: Any) {
        timeToMoveOn()
        
    }
    
    @objc func timeToMoveOn() {
        self.performSegue(withIdentifier: "playGameAgain", sender: self)
        
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
