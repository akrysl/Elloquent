//
//  DoodleViewController.swift
//  ELL App
//
//  Created by Brian Carreon on 2/24/16. Edited by Nick Ponce
//  Copyright © 2016 Bcarreon. All rights reserved.
//

import UIKit
import Parse

class DoodleGameViewController: UIViewController {
    
    //new edits
    
    @IBOutlet weak var submit: UIButton!
    
    
    // start 3/1
    var currentUser = PFUser.current()!
    // end 3/1

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var vocabLabel: UILabel!
    
    // edits from 01 / 2
    //time left
    @IBOutlet weak var timeLabel: UILabel!
    //submit button
    @IBOutlet weak var button: UIButton!
    // edits from 01 / 29
    
    var words = [String]()
    var currentWord = 0
    
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    // edits from 01 / 29
    var gameInt = 60
    var startInt = 3
    var gameTimer = Timer()
    var startTimer = Timer()
    //edits from 01 / 29
    
    // start 3/4
    var timer = Timer()
    // end 3/4
    
    // 03/08
    var nextSceneTimer = Timer()
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 45.0 / 255.0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("first word in list: ", words[0])
        // Do any additional setup after loading the view, typically from a nib.
        
        // GRABB's pop-up is not supported by the Ellokids - NAP
//        let _ = SCLAlertView().showInfo("Word Doodle", subTitle: "Illustrate the meaning of the word. Click next to draw the next word!")
//
        // start 3/2
        // draw transparent rectangle for drawing area
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 834, height: 1112))
        let rect = renderer.image { ctx in
            let rectangle = CGRect(x: 50, y: 250, width: 735, height: 660)
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        mainImageView.image = rect
        // end 3/2
        
        // edits from 01 / 29
        gameInt = 60
        timeLabel.text = String(gameInt)
        startInt = 3
        button.setTitle(String(startInt), for: .normal)
        button.isEnabled = false
        submit.isEnabled = true
        
        // start 3/4
        timer = Timer.scheduledTimer(timeInterval: 64.0, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
        // end 3/4

        startTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DoodleGameViewController.startGame), userInfo: nil, repeats: true)
        // edits from 01 / 29
        if (words.count > 0) {
            currentWord = Int(arc4random_uniform(UInt32(words.count)))
            vocabLabel.text = words[currentWord]
            print("number of words: ", words.count)
            print("word 1: " , words[0])
            print("word 2: ", words[1])
            print("vocab word ", vocabLabel.text!)
        }
        
        // 3/08,
        currentUser["VocabWord"] = vocabLabel.text
        currentUser["Score"] = 0
        currentUser["doneGuessing"] = false
        currentUser["doneDrawing"] = false
        Database().updateToDatabase(object: currentUser).then{result in
            print("result",result)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    // The next 4 functions are not yet supported by the Ellokids - NAP
//    @IBAction func reset(_ sender: AnyObject) {
//        mainImageView.image = nil
//    }
//
//    @IBAction func resetImage(_ sender: AnyObject) {
//        mainImageView.image = nil
//    }
//
//    @IBAction func nextWord(_ sender: AnyObject) {
//        if words.count - 1 == currentWord {
//            currentWord = 0
//        }
//        else {
//            currentWord += 1
//        }
//
//        if (words.count > 0) {
//            vocabLabel.text = words[currentWord]
//        }
//    }
//
//    @IBAction func share(_ sender: AnyObject) {
//        UIGraphicsBeginImageContext(mainImageView.bounds.size)
//        mainImageView.image?.draw(in: CGRect(x: 0, y: 0,
//                                             width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        let activity = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
//        present(activity, animated: true, completion: nil)
//    }
    
    // Pencil
    @IBAction func colorChosen(_ sender: UIButton) {
        var index = sender.tag
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        (red, green, blue) = colors[index]
        
        if index == colors.count - 1 {
            opacity = 1.0
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        // 3
        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(brushWidth)
        context!.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context!.setBlendMode(CGBlendMode.normal)
        
        // 4
        context!.strokePath()
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 6
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     let settingsViewController = segue.destinationViewController as! SettingsViewController
     settingsViewController.delegate = self
     settingsViewController.brush = brushWidth
     settingsViewController.opacity = opacity
     settingsViewController.red = red
     settingsViewController.green = green
     settingsViewController.blue = blue
     }
     
     }
     
     extension ViewController: SettingsViewControllerDelegate {
     func settingsViewControllerFinished(settingsViewController: SettingsViewController) {
     self.brushWidth = settingsViewController.brush
     self.opacity = settingsViewController.opacity
     self.red = settingsViewController.red
     self.green = settingsViewController.green
     self.blue = settingsViewController.blue
     }
     }*/
    
    //edits from 01 / 29
    @objc func startGame()
    {
        startInt -= 1
        button.setTitle(String(startInt), for: .normal)
        
        if startInt == 0
        {
            startTimer.invalidate()
            button.setTitle("GO go go, DRAW before time runs out!!", for: .normal)
            button.isEnabled = false
            submit.isEnabled = true
            //insert submit button code
            
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DoodleGameViewController.game), userInfo: nil, repeats: true)
        }
    }
    
    @objc func game()
    {
        gameInt -= 1
        timeLabel.text = String(gameInt)
        
        if gameInt == 0
        {
            gameTimer.invalidate()
            button.isEnabled = false
        }
    }
    
    @objc func timeToMoveOn() {
        takeshot(self)
        postTimerUpdates()
        self.performSegue(withIdentifier: "PostSubmitScreen", sender: self)
    }
    // edits from 01/ 29
    
    // start 3/2
    // take screenshot of drawing
    func takeshot(_ sender: Any) {
        var image :UIImage?
        let currentLayer = UIApplication.shared.keyWindow!.layer
        let currentScale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(currentLayer.frame.size, false, currentScale);
        guard let currentContext = UIGraphicsGetCurrentContext() else {return}
        currentLayer.render(in: currentContext)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let img = image else { return }
        
        let cropped : UIImage = cropImage(image: img)
        
//        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
//        UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil)
        
        // update drawing and vocab word in user's pictionary player
        let dataImage = UIImagePNGRepresentation(cropped)
        if let drawingImageFile = PFFile(name: "drawing.png", data: dataImage!)
        {
            print("update Drawing and doneDrawing")
            currentUser["Drawing"] = drawingImageFile
            currentUser["doneDrawing"] = true
            Database().updateToDatabase(object: currentUser).then{result in
                print("result update to database drawing stuff",result)
                
            }
        }
    }
    
    func cropImage(image: UIImage) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat = 93.0
        let posY: CGFloat = 500.0
        
        let cgwidth: CGFloat = CGFloat(contextSize.width - 2*posX)
        let cgheight: CGFloat = CGFloat(contextSize.height - 900)
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
//    @IBAction func submitButton(_ sender: Any) {
//        timer.invalidate()
//        print("click submit")
//        takeshot(self)
//        print("after takeshot")
//        print("update database")
//        Database().updateToDatabase(object: currentUser).then{result in
//            print("result update to database doodle game",result) }
//        self.performSegue(withIdentifier: "PostSubmitScreen", sender: self)
//    }
    
    // Will be called after Timer hits 0 seconds
    @objc func postTimerUpdates()
    {
        timer.invalidate()
        print("click submit")
        print("after takeshot")
        print("update database")
        Database().updateToDatabase(object: currentUser).then{result in
            print("result update to database doodle game",result) }
        self.performSegue(withIdentifier: "PostSubmitScreen", sender: self)
    }
    
    @IBAction func SubmitDrawing(_ sender: Any) {
        timeToMoveOn()
    }
    // end 3/2
}

