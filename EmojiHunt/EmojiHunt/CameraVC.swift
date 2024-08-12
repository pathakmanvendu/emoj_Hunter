//
//  CameraVC.swift
//  EmojiHunterGame
//
//  Created by manvendu pathak  on 07/08/24.
//

import AVFoundation
import UIKit
import CoreML
import Vision

class CameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    var delegate: EmojiFoundDelegate?
    //Variables
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    var emojiString = ""
    
    convenience init(emoji: String){
        self.init()
        self.emojiString = emoji
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do{
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch{
            return
        }
        
        if (captureSession.canAddInput(videoInput)){
            captureSession.addInput(videoInput)
        }
        
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        
        if captureSession?.isRunning == false{
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if captureSession?.isRunning == true {
                captureSession.stopRunning()
            }
        }

    override var prefersStatusBarHidden: Bool {
            return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
            do {
                let model = try VNCoreMLModel(for: MobileNetV2().model)
                let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                    self?.processClassifications(for: request, error: error)
                })
                request.imageCropAndScaleOption = .centerCrop
                return request
            } catch {
                fatalError("Failed to load Vision ML model: \(error)")
            }
        }()
        
    func captureOutput(
            _ output: AVCaptureOutput,
            didOutput sampleBuffer: CMSampleBuffer,
            from connection: AVCaptureConnection) {
            
            guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                debugPrint("unable to get image from sample buffer")
                return
            }
            
            self.updateClassifications(in: frame)
        }
        

    func updateClassifications(in image: CVPixelBuffer) {

            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .right, options: [:])
                do {
                    try handler.perform([self.classificationRequest])
                } catch {
                    print("Failed to perform classification.\n\(error.localizedDescription)")
                }
            }
        }
        
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                return
            }
            let classifications = results as! [VNClassificationObservation]

            if !classifications.isEmpty {
                if classifications.first!.confidence > 0.5{
                    let identifier = classifications.first?.identifier ?? ""

                    if identifier.contains(self.emojiString){
                        self.delegate?.emojiWasFound(result: true)
                    }
                }
            }
        }
    }
}

protocol EmojiFoundDelegate {
    func emojiWasFound(result: Bool)
}
