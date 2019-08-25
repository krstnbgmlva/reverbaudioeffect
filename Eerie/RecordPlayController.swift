//
//  ViewController.swift
//  Eerie
//
//  Created by Kristina Bogomolova on 7/18/19.
//  Copyright © 2019 Kristina Bogomolova. All rights reserved.
//

import UIKit
import AVFoundation

class RecordPlayController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var playEerieButton: UIButton!
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var reverbNode: AVAudioUnitReverb!
    var audioFile: AVAudioFile!
    var recordedAudioURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        playEerieButton.isEnabled = false

        
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = directoryPath[0]
        let soundFilePath = (documentDirectory as NSString).appendingPathComponent("eerie.caf")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue, AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String: Any] as [String: Any] as [String: Any] as [String: Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            audioRecorder = try AVAudioRecorder(url: soundFileURL as URL, settings: recordSettings as [String: AnyObject])
        } catch {
            print("\(error.localizedDescription)")
            return
        }
        
        audioRecorder?.prepareToRecord()
    }

    
    @IBAction func recordAudio(_ sender: Any) {
        recordButton.isEnabled = false
        stopRecordingButton.isEnabled = true
        playEerieButton.isEnabled = false
        audioRecorder?.record()
    }
    
    
    @IBAction func stopRecording(_ sender: Any) {
        stopRecordingButton.isEnabled = false
        playEerieButton.isEnabled = true
        recordButton.isEnabled = true
        
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        } else {
            audioPlayer?.stop()
        }
        
        recordedAudioURL = audioRecorder?.url
    }
    
    @IBAction func playEerieAudio(_ sender: Any) {
        stopRecordingButton.isEnabled = true
        recordButton.isEnabled = false
        playEerieButton.isEnabled = false
        
        playReverbSound()
    }
    
    func playReverbSound() {
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        } catch {
            print("error audiofile")
        }
        
        //Initialize audio engine components
        audioEngine = AVAudioEngine()
        //Setup node for playing audio and attach it to audioEngine
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        //Setup node for reverb effect and attach it to audioEngine
        reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        //Connect nodes to each other through audioEngine
        audioEngine.connect(audioPlayerNode, to: reverbNode, format: nil)
        audioEngine.connect(reverbNode, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print("audioengine start error")
        }
        
        audioPlayerNode.play()
    }
}

