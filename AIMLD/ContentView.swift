import SwiftUI

struct ContentView: View {
    @State private var isActivated = UserDefaults.standard.bool(forKey: "AIMLD_Activated")
    @State private var keyInput = ""
    @State private var errorMsg = ""
    @State private var selectedTab = 0
    
    // Trạng thái các công tắc
    @State private var aimSilent = false
    @State private var boxESP = false
    @State private var fastFire = false
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
            
            if !isActivated {
                // MÀN HÌNH NHẬP KEY
                VStack(spacing: 20) {
                    Text("AIMLD").font(.system(size: 40, weight: .bold)).foregroundColor(.purple)
                    Text("Nhập Key Để Kích Hoạt").foregroundColor(.gray)
                    
                    TextField("AIMLD-XXXX-XXXX", text: $keyInput)
                        .padding().background(Color.gray.opacity(0.2)).cornerRadius(10)
                        .foregroundColor(.white).autocapitalization(.allCharacters).multilineTextAlignment(.center)
                    
                    Button(action: {
                        errorMsg = "Đang kiểm tra..."
                        AuthManager.shared.validateKey(key: keyInput) { success, isAdmin in
                            if success { 
                                isActivated = true 
                            } else { 
                                if errorMsg == "Đang kiểm tra..." {
                                    errorMsg = "Sai Key hoặc đã hết hạn!" 
                                }
                            }
                        }
                    }) {
                        Text("Kích Hoạt").font(.headline).foregroundColor(.white)
                            .padding().frame(maxWidth: .infinity)
                            .background(Color.purple).cornerRadius(10)
                    }
                    
                    if !errorMsg.isEmpty { 
                        Text(errorMsg).foregroundColor(.red).font(.caption).multilineTextAlignment(.center)
                    }
                }.padding(30)
            } else {
                // GIAO DIỆN MENU CHÍNH
                VStack(spacing: 0) {
                    // Tabs
                    HStack(spacing: 0) {
                        TabButton(title: "Ngắm", index: 0, selected: $selectedTab)
                        TabButton(title: "Hiển thị", index: 1, selected: $selectedTab)
                        TabButton(title: "Chiến đấu", index: 2, selected: $selectedTab)
                    }
                    .background(Color(red: 0.1, green: 0.1, blue: 0.15))
                    .cornerRadius(12)
                    .padding()

                    // Nội dung Tabs
                    ScrollView {
                        VStack(spacing: 12) {
                            if selectedTab == 0 {
                                ModToggle(title: "Aim Silent", subtitle: "Silent aim với headshot rate", isOn: $aimSilent)
                                    .onChange(of: aimSilent) { _ in syncSettings() }
                            } else if selectedTab == 1 {
                                ModToggle(title: "Box ESP", subtitle: "Khung viền enemy", isOn: $boxESP)
                                    .onChange(of: boxESP) { _ in syncSettings() }
                            } else if selectedTab == 2 {
                                ModToggle(title: "Fast Fire", subtitle: "Tăng tốc độ bắn", isOn: $fastFire)
                                    .onChange(of: fastFire) { _ in syncSettings() }
                            }
                        }.padding(.horizontal)
                    }
                    
                    // Bottom Bar
                    HStack {
                        VStack(alignment: .leading) {
                            Text("• Đã lưu lên máy chủ").font(.caption).foregroundColor(.gray)
                            Text("Có thay đổi chưa lưu.").font(.caption2).foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { syncSettings() }) {
                            HStack {
                                Text("Áp dụng")
                                Image(systemName: "arrow.right")
                            }
                            .padding().background(Color.purple).foregroundColor(.white).cornerRadius(10)
                        }
                    }
                    .padding().background(Color(red: 0.1, green: 0.1, blue: 0.15))
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowError"))) { notification in
            if let msg = notification.object as? String {
                self.errorMsg = msg
            }
        }
    }
    
    func syncSettings() {
        AuthManager.shared.sendSettingsToServer(aimbot: aimSilent, esp: boxESP, fastFire: fastFire)
    }
}

struct TabButton: View {
    var title: String
    var index: Int
    @Binding var selected: Int
    var body: some View {
        Button(action: { selected = index }) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selected == index ? .white : .gray)
                .padding(.vertical, 12).frame(maxWidth: .infinity)
                .background(selected == index ? Color.black : Color.clear)
                .cornerRadius(10)
        }
    }
}

struct ModToggle: View {
    var title: String
    var subtitle: String
    @Binding var isOn: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundColor(.white)
                Text(subtitle).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().toggleStyle(SwitchToggleStyle(tint: Color.cyan))
        }
        .padding()
        .background(Color(red: 0.08, green: 0.1, blue: 0.15))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}