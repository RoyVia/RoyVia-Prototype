import SwiftUI
import AVFoundation

struct IngredientScannerView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ProductIngredientScanViewModel
    
    func makeUIViewController(context: Context) -> IngredientScannerViewController {
        let cameraViewController = IngredientScannerViewController()
        cameraViewController.onPhotoCaptured = { image in
            viewModel.capturedImage = image
        }
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: IngredientScannerViewController, context: Context) {}
}

class IngredientScannerViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    private let captureButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()
        setupCaptureButton()
        setupCloseButton() // Add close button
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        photoOutput = AVCapturePhotoOutput()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              let captureSession = captureSession,
              captureSession.canAddInput(videoInput),
              captureSession.canAddOutput(photoOutput!) else {
            print("Camera setup failed")
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.addInput(videoInput)
        captureSession.addOutput(photoOutput!)
        
        // Configure maxPhotoDimensions based on supported dimensions
        if #available(iOS 16.0, *) {
            let activeFormat = videoCaptureDevice.activeFormat
            
            if let firstDimension = activeFormat.supportedMaxPhotoDimensions.first {
                photoOutput?.maxPhotoDimensions = firstDimension
            }
        }
        
        captureSession.commitConfiguration()
        
        // Configure preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        view.layer.addSublayer(previewLayer!)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    private func setupOverlay() {
        // Create a semi-transparent overlay view
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isUserInteractionEnabled = false
        
        // Define dimensions for button and label area
        let buttonHeight: CGFloat = 100
        let labelHeight: CGFloat = 50
        let reservedHeight = buttonHeight + labelHeight
        
        // Calculate the remaining height for the viewfinder and its position
        let remainingHeight = view.bounds.height - reservedHeight
        let viewfinderWidth: CGFloat = view.bounds.width * 0.7
        let viewfinderHeight: CGFloat = remainingHeight * 0.7
        let viewfinderTop: CGFloat = labelHeight + 50
        
        // Define the viewfinder rectangle
        let viewfinderRect = CGRect(
            x: view.bounds.midX - viewfinderWidth / 2,
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
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Please capture the entire\ningredient label area."
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.lineBreakMode = .byWordWrapping
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(instructionLabel)
        
        view.addSubview(overlayView)
        
        // Set up Auto Layout for the instruction label
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: viewfinderRect.maxY + 20)
        ])
    }
    
    private func setupCaptureButton() {
        let cameraSymbolConfig = UIImage.SymbolConfiguration(
            pointSize: 60,
            weight: .regular,
            scale: .large
        )
        let cameraImage = UIImage(systemName: "camera.circle", withConfiguration: cameraSymbolConfig)
        
        captureButton.setImage(cameraImage, for: .normal)
        captureButton.tintColor = .white
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        let closeImage = UIImage(
            systemName: "xmark.circle",
            withConfiguration: UIImage
                .SymbolConfiguration(pointSize: 30, weight: .regular)
        )
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeScanner), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])
    }
    
    @objc private func closeScanner() {
        dismiss(animated: true)
    }
    
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Failed to process photo data")
            return
        }
        
        onPhotoCaptured?(image)
        
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}
