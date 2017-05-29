/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import AVFoundation


protocol AnnotationViewDelegate {
  func didTouch(annotationView: AnnotationView)
}


class AnnotationView: ARAnnotationView {
  var titleLabel: UILabel?
  var distanceLabel: UILabel?
  var delegate: AnnotationViewDelegate?
  var imageView: UIImageView!
  var audioPlayer: AVAudioPlayer!
  weak var delegateAR : ARViewControllerProtocol?
  var distance: Double?

  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    loadUI()
  }
  
  func loadUI() {
    titleLabel?.removeFromSuperview()
    distanceLabel?.removeFromSuperview()




    //Test label stuff

//    let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
//    label.font = UIFont.systemFont(ofSize: 16)
//    label.numberOfLines = 0
//    label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
//    label.textColor = UIColor.white
//  //  self.addSubview(label)
//    self.titleLabel = label
//
//    //distanceLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20))
//    distanceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
//
//    distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
//    distanceLabel?.textColor = UIColor.green
//    distanceLabel?.font = UIFont.systemFont(ofSize: 12)
//   // self.addSubview(distanceLabel!)


    if let annotation = annotation as? Place {
      //titleLabel?.text = annotation.placeName
     // distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)

     // self.distanceLabel?.text = String(format: "%.2f m", (annotation.distanceFromUser))

      print("Updated Distance")
      print(annotation.distanceFromUser)

    }

    var image: UIImage

    image = UIImage(named: "bobDylan.png")!
    imageView = UIImageView(image: image)


    ///Dynamic Scaling Code
    //let heightForOverlay: Double = (((100 - annotation!.distanceFromUser) / 100) * Double(self.frame.height));
    //var heightFloat = heightForOverlay;
   // imageView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: CGFloat(heightForOverlay))

    imageView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    imageView.contentMode = UIViewContentMode.scaleAspectFit



    self.addSubview(imageView!)


      do
      {
        
        let path = Bundle.main.path(forResource: "audio", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer.numberOfLoops = -1
  

        if self.window != nil{
          if(audioPlayer.isPlaying){
          audioPlayer.stop()
         
        }
        else{
          audioPlayer.play()

        }

        }
        else{
          audioPlayer.pause()
        }
        
              }
      catch
      {
        print("An error occurred while trying to extract audio file")
      }


  }

  func loopVideo(videoPlayer: AVPlayer) {
    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
      videoPlayer.seek(to: kCMTimeZero)
      videoPlayer.play()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
//    titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 100)
//    distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 100)
   // imageView?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 100)

  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.didTouch(annotationView: self)
  }

  func play(for resource: String, type: String) {
    // Prevent a crash in the event that the resource or type is invalid
    guard let path = Bundle.main.path(forResource: resource, ofType: type) else { return }
    // Convert path to URL for audio player
    let sound = URL(fileURLWithPath: path)
    do {
      let audioPlayer = try AVAudioPlayer(contentsOf: sound)
      audioPlayer.prepareToPlay()
      audioPlayer.play()
    } catch {
      // Create an assertion crash in the event that the app fails to play the sound
      assert(false, error.localizedDescription)
    }
  }
}
