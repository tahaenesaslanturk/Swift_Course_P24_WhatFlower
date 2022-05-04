//
//  ViewController.swift
//  WhatFlower
//
//  Created by Taha Enes Aslantürk on 4.05.2022.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    let imagePicker = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Cannot convert ciImage")
            }
            
            detect(image: ciImage)
            imageView.image = userPickedImage
        }
        
        
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image: CIImage) {
    
        guard let model = try? VNCoreMLModel(for: FlowerShop().model) else {
            fatalError("Loading coreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let classification = request.results as? [VNClassificationObservation] else {
            fatalError("Model failed to process image.")
            }
            
            self.navigationItem.title = classification[0].identifier
            self.requestInfo(flowerName: classification[0].identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
      
    }
    
    func requestInfo(flowerName: String) {
        let parameters : [String:String] = [
         "format" : "json",
         "action" : "query",
         "prop" : "extracts",
         "exintro" : "",
         "explaintext" : "",
         "titles" : flowerName,
         "indexpageids" : "",
         "redirects" : "1",
         "pithumbsize": "500"
         ]

        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Got the wikipedia info.")
                print(response)
                
                
                let flowerJSON: JSON = JSON(response.result.value!)
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
//                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
//
//
//                self.imageView.sd_setImage(with: URL(string: flowerImageURL))
                self.label.text = flowerDescription
                
            }
        }
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

