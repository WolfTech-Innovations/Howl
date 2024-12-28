import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    var model: VNCoreMLModel?
    var messages: [String] = []
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var messageList: UITextView!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        statusLabel.text = "Downloading model..."
        inputField.addTarget(self, action: #selector(handleSend), for: .editingDidEndOnExit)
        
        downloadModel()
    }

    func setupUI() {
        // Style input field
        inputField.layer.cornerRadius = 10
        inputField.layer.borderWidth = 1
        inputField.layer.borderColor = UIColor.lightGray.cgColor
        inputField.setLeftPaddingPoints(10)

        // Style message list
        messageList.layer.cornerRadius = 10
        messageList.layer.borderWidth = 1
        messageList.layer.borderColor = UIColor.lightGray.cgColor

        // Style buttons
        sendButton.layer.cornerRadius = 10
        sendButton.layer.shadowColor = UIColor.black.cgColor
        sendButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        sendButton.layer.shadowOpacity = 0.5
        sendButton.layer.shadowRadius = 4

        clearButton.layer.cornerRadius = 10
        clearButton.layer.shadowColor = UIColor.black.cgColor
        clearButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        clearButton.layer.shadowOpacity = 0.5
        clearButton.layer.shadowRadius = 4
    }

    func downloadModel() {
        let urlString = "https://huggingface.co/andmev/Llama-3.2-3B-Instruct-CoreML/resolve/main/Llama-3.2-3B-Instruct.mlpackage/Data/com.apple.CoreML/model.mlmodel"
        
        guard let url = URL(string: urlString) else {
            setStatus("Invalid model URL.")
            return
        }
        
        activityIndicator.startAnimating()

        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }

            if let error = error {
                self.setStatus("Download failed: \(error.localizedDescription)")
                return
            }
            
            guard let location = location else {
                self.setStatus("Failed to download model.")
                return
            }
            
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsURL.appendingPathComponent("model.mlmodel")
            
            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                try fileManager.moveItem(at: location, to: destinationURL)
                self.loadModel(at: destinationURL)
            } catch {
                self.setStatus("Error moving model file: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    func loadModel(at url: URL) {
        do {
            let compiledModelURL = try MLModel.compileModel(at: url)
            let coreMLModel = try MLModel(contentsOf: compiledModelURL)
            model = try VNCoreMLModel(for: coreMLModel)
            setStatus("Model Ready!")
            addMessage("Model is ready. Type something to start chatting!", type: .system)
        } catch {
            setStatus("Failed to load model: \(error.localizedDescription)")
        }
    }

    func setStatus(_ status: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = status
        }
    }

    func addMessage(_ message: String, type: MessageType = .user) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        let formattedMessage = "\(timestamp) - \(message)"
        
        DispatchQueue.main.async {
            self.messages.append(formattedMessage)
            self.messageList.text = self.messages.joined(separator: "\n")
        }
    }

    @objc func handleSend() {
        guard let input = inputField.text, !input.isEmpty else { return }
        inputField.text = ""

        addMessage("You: \(input)")

        DispatchQueue.global().async {
            let response = self.generateResponse(input)
            self.addMessage("Howl: \(response)", type: .system)
        }
    }

    func generateResponse(_ input: String) -> String {
        guard let model = self.model else {
            return "Model not loaded yet."
        }

        let prompt = "User: \(input)\nAssistant:"
        guard let inputData = prompt.data(using: .utf8) else {
            return "Error processing input."
        }

        do {
            let request = VNCoreMLRequest(model: model) { (request, error) in
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    return
                }

                DispatchQueue.main.async {
                    self.addMessage("Howl: \(topResult.identifier)", type: .system)
                }
            }

            let handler = VNImageRequestHandler(data: inputData, options: [:])
            try handler.perform([request])
        } catch {
            return "Error generating response: \(error.localizedDescription)"
        }

        return "Processing..."
    }

    @IBAction func clearMessages(_ sender: UIButton) {
        messages.removeAll()
        messageList.text = ""
    }

    enum MessageType {
        case user
        case system
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
