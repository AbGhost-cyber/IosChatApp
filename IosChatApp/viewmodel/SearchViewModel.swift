//
//  SearchViewModel.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/3/1.
//

import Foundation
import Combine
enum SearchScope {
    case group
    case chat
}


@MainActor
class SearchViewModel: ObservableObject {
    
    @Published var phase: FetchPhase<[SearchData]> = .initial
    @Published var keyword: String = ""
    
    @Published var scope: SearchScope = .group
    
    private var trimmedQuery: String {
        keyword.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var errorMsg: Error? { phase.error }
    var isSearching: Bool { !trimmedQuery.isEmpty }
    
    var emptyListText: String {
        "No \(scope == .group ? "group" : "chat") found for\n\"\(keyword)\""
    }
    
    var searchedGroups: [SearchData] { phase.value ?? [] }
    
    private var cancellables = Set<AnyCancellable>()
    private let service: UserSocketService
    private var userGroups: [Group] = []
    
    init(keyword: String = "", service: UserSocketService = UserSocketImpl()) {
        self.keyword = keyword
        self.service = service
        startObserving()
    }
    
    private func startObserving() {
        $keyword
            .debounce(for: 1.5, scheduler: DispatchQueue.main)
            .sink { _ in
                Task {
                    [weak self] in await self?.doSearch()
                }
            }
            .store(in: &cancellables)
        $keyword
            .filter{$0.isEmpty}
            .sink {
                [weak self] _ in self?.phase = .initial
            }
            .store(in: &cancellables)
        $scope
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { _ in
                Task {
                    [weak self] in await self?.doSearch()
                }
            }
            .store(in: &cancellables)
        
    }
    
    func doSearch() async {
        if scope == .group {
            await searchGroups()
        } else {
            await searchChats()
        }
    }
    
    func userIsGroupMember(groupdId: String) -> Bool {
        return userGroups.contains(where: {$0.groupId == groupdId})
    }
    
    func setUserGroups(_ groups: [Group]) {
        self.userGroups = groups
    }
    
    
    func searchChats() async {
        let searchedQuery = trimmedQuery
        guard !searchedQuery.isEmpty else { return }
        phase = .fetching

        let searchGroupList = userGroups.filter { group in
            group.messages.contains(where: {$0.message.lowercased().contains(searchedQuery.lowercased())})
        }.map {$0.toSearchData(query: searchedQuery)}

        if searchedQuery != trimmedQuery { return }
        if searchGroupList.isEmpty {
            phase = .empty
        }else {
            phase = .success(searchGroupList)
        }
    }
    
    func searchGroups() async {
        let searchedQuery = trimmedQuery
        guard !searchedQuery.isEmpty else { return }
        phase = .fetching
        
        do {
            let searchedGroups = try await service.searchGroups(with: searchedQuery.lowercased())
            if searchedQuery != trimmedQuery { return }
            if searchedGroups.isEmpty {
                phase = .empty
            } else {
                phase = .success(searchedGroups.map{$0.toSearchData()})
            }
        } catch {
            if searchedQuery != trimmedQuery { return }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
}
