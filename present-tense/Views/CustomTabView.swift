//
//  Tab.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/28/25.
//


import SwiftUI

// Enum para los tabs
// (Dentro o fuera de ContentView, donde sea accesible)
enum Tab {
    case timeline, calendar, diary, plan, settings // Añadidos calendar y diary
}

struct CustomTabView: View {
    @Binding var selectedTab: Tab
    let addAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. La barra de navegación principal (HStack)
            HStack {
                // Botón Timeline
                TabButton(systemImage: "list.bullet", text: "Timeline", isSelected: selectedTab == .timeline) {
                    selectedTab = .timeline
                }

                // Botón Calendar
                TabButton(systemImage: "calendar", text: "Calendar", isSelected: selectedTab == .calendar) {
                    selectedTab = .calendar
                }

                // Espacio central flexible donde "flotará" el botón +
                Spacer()

                // Botón Diary
                TabButton(systemImage: "book.closed", text: "Diary", isSelected: selectedTab == .diary) {
                    selectedTab = .diary
                }

                // Botón Plan (Considera si "Plan" sigue siendo necesario o si se fusiona con Calendar/Diary)
                 TabButton(systemImage: "chart.bar", text: "Plan", isSelected: selectedTab == .plan) { // Cambié icono a algo más genérico
                    selectedTab = .plan
                 }

                 // Botón Settings
                TabButton(systemImage: "gear", text: "Settings", isSelected: selectedTab == .settings) {
                    selectedTab = .settings
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, bottomSafeArea())
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5, y: -3)
            .padding(.horizontal)

            // 2. El botón "+" flotante (permanece igual, pero su posición visual es entre Calendar y Diary)
            Button {
                addAction()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .padding(18)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .offset(y: -35) // Ajusta según sea necesario

        }
        .frame(height: 70 + bottomSafeArea())
    }

    // Helper para el área segura 
    private func bottomSafeArea() -> CGFloat {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

// Vista auxiliar para los botones de la TabBar
struct TabButton: View {
    let systemImage: String
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(text)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .blue : .gray) // Cambia color si está seleccionado
        }
        .frame(maxWidth: .infinity) // Ocupa espacio equitativamente
    }
}

// Preview para CustomTabView
#Preview {
    VStack {
        Spacer() // Empuja la TabView hacia abajo para previsualizar
        CustomTabView(selectedTab: .constant(.timeline)) {
            print("Add button tapped")
        }
    }
    .background(Color.gray.opacity(0.2)) // Fondo para ver la barra
}
