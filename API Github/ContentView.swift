//
//  ContentView.swift
//  API Github
//
//  Created by Raina Rodrigues on 23/01/25.
// curl https://api.github.com/users/rainarodrigues/followers
// curl https://api.github.com/users/rainarodrigues


import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUSer?
    
    var body: some View {
        VStack (spacing: 20){
            AsyncImage(url: URL(string: user?.avatarUrl ?? ""))
            {image in image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }placeholder: {
                Circle()
                    .foregroundStyle(.secondary)
            }.frame(width: 120,height: 120)
                
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
            
            Spacer()
            
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            }catch GHError.invalidURL{
                print("url invalid")
            }catch GHError.invalidResponse{
                print("invalid response")
            }catch GHError.invalidData{
                print( "invalid data")
            }catch{
                print("unexpected error")
            }
        }
    }
    func getUser() async throws -> GitHubUSer {
        let endpoint = "https://api.github.com/users/RainaRodrigues"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
          
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUSer.self, from: data)
        } catch{
            throw GHError.invalidData
        }
        
        return try JSONDecoder().decode(GitHubUSer.self, from: data)
    }
}

struct ContentView_Prewiews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GitHubUSer: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

