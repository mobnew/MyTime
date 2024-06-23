//
//  DayCell.swift
//  MyTime
//
//  Created by Alexey Kurazhov on 22.06.2024.
//

import UIKit

class DayCell: UICollectionViewCell {
    static let identifier = "DayCell"
        
        private let dayLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(dayLabel)
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(with day: String) {
            dayLabel.text = day
        }
}
