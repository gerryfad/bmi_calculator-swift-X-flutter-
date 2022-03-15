//
//  ViewController.swift
//  bmi
//
//  Created by yaelahbro on 15/03/22.
//

import UIKit
import Flutter
import FlutterPluginRegistrant

class ViewController: UIViewController {
    
    var bmi: BMI?
   
    
    let labelName: UILabel = {
        let label = UILabel()
        label.text = "BMI Calculator"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelHeight: UILabel = {
        let label = UILabel()
        label.text = "Height : \(Int(sliderHeight.value))"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelWeight: UILabel = {
        let label = UILabel()
        label.text = "Weight : \(Int(sliderWeight.value))"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sliderHeight: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 200
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(HeightSliderChanged(sender:)), for: .valueChanged)
        return slider
    }()
    
    @objc func HeightSliderChanged(sender: UISlider) {
        labelHeight.text = "Height : \(String(format: "%.2f CM", sliderHeight.value))"
    }
    
    let sliderWeight: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 200
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(WeightSliderChanged(sender:)), for: .valueChanged)
        return slider
    }()
    
    @objc func WeightSliderChanged(sender: UISlider) {
        labelWeight.text = "Weight : \(String(format: "%.0f Kg", sliderWeight.value))"
    }
    
    lazy var rootStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.alignment = .leading
            stackView.translatesAutoresizingMaskIntoConstraints = false
        [self.labelHeight,self.sliderHeight,self.labelWeight,self.sliderWeight] .forEach { stackView.addArrangedSubview($0) }
            return stackView
    }()
    
    let buttonNext: UIButton = {
            let buttonNext = UIButton()
            buttonNext.setTitle("Calculate", for: .normal)
            buttonNext.backgroundColor = .blue
            buttonNext.setTitleColor(.white, for: .normal)
            buttonNext.layer.cornerRadius = 5
            buttonNext.translatesAutoresizingMaskIntoConstraints = false
            buttonNext.addTarget(self, action: #selector(calculate), for: .touchUpInside)
            return buttonNext
        }()
    @objc func calculate(){
        
        let height = sliderHeight.value
        let weight = sliderWeight.value

        calculateBMI(weight, height)

        let bmiValue = getBMIValue()
        let bmiAdvice = getAdvice()
        let bmiColor = getColor()
        
        let flutterEngine = ((UIApplication.shared.delegate as? AppDelegate)?.flutterEngine)!;
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil);
        self.present(flutterViewController, animated: true, completion: nil)
        
        let bmiDataChannel = FlutterMethodChannel(name: "com.gerry.bmi/data", binaryMessenger: flutterViewController.binaryMessenger)
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()

         jsonObject.setValue(bmiValue, forKey: "value")
         jsonObject.setValue(bmiAdvice, forKey: "advice")
         jsonObject.setValue(bmiColor, forKey: "color")

         var convertedString: String? = nil

         do {
             let data1 =  try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
             convertedString = String(data: data1, encoding: String.Encoding.utf8)
         } catch let myJSONError {
             print(myJSONError)
         }

         bmiDataChannel.invokeMethod("fromHostToClient", arguments: convertedString)


    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(labelName)
        view.addSubview(rootStackView)
        view.addSubview(buttonNext)
        
        
        
        
        setupLayout()
    }
    
    
    private func setupLayout(){
            
            
            
            NSLayoutConstraint.activate([
                
                labelName.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
                labelName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                rootStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150),
                rootStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                sliderWeight.widthAnchor.constraint(equalToConstant: 300),
                sliderWeight.heightAnchor.constraint(equalToConstant: 30),
                
                sliderHeight.widthAnchor.constraint(equalToConstant:  300),
                sliderHeight.heightAnchor.constraint(equalToConstant: 30),
                
                buttonNext.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                buttonNext.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonNext.widthAnchor.constraint(equalToConstant: 300),
                buttonNext.heightAnchor.constraint(equalToConstant: 40),
                
                
            ])
        }


}

extension ViewController{
    

    func getBMIValue() -> String {
        let bmiTo1DecimalPlace = String(format: "%.1f", bmi?.value ?? 0.0)
        return bmiTo1DecimalPlace
    }

    func getAdvice() -> String {
        return bmi?.advice ?? "No advice"
    }

    func getColor() -> String {
        return bmi?.color ?? "white"
    }

    func calculateBMI(_ weight: Float, _ height: Float) {
        let bmiValue = weight / pow(height, 2)

        if bmiValue < 18.5 {
            bmi = BMI(value: bmiValue, advice: "Eat more pies!", color: "blue")
        } else if bmiValue < 24.9 {
            bmi = BMI(value: bmiValue, advice: "Fit as a fiddle!", color: "green")
        } else {
            bmi = BMI(value: bmiValue, advice: "Eat less pies!", color: "pink")
        }
    }
}

