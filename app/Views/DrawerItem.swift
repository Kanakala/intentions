import SwiftUI

struct DrawerItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, AppSpacing.sm)
        }
    }
} 