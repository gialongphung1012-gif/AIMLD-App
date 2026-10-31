import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    // IP máy tính của bạn
    let apiURL = "http://192.168.1.207:3000/api/validate"
    let updateURL = "http://192.168.1.207:3000/api/update_settings"
    
    func validateKey(key: String, completion: @escaping (Bool, Bool) -> Void) {
        guard let url = URL(string: apiURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["key": key]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    let status = json["status"] as? String
                    if status == "success" {
                        let isAdmin = json["isAdmin"] as? Bool ?? false
                        UserDefaults.standard.set(true, forKey: "AIMLD_Activated")
                        if isAdmin {
                            UserDefaults.standard.set(true, forKey: "AIMLD_Admin")
                        }
                        completion(true, isAdmin)
                    } else {
                        // Hiển thị lỗi từ Server trả về (ví dụ: "Key không tồn tại", "Key đã hết hạn")
                        let msg = json["message"] as? String ?? "Lỗi không xác định từ Server"
                        print("Server báo lỗi: \(msg)")
                        NotificationCenter.default.post(name: NSNotification.Name("ShowError"), object: msg)
                        completion(false, false)
                    }
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowError"), object: "Không thể kết nối tới Server")
                    completion(false, false)
                }
            }
        }.resume()
    }
    
    func sendSettingsToServer(aimbot: Bool, esp: Bool, fastFire: Bool) {
        guard let url = URL(string: updateURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["aimbot": aimbot, "esp": esp, "fast_fire": fastFire]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request).resume()
    }
}