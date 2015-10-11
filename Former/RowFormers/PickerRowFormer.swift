//
//  PickerRowFormer.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 8/2/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

public protocol PickerFormableRow: FormableRow {
    
    func formPickerView() -> UIPickerView
}

public class PickerItem<S> {
    public let title: String
    public let value: S?
    
    public init(title: String, value: S? = nil) {
        self.title = title
        self.value = value
    }
}

public class PickerRowFormer<T: UITableViewCell, S where T: PickerFormableRow>
: CustomRowFormer<T> {
    
    // MARK: Public
    
    public var onValueChanged: ((PickerItem<S>) -> Void)?
    public var pickerItems: [PickerItem<S>] = []
    public var selectedRow: Int = 0
    
    required public init(instantiateType: Former.InstantiateType = .Class, cellSetup: (T -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    public override func initialized() {
        super.initialized()
        cellHeight = 216.0
    }
    
    deinit {
        let picker = cell.formPickerView()
        picker.delegate = nil
        picker.dataSource = nil
    }
    
    public override func update() {
        super.update()
        
        cell.selectionStyle = .None
        let picker = cell.formPickerView()
        picker.delegate = observer
        picker.dataSource = observer
        picker.selectRow(selectedRow, inComponent: 0, animated: false)
        picker.userInteractionEnabled = enabled
        picker.alpha = self.enabled ? 1.0 : 0.5
    }
    
    // MARK: Private
    
    private lazy var observer: Observer<T, S> = { [unowned self] in
        Observer<T, S>(pickerRowFormer: self)
        }()
}

private class Observer<T: UITableViewCell, S where T: PickerFormableRow>
: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private weak var pickerRowFormer: PickerRowFormer<T, S>?
    
    init(pickerRowFormer: PickerRowFormer<T, S>) {
        self.pickerRowFormer = pickerRowFormer
    }
    
    private dynamic func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let pickerRowFormer = pickerRowFormer else { return }
        if pickerRowFormer.enabled {
            pickerRowFormer.selectedRow = row
            let pickerItem = pickerRowFormer.pickerItems[row]
            pickerRowFormer.onValueChanged?(pickerItem)
        }
    }
    
    private dynamic func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    private dynamic func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerRowFormer = pickerRowFormer else { return 0 }
        return pickerRowFormer.pickerItems.count
    }
    
    private dynamic func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let pickerRowFormer = pickerRowFormer else { return nil }
        return pickerRowFormer.pickerItems[row].title
    }
}