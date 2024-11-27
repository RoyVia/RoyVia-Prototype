import SwiftUI
import AVFoundation
import AudioToolbox

struct BarcodeScannerView: UIViewControllerRepresentable {
    var onCodeScanned: (String, AVMetadataObject.ObjectType) -> Void
    @Binding var isScanning: Bool
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView
        var captureSession: AVCaptureSession?
        
        init(parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first,
                  let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            DispatchQueue.main.async {
                self.parent.onCodeScanned(stringValue, readableObject.type)
            }
        }

    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
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
            
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8, .code128]
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = viewController.view.bounds
            viewController.view.layer.addSublayer(previewLayer)
            
            // Add the overlay with the close button
            setupOverlay(on: viewController.view, controller: viewController)
        } catch {
            print("Error configuring capture session: \(error)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if self.isScanning {
                captureSession.startRunning()
            }
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let session = context.coordinator.captureSession else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if self.isScanning {
                if !session.isRunning {
                    session.startRunning()
                }
            } else {
                if session.isRunning {
                    session.stopRunning()
                }
            }
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        DispatchQueue.global(qos: .background).async {
            coordinator.captureSession?.stopRunning()
            coordinator.captureSession = nil
        }
    }
    
    private func setupOverlay(on parentView: UIView, controller: UIViewController) {
        // Create a semi-transparent overlay view
        let overlayView = UIView(frame: parentView.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isUserInteractionEnabled = true // Enable interaction for the close button
        
        // Define dimensions for button and label area
        let buttonHeight: CGFloat = 100 // Height of the button + padding
        let labelHeight: CGFloat = 50  // Height of the instruction label + padding
        let reservedHeight = buttonHeight + labelHeight // Total reserved height for button and label
        
        // Calculate the remaining height for the viewfinder and its position
        let remainingHeight = parentView.bounds.height - reservedHeight
        let viewfinderWidth: CGFloat = parentView.bounds.width * 0.7
        let viewfinderHeight: CGFloat = remainingHeight * 0.7
        let viewfinderTop: CGFloat = labelHeight + 50// Start below the reserved label area
        
        // Define the viewfinder rectangle
        let viewfinderRect = CGRect(
            x: parentView.bounds.midX - viewfinderWidth / 2,
            y: viewfinderTop,
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
        instructionLabel.text = "Align the barcode or QR code\nwithin the frame to scan."
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.lineBreakMode = .byWordWrapping
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(instructionLabel)
        
        // Add a close button
        let closeButton = UIButton(type: .system)
        let closeImage = UIImage(
            systemName: "xmark.circle",
            withConfiguration: UIImage
                .SymbolConfiguration(pointSize: 30, weight: .regular)
        )
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addAction(UIAction { _ in
            controller.dismiss(animated: true)
        }, for: .touchUpInside)
        overlayView.addSubview(closeButton)
        
        parentView.addSubview(overlayView)
        
        // Set up Auto Layout for the instruction label
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: viewfinderRect.maxY + 20)
        ])
        
        // Set up Auto Layout for the close button
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 16)
        ])
    }
}
