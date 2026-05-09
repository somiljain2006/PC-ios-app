import SwiftUI

struct ContentView: View {
    @State private var progress: CGFloat = 0.3
    @State private var isAnimating = false
    @State private var navigate = false

    var body: some View {
        if navigate {
            HomeView()
        } else {
            ZStack {
                Color(red: 24 / 255, green: 16 / 255, blue: 31 / 255)
                    .ignoresSafeArea()

                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 120)
                    .offset(x: -150, y: -200)

                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 120)
                    .offset(x: 150, y: 200)

                VStack {
                    Spacer()

                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)

                    Spacer()

                    VStack(spacing: 12) {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 2)

                            Rectangle()
                                .fill(Color.red)
                                .frame(width: progress * 200, height: 2)
                        }
                        .frame(width: 200)

                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.red)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)

                            Text("LOADING...")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                        }
                    }

                    Spacer().frame(height: 60)
                }
            }
            .onAppear {
                isAnimating = true

                withAnimation(.easeInOut(duration: 2)) {
                    progress = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    navigate = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
