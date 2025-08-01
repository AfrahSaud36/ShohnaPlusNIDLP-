import SwiftUI
import MapKit

struct RealTimeTrackingView: View {
    let trackingNumber: String
    @StateObject private var trackingService = RealTimeTrackingService.shared
    @State private var trackingInfo: RealTimeTrackingInfo?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showDriverContact = false
    @State private var showNotifications = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with app's off-white color
                Color("offWhite")
                    .ignoresSafeArea()
                
                // Purple header background
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "3A1C71"),
                                    Color(hex: "6A1B9A")
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: 140)
                        .ignoresSafeArea(edges: .top)
                    Spacer()
                }
                
                if let tracking = trackingInfo {
                    VStack(spacing: 30) {
                        // Header
                        HStack {
                            Button("إغلاق") {
                                trackingService.stopTracking(trackingNumber: trackingNumber)
                                dismiss()
                            }
                            .foregroundColor(.white)
                            .font(.body)
                            .padding(.leading)
                            
                            Spacer()
                            
                            Text("التتبع المباشر")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { showNotifications = true }) {
                                NotificationBadgeView()
                            }
                            .padding(.trailing)
                        }
                        .frame(height: 70)
                        .padding(.top, 1)
                        
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                // Live Status Section
                                LiveStatusCard(tracking: tracking)
                                
                                // Map Section
                                RealTimeMapCard(tracking: tracking, region: $region, trackingInfo: $trackingInfo)
                                
                                // Driver Section
                                if let driver = tracking.driverInfo {
                                    DriverInfoCard(driver: driver, onContact: { showDriverContact = true })
                                }
                                
                                // Timeline Section
                                TrackingTimelineCard(steps: tracking.trackingSteps)
                                
                                // Updates Section
                                LiveUpdatesCard()
                                
                                // Bottom spacing for safe area
                                Color.clear.frame(height: 20)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                        }
                    }
                } else {
                    // Loading State with purple theme
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "6A1B9A")))
                        
                        Text("جاري تحميل معلومات التتبع...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            startTracking()
            TrackingNotificationService.shared.requestNotificationPermission()
        }
        .onDisappear {
            trackingService.stopTracking(trackingNumber: trackingNumber)
        }
        .sheet(isPresented: $showDriverContact) {
            if let driver = trackingInfo?.driverInfo {
                DriverContactSheet(driver: driver)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsListView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func startTracking() {
        trackingInfo = trackingService.startTracking(trackingNumber: trackingNumber)
        if let tracking = trackingInfo {
            region.center = tracking.currentLocation.coordinate
        }
    }
}

// MARK: - Live Status Card
struct LiveStatusCard: View {
    let tracking: RealTimeTrackingInfo
    
    var body: some View {
        VStack(spacing: 16) {
            // Live indicator and last update
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .scaleEffect(tracking.isLive ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: tracking.isLive)
                    
                    Text("مباشر")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.red.opacity(0.1))
                .clipShape(Capsule())
                
                Spacer()
                
                Text("آخر تحديث: \(formatTime(tracking.lastUpdated))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Status and progress
            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tracking.currentStatus.title)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Text(tracking.currentStatus.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(tracking.currentStatus.percentage))%")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(Color(hex: "6A1B9A"))
                        
                        Text("مكتمل")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress Bar with purple theme
                ProgressView(value: tracking.currentStatus.percentage / 100.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .scaleEffect(x: 1, y: 1.5)
                    .foregroundColor(Color(hex: "6A1B9A"))
            }
            
            // ETA Section
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(Color(hex: "6A1B9A"))
                    .font(.system(size: 16, weight: .medium))
                
                Text("الوصول المتوقع")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(formatETA(tracking.estimatedDeliveryTime))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(hex: "6A1B9A"))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(hex: "6A1B9A").opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: date)
    }
    
    private func formatETA(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: date)
    }
}

// MARK: - Real-Time Map Card
struct RealTimeMapCard: View {
    let tracking: RealTimeTrackingInfo
    @Binding var region: MKCoordinateRegion
    @Binding var trackingInfo: RealTimeTrackingInfo?
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with actions
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("الموقع الحالي")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("تحديث مباشر كل 5 ثواني")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("تكبير") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color(hex: "6A1B9A"))
            }
            
            // Map with modern styling
            Map(coordinateRegion: $region, annotationItems: [TrackingMapAnnotation(tracking: tracking)]) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "6A1B9A"))
                            .frame(width: 36, height: 36)
                            .shadow(color: Color(hex: "6A1B9A").opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "box.truck.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(tracking.isLive ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: tracking.isLive)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onReceive(NotificationCenter.default.publisher(for: .trackingLocationUpdated)) { _ in
                if let updatedTracking = trackingInfo {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        region.center = updatedTracking.currentLocation.coordinate
                    }
                }
            }
            
            // Address section
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                
                Text(tracking.currentLocation.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct TrackingMapAnnotation: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    init(tracking: RealTimeTrackingInfo) {
        self.coordinate = tracking.currentLocation.coordinate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
    
    static func == (lhs: TrackingMapAnnotation, rhs: TrackingMapAnnotation) -> Bool {
        return lhs.id == rhs.id &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

// MARK: - Driver Info Card
struct DriverInfoCard: View {
    let driver: DriverInfo
    let onContact: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("معلومات السائق")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Driver Avatar with purple theme
                Circle()
                    .fill(Color(hex: "6A1B9A").opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color(hex: "6A1B9A"))
                    )
                
                // Driver Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(driver.name)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text(String(format: "%.1f", driver.rating))
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                        }
                        
                        Circle()
                            .fill(.secondary)
                            .frame(width: 3, height: 3)
                        
                        Text(driver.vehicleType)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(driver.vehicleNumber)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Contact Button with purple theme
                Button(action: onContact) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Color(hex: "6A1B9A"))
                        .clipShape(Circle())
                        .shadow(color: Color(hex: "6A1B9A").opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Tracking Timeline Card
struct TrackingTimelineCard: View {
    let steps: [TrackingStep]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("مراحل التسليم")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(steps.filter(\.isCompleted).count) من \(steps.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    TrackingStepRow(
                        step: step,
                        isLast: index == steps.count - 1
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct TrackingStepRow: View {
    let step: TrackingStep
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline indicator with purple theme
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(step.isCompleted ? Color(hex: "6A1B9A") : Color.gray.opacity(0.3))
                        .frame(width: 16, height: 16)
                    
                    if step.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    if step.isCurrentStep {
                        Circle()
                            .stroke(Color(hex: "6A1B9A"), lineWidth: 3)
                            .frame(width: 24, height: 24)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: step.isCurrentStep)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(step.isCompleted ? Color(hex: "6A1B9A") : Color.gray.opacity(0.3))
                        .frame(width: 2, height: 32)
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(step.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(step.isCompleted ? .primary : .secondary)
                    
                    Spacer()
                    
                    if let timestamp = step.timestamp {
                        Text(formatTimestamp(timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: date)
    }
}

// MARK: - Live Updates Card
struct LiveUpdatesCard: View {
    @StateObject private var trackingService = RealTimeTrackingService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("التحديثات المباشرة")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !trackingService.liveUpdates.isEmpty {
                    Text("آخر \(min(trackingService.liveUpdates.count, 5))")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                }
            }
            
            if trackingService.liveUpdates.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 24))
                        .foregroundColor(Color.gray.opacity(0.4))
                    
                    Text("لا توجد تحديثات حالياً")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(trackingService.liveUpdates.prefix(5), id: \.timestamp) { update in
                        LiveUpdateRow(update: update)
                        
                        if update.timestamp != trackingService.liveUpdates.prefix(5).last?.timestamp {
                            Divider()
                                .padding(.leading, 24)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct LiveUpdateRow: View {
    let update: TrackingUpdate
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "6A1B9A").opacity(0.3))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                if let message = update.message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Text(formatUpdateTime(update.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
    }
    
    private func formatUpdateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: date)
    }
}

// MARK: - Driver Contact Sheet
struct DriverContactSheet: View {
    let driver: DriverInfo
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                // Driver Info Section with purple theme
                VStack(spacing: 20) {
                    Circle()
                        .fill(Color(hex: "6A1B9A").opacity(0.1))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(Color(hex: "6A1B9A"))
                        )
                    
                    VStack(spacing: 8) {
                        Text(driver.name)
                            .font(.title2.weight(.bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                                
                                Text(String(format: "%.1f", driver.rating))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Circle()
                                .fill(.secondary)
                                .frame(width: 3, height: 3)
                            
                            Text(driver.vehicleType)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(driver.vehicleNumber)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                
                // Contact Actions with purple theme
                VStack(spacing: 16) {
                    Button(action: {
                        if let url = URL(string: "tel:\(driver.phoneNumber)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("اتصال")
                                .font(.headline.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "3A1C71"), Color(hex: "6A1B9A")]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "6A1B9A").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        if let url = URL(string: "sms:\(driver.phoneNumber)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("رسالة نصية")
                                .font(.headline.weight(.semibold))
                        }
                        .foregroundColor(Color(hex: "6A1B9A"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6A1B9A").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle("تواصل مع السائق")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LinearGradient(gradient: Gradient(colors: [Color(hex: "3A1C71"), Color(hex: "6A1B9A")]), startPoint: .bottom, endPoint: .top), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("تم") {
                        dismiss()
                    }
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    RealTimeTrackingView(trackingNumber: "TRK001")
} 
