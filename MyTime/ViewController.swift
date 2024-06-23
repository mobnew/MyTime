//
//  ViewController.swift
//  MyTime
//
//  Created by Alexey Kurazhov on 22.06.2024.
//

import UIKit

class ViewController: UIViewController {
    
    // Создаем массивы для данных
    private let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    private let years = ["2023", "2024", "2025"]
    
    // Дни выбранного месяца
    private var daysOfMonth = [String]()
    
    // Создаем текстовые поля для выпадающих меню
    private lazy var monthTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select Month"
        textField.borderStyle = .roundedRect
        textField.inputView = monthPicker
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    private lazy var yearTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select Year"
        textField.borderStyle = .roundedRect
        textField.inputView = yearPicker
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    // Создаем StackView
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [monthTextField, yearTextField])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    // Создаем выпадающее меню для месяцев
    private lazy var monthPicker: UIPickerView = {
        let monthPicker = UIPickerView()
        monthPicker.tag = 1
        monthPicker.dataSource = self
        monthPicker.delegate = self
        return monthPicker
    }()
    
    private lazy var yearPicker: UIPickerView = {
        let yearPicker = UIPickerView()
        yearPicker.tag = 2
        yearPicker.dataSource = self
        yearPicker.delegate = self
        return yearPicker
    }()
    
    // Создаем toolbar с кнопкой "Done"
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([doneButton], animated: false)
        return toolbar
    }()
    
    // Создаем CollectionView
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: DayCell.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        selectCurrentDate()
        updateDaysOfMonth()
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
    
    private func setupViews() {
        // Добавляем StackView на основной вид
        view.addSubview(stackView)
        view.addSubview(collectionView)
        
        // Устанавливаем констрейнты
        stackView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func selectCurrentDate() {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate) - 1
        let currentYear = calendar.component(.year, from: currentDate)
        
        monthTextField.text = months[currentMonth]
        if let yearIndex = years.firstIndex(of: String(currentYear)) {
            yearTextField.text = years[yearIndex]
            yearPicker.selectRow(yearIndex, inComponent: 0, animated: false)
        }
        
        monthPicker.selectRow(currentMonth, inComponent: 0, animated: false)
    }
    
    private func updateDaysOfMonth() {
        guard let selectedMonth = monthTextField.text, let selectedYear = yearTextField.text, let year = Int(selectedYear) else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        guard let monthIndex = months.firstIndex(of: selectedMonth) else {
            return
        }
        
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: monthIndex + 1)
        guard let firstDayOfMonth = calendar.date(from: dateComponents), let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return
        }
        
        daysOfMonth = []
        var currentWeek = [String](repeating: "", count: 7)
        
        for day in range {
            let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
            let weekday = calendar.component(.weekday, from: dayDate) - 1 // Sunday = 1, Saturday = 7
            
            currentWeek[weekday] = String(day)
            
            if weekday == 6 {
                daysOfMonth.append(contentsOf: currentWeek)
                currentWeek = [String](repeating: "", count: 7)
            }
        }
        
        if !currentWeek.allSatisfy({ $0 == "" }) {
            daysOfMonth.append(contentsOf: currentWeek)
        }
        
        collectionView.reloadData()
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return months.count
        } else {
            return years.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return months[row]
        } else {
            return years[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            monthTextField.text = months[row]
        } else {
            yearTextField.text = years[row]
        }
        updateDaysOfMonth()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysOfMonth.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.identifier, for: indexPath) as? DayCell else {
            return UICollectionViewCell()
        }
        
        let day = daysOfMonth[indexPath.item]
        cell.configure(with: day)
        
        let dayOfWeek = indexPath.item % 7
        if dayOfWeek == 5 || dayOfWeek == 6 { // Saturday or Sunday
            cell.backgroundColor = UIColor.systemPink.withAlphaComponent(0.3)
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: width, height: width)
    }
}
