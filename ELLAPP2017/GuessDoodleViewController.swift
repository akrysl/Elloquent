//
//  GuessDoodleViewController.swift
//  
//
//  Created by Andy Tran Nguyen on 3/1/19.
//

import UIKit
import Parse

class GuessDoodleViewController: UIViewController {
    
    
    @IBOutlet weak var displayResult: UILabel!
    @IBOutlet weak var playerInput: UITextField!
    @IBOutlet weak var userImage: PFImageView!
    
    @IBOutlet weak var correctVocab: UILabel!
    

    @IBOutlet weak var wordBank: UILabel!
    
    @IBOutlet weak var nextDrawing: UIButton!
    
    @IBOutlet weak var viewScore: UIButton!
    
    var guessInt = 45
    var guessTimer = Timer()
    
    var currentUser = PFUser.current()!
    var DrawingFile = PFFile(data: Data())
    var someData = [PFObject]()
    var players = [String]()
    var score = 0
    
    // start 3/8
    var correctAnswer = false
    // end 3/8
    
    // 03/09
    var i = 0
    var n = 0
    var word = ""
    var numGuesses = 1


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        _ = Timer.scheduledTimer(timeInterval: 45.0, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
//        guessTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GuessDoodleViewController.timerCountdown), userInfo: nil, repeats: true)
        
        // hide result until submit button is pressed
        displayResult.isHidden = true
        correctVocab.isHidden = true
        wordBank.isHidden = false
        viewScore.isHidden = true
        nextDrawing.isHidden = false
        nextDrawing.isEnabled = true
        
//        DrawingFile = currentUser["Drawing"] as? PFFile
//        DrawingFile?.getDataInBackground(block: {(imageData: Data?, error: Error?) -> Void in
//            if error == nil{
//                self.userImage.image = UIImage(data: imageData!)
//            }
//        })

        // Get the array of user's objectId's in the game
        players = currentUser["PictionaryGame"] as! [String]
        print("players: ", players) //added
        print("number of players: ", players.count)
        n = 0
        var str1 = ""
        while (n < players.count)
        {
            let ID = players[n]
            // Query for user based on ID variable
            let query = PFUser.query()!
            query.whereKey("objectId", equalTo: ID)
            query.getFirstObjectInBackground { newUser, error in
                if error == nil {
                    print("User: ", newUser!["username"] as! String)
                    // add the vocab word to the word bank
                    str1 += newUser?["VocabWord"] as! String + "    "
                    self.wordBank.text = str1
                }
            }
            self.n = self.n + 1
        }
        // 03/09
        // Check if the first user in the array is the current user
        if (currentUser.objectId == players[0]) {
            // Get the next user in the array instead
            i = 1
        }
        // Display the first drawing that isn't the current user's
        getDrawing(playersIndex: i)
        // Get the first VocabWord that isn't the current user's
        getVocab(playersIndex: i)
        // Go to next user in the array
//        i += 1
        // 03/09


    }
    
    // Gets the drawing from a user in the database
    @IBAction func getDrawing(playersIndex: Int) {
        // Get the user's objectId to query
        let ID = players[playersIndex]
        // Query for user based on ID variable
        let query = PFUser.query()!
        query.whereKey("objectId", equalTo: ID)
        query.getFirstObjectInBackground { newUser, error in
            if error == nil {
                print("User: ", newUser!["username"] as! String)
                // Save the new drawing
                self.DrawingFile = newUser?["Drawing"] as? PFFile
                self.DrawingFile?.getDataInBackground(block: {(imageData: Data?, error: Error?) -> Void in
                    if error == nil{
                        self.userImage.image = UIImage(data: imageData!)
                    }
                })
            }
        }
    }
    
    // Gets the drawing from a user in the database
//    func getDrawing(playersIndex: Int) {
//        // Get the user's objectId to query
//        let ID = players[playersIndex]
//        // Query for user based on ID variable
//        let query = PFUser.query()!
//        query.whereKey("objectId", equalTo: ID)
//        query.getFirstObjectInBackground { newUser, error in
//            if error == nil {
//                print("User: ", newUser!["username"] as! String)
//                // Save the new drawing
//                self.DrawingFile = newUser?["Drawing"] as? PFFile
//                self.DrawingFile?.getDataInBackground(block: {(imageData: Data?, error: Error?) -> Void in
//                    if error == nil{
//                        self.userImage.image = UIImage(data: imageData!)
//                    }
//                })
//            }
//        }
//    }
    
    // Gets the VocabWord from a user in the database
    func getVocab(playersIndex: Int) {
        // Get the user's objectId to query
        let ID = players[playersIndex]
        // Query for user based on ID variable
        let query = PFUser.query()!
        query.whereKey("objectId", equalTo: ID)
        query.getFirstObjectInBackground { newUser, error in
            if error == nil {
                print("User: ", newUser!["username"] as! String)
                // Save the new VocabWord
                self.word = newUser?["VocabWord"] as! String
            }
        }
    }
    
//    @objc func timerCountdown()
//    {
//        guessInt -= 1
//        timeLeft.text = "\(guessInt) seconds left"
//
//        if(guessInt == 0)
//        {
//            guessTimer.invalidate()
//        }
//
//    }
    
    @IBAction func viewPlayerScore(_ sender: Any) {
        timeToMoveOn()
    }
    
    
    @objc func timeToMoveOn() {
        self.performSegue(withIdentifier: "scoreScene", sender: self)

    }
    
    @IBAction func nextDrawing(_ sender: Any) {
        numGuesses += 1
        playerInput.text = ""
        if (i < players.count - 1){
            i += 1
        }
        if (currentUser.objectId == players[i] && i < (players.count - 1)){
            i += 1
        }
        if (currentUser.objectId != players[i]){
            getDrawing(playersIndex: i)
        }
        if (currentUser.objectId != players[i]){
            getVocab(playersIndex: i)
        }
        if (i == players.count - 1 || numGuesses == 3)
        {
            nextDrawing.isHidden = true
            nextDrawing.isEnabled = false
        }
        displayResult.isHidden = true
        correctVocab.isHidden = true
    }
    
    @IBAction func checkPlayerSubmission(_ sender: Any) {
        
        if (currentUser.objectId == players[i] && i < (players.count-1)) {
            i += 1
        }
        
        getVocab(playersIndex: i)
        print("current user's vocab word:",word)
        
        var userSubmission = playerInput.text
        var testString = word
        testString = testString.lowercased()
        userSubmission = userSubmission?.lowercased()
        correctVocab.text = ""
        if userSubmission == "\(String(describing: testString))" {
            displayResult.isHidden = false
            displayResult.text = "Correct Answer"
            score += 1
        }
        else{
            displayResult.isHidden = false
            displayResult.text = "Incorrect Answer"
            correctVocab.isHidden = false
            correctVocab.text = " The correct answer was: " + word
        }
        if(numGuesses == 3)
        {
            viewScore.isHidden = false
            viewScore.isEnabled = true
            if(score == 3)
            {
                currentUser["Score"] = "3 out of 3"
            }
            else if(score == 2)
            {
                currentUser["Score"] = "2 out of 3"
            }
            else if(score == 1)
            {
                currentUser["Score"] = "1 out of 3"
            }
            else
            {
                currentUser["Score"] = "0 out of 3"
            }
            numGuesses = 1
        }
        
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
