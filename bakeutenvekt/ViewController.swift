//
//  ViewController.swift
//  bakeutenvekt
//
//  Created by Robert Petersson on 11/06/2020.
//  Copyright © 2020 Robert Petersson. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    
     // Function to calculate and update
    
    func regneUt() {
        //Gets name of selected product
        let selectedProduct = products[pickerView.selectedRow(inComponent: 0)].name
        
        //Gets gram from slider
        let selectedGram = uiSlider.value
            
        //Gets index of selected product in array "products"
        let index = products.firstIndex(where: {$0.name == selectedProduct})!
        
        //Get gram from seleced product...
        let gramOfSelectedProduct = products[index].1
        
        //Caculate DL and replace text
        let result = Double(selectedGram) / Double(gramOfSelectedProduct)
        
        //Replaces text of labelResult
        labelResult.text = String(format: " %.2f dl",result)
    }
    
    var products : [(name:String, gram:Int)] = [("Hvetemel", 60),("Grovt mel", 55),("Havregryn", 40), ("Maizena", 50),("Potetmel",70),("Salt",23),("Sukker",90),("Melis",60),("Sirup",120),("Rosiner",60),("Margarin",90),("Olje",90),("Smulegryn",70),("Ris, langkornet",80),("Ris rundkornet",90),("Erter, Bønner, Linser",80),("Kakao",40),("Kokosmasse",40),("Syltetøy",125),("Hvit-ost revet",40)]
    
    @IBOutlet weak var uiSlider: UISlider!
    @IBOutlet weak var labelResult: UILabel!

    @IBOutlet weak var uiLabelGram: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func uiSliderValueChanged(_ sender: UISlider) {
        
        uiLabelGram.text = String(format:"%.0f",uiSlider.value) + " g"
        
        regneUt()
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        
        //Sets label based on slider at init.
        
        uiLabelGram.text = String(format:"%.0f",uiSlider.value) + " g"
        labelResult.text = String(uiSlider.value)
        
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return products.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return products[row].name
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
    inComponent component: Int) {
        
        regneUt()
    }

}

