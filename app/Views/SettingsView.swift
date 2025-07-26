import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.primary)
            Text("Settings")
                .font(AppFonts.titleMedium)
                .padding(.top, 8)
            Text("App settings and preferences will appear here.")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
    }
} 