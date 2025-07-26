import SwiftUI

struct DrawerView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Profile Section
                    SectionCard(style: .elevated, padding: .all(AppSpacing.md)) {
                        Text("👤 Guest")
                            .font(AppFonts.titleMedium)
                            .padding(.bottom, AppSpacing.sm)
                        DrawerItem(icon: "person.fill", title: "Sign In") {
                            // Trigger sign in
                        }
                    }
                    // General Settings
                    SectionCard(style: .elevated, padding: .all(AppSpacing.md)) {
                        Text("⚙️ General")
                            .font(AppFonts.captionMedium)
                            .foregroundColor(AppColors.textSecondary)
                        DrawerItem(icon: "paintbrush.fill", title: "Appearance") {
                            // Open appearance settings
                        }
                        DrawerItem(icon: "bell.fill", title: "Notifications") {
                            // Open notification screen
                        }
                    }
                    // Support
                    SectionCard(style: .elevated, padding: .all(AppSpacing.md)) {
                        Text("💬 Support")
                            .font(AppFonts.captionMedium)
                            .foregroundColor(AppColors.textSecondary)
                        DrawerItem(icon: "envelope.fill", title: "Send Feedback") {
                            // Feedback action
                        }
                        DrawerItem(icon: "star.fill", title: "Rate Us") {
                            // App Store redirect
                        }
                        DrawerItem(icon: "lock.shield.fill", title: "Privacy Policy") {
                            // Open web link or policy sheet
                        }
                    }
                    // About
                    SectionCard(style: .elevated, padding: .all(AppSpacing.md)) {
                        Text("ℹ️ About")
                            .font(AppFonts.captionMedium)
                            .foregroundColor(AppColors.textSecondary)
                        HStack {
                            Text("Version 1.0.0")
                                .font(AppFonts.captionMedium)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(AppColors.background.ignoresSafeArea())
            }
            .navigationTitle("Menu")
        }
    }
} 