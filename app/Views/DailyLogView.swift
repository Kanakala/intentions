import SwiftUI

struct DailyLogView: View {
    var body: some View {
        VStack {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 48))
                .foregroundColor(AppColors.primary)
            Text("Daily Log")
                .font(AppFonts.titleMedium)
                .padding(.top, 8)
            Text("Your daily logs will appear here.")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
    }
} 