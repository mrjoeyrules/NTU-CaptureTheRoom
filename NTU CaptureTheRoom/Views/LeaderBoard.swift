//
//  LeaderBoard.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 07/03/2025
//



import SwiftUI
import FirebaseFirestore

struct LeaderBoard: View {
    @Binding var showLeaderboard: Bool
    @State private var teams: [(name: String, score: Int)] = []
    @ObservedObject private var colourSelector = ColourSelector()
    
    
    
    // Fetch leaderboard from Firestore
    func fetchLeaderBoardData() {
        let db = Firestore.firestore()
        
        db.collection("Rooms").getDocuments { snapshot, error in // get all rooms from rooms collection
            if let error = error {
                print("Error fetching leaderboard data: \(error.localizedDescription)")
                return
            }
            
            var greyCaps = 0 // variable for all caps of each team
            var blueCaps = 0
            var pinkCaps = 0
            
            for document in snapshot?.documents ?? [] {
                let teamOwner = document.data()["teamowner"] as? String ?? "unclaimed" // get teamowner from each doc
                
                switch teamOwner.lowercased() { // set team owner to lowercase just incase of change
                    // plus 1 to overall cap variable if teamowner = team
                case "grey":
                    greyCaps += 1
                case "blue":
                    blueCaps += 1
                case "pink":
                    pinkCaps += 1
                default:
                    break
                }
            }
            
            // store data with a named key value in a dictionary
            let allTeams = [
                ("Team Grey", greyCaps),
                ("Team Blue", blueCaps),
                ("Team Pink", pinkCaps)
            ]
            
            DispatchQueue.main.async {
                teams = allTeams.sorted { $0.1 > $1.1 } // Sort by rooms captured, most first
            }
        }
    }
    
    
    
    var body: some View {
        ZStack {
            // allows for full screen
            Color.black.opacity(0.5) // shades background on maps page a little
                .ignoresSafeArea()
                .onTapGesture { // on tapping screen do this
                    showLeaderboard = false // Close when tapping outside
                }
            
            // Main leaderboard
            VStack(spacing: 10) {
                Text("Leaderboard")
                    .font(.title)
                    .bold()
                    .padding(.top, 10)
                
                VStack(spacing: 10) {
                    ForEach(teams.indices, id: \.self) { index in // for each team
                        HStack {
                            Text(Image(systemName: "trophy.fill"))
                                .font(.headline)
                                .foregroundStyle(colourSelector.getTrophyColourLeaderboard(for: index)) // set trophy colour to number in index
                            
                            Text(teams[index].name) // get name from teams dictionary
                                .font(.headline)
                                .bold()
                            
                            Spacer()
                            
                            Text("\(teams[index].score) Rooms Captured") // get score from teams dictionary
                                .foregroundColor(Color.white)
                                .bold()
                                .font(.subheadline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8) // ensure it only takes one line and shows on screen
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.background)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(teams.indices.contains(index) ? colourSelector.getLeaderboardOutline(team: teams[index].name) : Color.clear, lineWidth: 4) // set border outline to teams colour

                        )
                    }
                }
                .padding()
                .background(Color.background)
                .cornerRadius(10)
                
                // Close Button
                Button(action: {
                    showLeaderboard = false // flag for actually showing the leaderboard
                }) {
                    Text("Close")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.actionColour)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .padding()
            .frame(width: 350, height: 400) // set frame to these values
            .background(Color.background)
            .cornerRadius(15)
            .shadow(color: teams.first.map { colourSelector.getShadowColourLeaderboard(team: $0.name) } ?? Color.clear, radius: 10) // set shadow of overall popup for effect

        }
        .onAppear {
            fetchLeaderBoardData() // when loading fetch leaderboard data
        }
    }
}
