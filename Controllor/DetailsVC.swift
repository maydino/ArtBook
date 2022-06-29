//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Mutlu Aydin on 1/2/21.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            // CoreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let idString = chosenPaintingId?.uuidString

            // Create request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            // Get the data
            do {
                let result = try context.fetch(fetchRequest)
                
                if result.count > 0 {
                    
                    for result in result as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data:  imageData)
                            imageView.image = image
                        }
                    }
                }
                
            } catch {
                
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        imageView.image = UIImage(named: "SelectImage")
        
        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        // Tap the image
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    
    // Call this function when tap the image
    @objc func selectImage () {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    // Show selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        // Show the save button
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    // Hide keyboard
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    // Save selected image
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
       
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        
        // Create ids for each entry
        newPainting.setValue(UUID(), forKey: "id")
        
        // Image compression
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        // Set value
        newPainting.setValue(data, forKey: "image")
        
        // Save
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        

        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        // Return to main ViewController
        self.navigationController?.popViewController(animated: true)
    }
    

}
