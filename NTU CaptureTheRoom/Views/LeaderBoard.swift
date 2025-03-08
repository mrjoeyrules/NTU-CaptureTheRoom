import SwiftUI
import FirebaseFirestore

struct LeaderBoard: View {
    @Binding var showLeaderboard: Bool
    @State private var teams: [(name: String, score: Int)] = []
    @ObservedObject private var colourSelector = ColourSelector()
    
    
    
    // Fetch leaderboard from Firestore
    func fetchLeaderBoardData() {
        let db = Firestore.firestore()
        
        db.collection("Rooms").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching leaderboard data: \(error.localizedDescription)")
                return
            }
            
            var greyCaps = 0
            var blueCaps = 0
            var pinkCaps = 0
            
            for document in snapshot?.documents ?? [] {
                let teamOwner = document.data()["teamowner"] as? String ?? "unclaimed"
                
                switch teamOwner.lowercased() {
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
            
            let allTeams = [
                ("Team Grey", greyCaps),
                ("Team Blue", blueCaps),
                ("Team Pink", pinkCaps)
            ]
            
            DispatchQueue.main.async {
                teams = allTeams.sorted { $0.1 > $1.1 } // Sort by rooms captured
            }
        }
    }
    
    
    
    var body: some View {
        ZStack {
            // allows for full screen
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showLeaderboard = false // Close when tapping outside
                }
            
            // Main leaderboard
            VStack(spacing: 10) {
                Text("Leaderboard")
                    .font(.title)
                    .bold()
                    .padding(.top, 10)
                
                VStack(spacing: 10) {
                    ForEach(teams.indices, id: \.self) { index in
                        HStack {
                            Text(Image(systemName: "trophy.fill"))
                                .font(.headline)
                                .foregroundStyle(colourSelector.getTrophyColourLeaderboard(for: index))
                            
                            Text(teams[index].name)
                                .font(.headline)
                                .bold()
                            
                            Spacer()
                            
                            Text("\(teams[index].score) Rooms Captured")
                                .foregroundColor(Color.white)
                                .bold()
                                .font(.subheadline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.background)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(teams.indices.contains(index) ? colourSelector.getLeaderboardOutline(team: teams[index].name) : Color.clear, lineWidth: 4)

                        )
                    }
                }
                .padding()
                .background(Color.background)
                .cornerRadius(10)
                
                // Close Button
                Button(action: {
                    showLeaderboard = false
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
            .frame(width: 350, height: 400)
            .background(Color.background)
            .cornerRadius(15)
            .shadow(color: teams.first.map { colourSelector.getShadowColourLeaderboard(team: $0.name) } ?? Color.clear, radius: 10)

        }
        .onAppear {
            fetchLeaderBoardData()
        }
    }
}
