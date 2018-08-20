//
//  BlendModeButton.swift
//  ImageCompose
//
//  Created by Kazuo Tsubaki on 2018/08/20.
//  Copyright © 2018年 Kazuo Tsubaki. All rights reserved.
//

import UIKit

protocol BlendModeButtonDelegate: NSObjectProtocol {
    func didSelect(blendModeButton: BlendModeButton, selectedMode: CGBlendMode)
    func didCancel(blendModeButton: BlendModeButton)
    func selectedBlendMode(blendModeButton: BlendModeButton) -> CGBlendMode;
}

class BlendModeButton: UIButton {
    
    var delegate: BlendModeButtonDelegate!
    var pickerView: UIPickerView!
    
    let blendModes: [CGBlendMode] = [.normal, .multiply, .screen, .overlay, .darken, .lighten, .colorDodge, .colorBurn, .softLight, .hardLight, .difference, .exclusion, .hue, .saturation, .color, .luminosity, .clear, .copy, .sourceIn, .sourceOut, .sourceAtop, .destinationOver, .destinationIn, .destinationOut, .xor, .plusDarker, .plusLighter]
    let blendModeLabels: [String] = ["normal", "multiply", "screen", "overlay", "darken", "lighten", "colorDodge", "colorBurn", "softLight", "hardLight", "difference", "exclusion", "hue", "saturation", "color", "luminosity", "clear", "copy", "sourceIn", "sourceOut", "sourceAtop", "destinationOver", "destinationIn", "destinationOut", "xor", "plusDarker", "plusLighter"]

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc func didTouchUpInside(_ sender: UIButton) {
        becomeFirstResponder()
    }
    
    override var inputView: UIView? {
        pickerView = UIPickerView()
        pickerView.delegate = self
        let mode = delegate.selectedBlendMode(blendModeButton: self)
        if let row = blendModes.index(of: mode) {
            if row >= 0 {
                pickerView.selectRow(row, inComponent: 0, animated: true)
            }
        }
        return pickerView
    }
    
    override var inputAccessoryView: UIView? {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(BlendModeButton.clickCancel))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(BlendModeButton.clickDone))
        toolbar.setItems([cancelButton, space, doneButton], animated: true)
        return toolbar
    }
    
    private func titleLabel() -> String {
        var label = ""
        let mode = delegate.selectedBlendMode(blendModeButton: self)
        if let row = blendModes.index(of: mode) {
            if row >= 0 {
                label = blendModeLabels[row]
            }
        }
        return label
    }
    
    override func draw(_ rect: CGRect) {
        setTitle(titleLabel(), for: .normal)
        super.draw(rect)
    }
    
    @objc func clickDone() {
        let row = pickerView.selectedRow(inComponent: 0)
        delegate.didSelect(blendModeButton: self, selectedMode: blendModes[row])
        self.setNeedsDisplay()
    }
    
    @objc func clickCancel() {
        delegate.didCancel(blendModeButton: self)
    }
}

extension BlendModeButton: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return blendModes.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return blendModeLabels[row]
    }
    
}
