
import SwiftUI
import AVFoundation
import AudioToolbox

struct BarcodeScannerView: UIViewControllerRepresentable {
    var onCodeScanned: (String, AVMetadataObject.ObjectType) -> Void
    @Binding var isScanning: Bool // Bind to control session start/stop
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView
        var captureSession: AVCaptureSession?
        
        init(parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first,
                  let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            let barcodeType = readableObject.type
            
            // Trigger vibration upon successful capture
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            // Stop scanning temporarily
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.stopRunning()
                print("- Barcode scaning shutting down after scan")
            }
            
            // Return the scanned code and its type
            DispatchQueue.main.async {
                self.parent.onCodeScanned(stringValue, barcodeType)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(parent: self)
        return coordinator
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        context.coordinator.captureSession = captureSession
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return viewController
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            // Enable auto-focus and continuous focus
            try videoCaptureDevice.lockForConfiguration()
            if videoCaptureDevice.isFocusModeSupported(.continuousAutoFocus) {
                videoCaptureDevice.focusMode = .continuousAutoFocus
            } else if videoCaptureDevice.isFocusModeSupported(.autoFocus) {
                videoCaptureDevice.focusMode = .autoFocus
            }
            
            if videoCaptureDevice.isSmoothAutoFocusSupported {
                videoCaptureDevice.isSmoothAutoFocusEnabled = true
            }
            
            videoCaptureDevice.unlockForConfiguration()
        } catch {
            print("Error configuring video device: \(error)")
            return viewController
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8, .code128]
        }
        
        // Set up preview layer limited to half the screen
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        let screenBounds = UIScreen.main.bounds
        let halfScreenFrame = CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height / 2)
        previewLayer.frame = halfScreenFrame
        viewController.view.layer.addSublayer(previewLayer)
        
        // Add the overlay to match the half-screen feed
        addOverlay(to: viewController.view, cameraFrame: halfScreenFrame)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if self.isScanning {
                captureSession.startRunning()
                print("- Barcode scaning turning on while prepiing ViewController")
            }
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let session = context.coordinator.captureSession else { return }
        
        if isScanning {
            DispatchQueue.global(qos: .userInitiated).async {
                if !session.isRunning {
                    session.startRunning()
                    print("- Barcode scaning turning on")
                }
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                if session.isRunning {
                    session.stopRunning()
                    print("- Barcode scaning shutting down")
                }
            }
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        coordinator.captureSession?.stopRunning()
        coordinator.captureSession = nil
    }
    
    private func addOverlay(to parentView: UIView, cameraFrame: CGRect) {
        let overlayView = UIView(frame: cameraFrame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isUserInteractionEnabled = false
        
        // Define the viewfinder size and position within the half-screen camera feed
        let viewfinderWidth = cameraFrame.width * 0.7
        let viewfinderHeight = cameraFrame.height * 0.7
        let viewfinderRect = CGRect(
            x: cameraFrame.midX - viewfinderWidth / 2,
            y: cameraFrame.midY - viewfinderHeight / 2,
            width: viewfinderWidth,
            height: viewfinderHeight
        )
        
        // Create the cutout path for the viewfinder
        let cutoutPath = UIBezierPath(rect: overlayView.bounds)
        let viewfinderPath = UIBezierPath(roundedRect: viewfinderRect, cornerRadius: 10)
        cutoutPath.append(viewfinderPath)
        cutoutPath.usesEvenOddFillRule = true
        
        // Apply the cutout path as a mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = cutoutPath.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        // Add a border around the viewfinder
        let borderLayer = CAShapeLayer()
        borderLayer.path = viewfinderPath.cgPath
        borderLayer.lineWidth = 2
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        overlayView.layer.addSublayer(borderLayer)
        
        // Add an instruction label
        let instructionLabel = UILabel()
        instructionLabel.text = "Align the barcode or QR code\nnear the frame to scan"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(instructionLabel)
        
        // Add the overlay view to the parent view
        parentView.addSubview(overlayView)
        
        // Set up Auto Layout for the instruction label
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: viewfinderRect.maxY + 20)
        ])
    }
}
