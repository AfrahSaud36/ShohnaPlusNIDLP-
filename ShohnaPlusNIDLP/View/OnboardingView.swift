import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    var shipmentVM: ShipmentViewModel

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $vm.currentPage) {
                    ForEach(Array(vm.pages.enumerated()), id: \ .element.id) { (index, page) in
                        VStack(spacing: 24) {
                            Spacer()
                            Image(page.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .padding(.top, 20)
                            Text(page.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Text(page.subtitle)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Spacer()
                            HStack {
                                if !page.isLastPage {
                                    Button("Skip") {
                                        vm.skipToLastPage()
                                    }
                                    .foregroundColor(.gray)
                                    Spacer()
                                    Button("Next") {
                                        withAnimation {
                                            vm.goToNextPage()
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color("purple"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                } else {
                                    NavigationLink(destination: HomeView(shipmentVM: shipmentVM).navigationBarBackButtonHidden(true)) {
                                        Text("Get Started")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color("purple"))
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                        .tag(index)
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                HStack(spacing: 8) {
                    ForEach(0..<vm.pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == vm.currentPage ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 10)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(shipmentVM: ShipmentViewModel())
            .environmentObject(ReturnDataModel())
    }
} 
