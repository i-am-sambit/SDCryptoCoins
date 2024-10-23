//
//  HomeViewModelTests.swift
//  CryptoCoinsTests
//
//  Created by Sambit Prakash Dash on 23/10/24.
//

@testable import CryptoCoins
import Testing

struct HomeViewModelTests {
    private lazy var viewModel: HomeViewModel = {
        let viewModel = HomeViewModel(cryptoService: MockCryptoService())
        return viewModel
    }()
    
    @Test("Fetch Crypto Coins")
    mutating func testCryptoCoins() async {
        await viewModel.fetchCryptoCoins()
        #expect(viewModel.cryptoCoins.count == 10)
    }
    
    @Test("Search Crypto with name or symbol")
    mutating func testSearchCryptoCoinsWithText() async {
        await viewModel.fetchCryptoCoins()
        viewModel.filterText = "bit"
        #expect(viewModel.cryptoCoins.count == 2)
    }
    
    @Test("Search Crypto without text")
    mutating func testSearchCryptoCoinsWithoutText() async {
        await viewModel.fetchCryptoCoins()
        viewModel.filterText = ""
        #expect(viewModel.cryptoCoins.count == 10)
    }
    
    @Test("Filter active cryptos")
    mutating func testToggleFilterForActiveCryptos() async {
        await viewModel.fetchCryptoCoins()
        viewModel.toggleFilter(.active)
        #expect(viewModel.activeFilters.rawValue == 4)
        #expect(viewModel.cryptoCoins.count == 9)
    }
    
    @Test("Filter inactive cryptos")
    mutating func testToggleFilterForInactiveCryptos() async {
        await viewModel.fetchCryptoCoins()
        viewModel.toggleFilter(.active)
        viewModel.toggleFilter(.inactive)
        #expect(viewModel.activeFilters.rawValue == 8)
        #expect(viewModel.cryptoCoins.count == 1)
    }
    
    @Test("Filter tokens")
    mutating func testToggleFilterForTokens() async {
        await viewModel.fetchCryptoCoins()
        viewModel.toggleFilter(.coins)
        viewModel.toggleFilter(.token)
        #expect(viewModel.activeFilters.rawValue == 1)
        #expect(viewModel.cryptoCoins.count == 2)
    }
    
    @Test("Filter coins")
    mutating func testToggleFilterForInactiveCoins() async {
        await viewModel.fetchCryptoCoins()
        viewModel.toggleFilter(.token)
        viewModel.toggleFilter(.coins)
        #expect(viewModel.activeFilters.rawValue == 2)
        #expect(viewModel.cryptoCoins.count == 8)
    }
    
    @Test("Filter new cryptos")
    mutating func testToggleFilterForNewCryptos() async {
        await viewModel.fetchCryptoCoins()
        viewModel.toggleFilter(.new)
        #expect(viewModel.activeFilters.rawValue == 16)
        #expect(viewModel.cryptoCoins.count == 3)
    }
    
    @Test("Remove new crypto filter")
    mutating func testRemoveNewCryptosFilter() async {
        await viewModel.fetchCryptoCoins()
        viewModel.toggleFilter(.new)
        viewModel.toggleFilter(.new)
        #expect(viewModel.activeFilters.rawValue == 0)
        #expect(viewModel.cryptoCoins.count == 10)
    }

}
