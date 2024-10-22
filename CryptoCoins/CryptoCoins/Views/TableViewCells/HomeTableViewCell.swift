//
//  HomeTableViewCell.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import UIKit

final class HomeTableViewCell: UITableViewCell {
    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!
    private var coinImageView: UIImageView!
    private var newImageView: UIImageView!
    
    var cryptoCoin: CryptoCoinDM? = nil {
        didSet {
            guard let cryptoCoin else { return }
            titleLabel.text = cryptoCoin.name
            subTitleLabel.text = cryptoCoin.symbol
            coinImageView.image = cryptoCoin.icon
            newImageView.isHidden = cryptoCoin.isNew == false
            
            self.layer.opacity = cryptoCoin.isActive ? 1.0 : 0.6
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.createView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createView() {
        let containerView = UIView()
        containerView.layer.cornerRadius = 5
        containerView.backgroundColor = .systemGray6
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 16).isActive = true
        self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 0
        verticalStackView.alignment = .leading
        verticalStackView.distribution = .fillEqually
        containerView.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        verticalStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 10).isActive = true
        
        titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        verticalStackView.addArrangedSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subTitleLabel = UILabel()
        subTitleLabel.textColor = .black
        subTitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        verticalStackView.addArrangedSubview(subTitleLabel)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        coinImageView = UIImageView()
        coinImageView.contentMode = .scaleAspectFit
        containerView.addSubview(coinImageView)
        coinImageView.translatesAutoresizingMaskIntoConstraints = false
        
        coinImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        containerView.trailingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 10).isActive = true
        coinImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        coinImageView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(greaterThanOrEqualTo: coinImageView.bottomAnchor, constant: 10).isActive = true
        
        newImageView = UIImageView()
        newImageView.image = .new
        newImageView.contentMode = .scaleAspectFit
        containerView.addSubview(newImageView)
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        
        newImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        newImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        containerView.trailingAnchor.constraint(equalTo: newImageView.trailingAnchor, constant: 0).isActive = true
    }
}

#Preview {
    HomeViewController()
}
