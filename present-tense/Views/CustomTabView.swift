//
//  Tab.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/28/25.
//


import SwiftUI

// Enum para los tabs
enum Tab {
    case timeline, settings, plan
}

struct CustomTabView: View {
    // Binding para saber qué tab está seleccionado y poder cambiarlo
    @Binding var selectedTab: Tab
    // Closure para la acción del botón "+"
    let addAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. La barra de navegación principal (HStack)
            HStack {
                // Botón Timeline
                TabButton(systemImage: "list.bullet", text: "Timeline",
                          isSelected: selectedTab == .timeline) {
                    selectedTab = .timeline
                }

                Spacer() // Espacio antes del botón "+"

                // Botón Plan
                TabButton(systemImage: "calendar.badge.clock", text: "Plan",
                          isSelected: selectedTab == .plan) {
                     selectedTab = .plan
                }

                Spacer() // Espacio simétrico

                 // Botón Settings
                TabButton(systemImage: "gear", text: "Settings",
                          isSelected: selectedTab == .settings) {
                    selectedTab = .settings
                }
            }
            .padding(.horizontal)
            .padding(.top, 12) // Espacio arriba dentro de la barra
            .padding(.bottom, bottomSafeArea()) // Ajusta por el área segura inferior
            .background(.thinMaterial) // Efecto translúcido
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // Esquinas redondeadas
            .shadow(color: .black.opacity(0.1), radius: 5, y: -3) // Sombra suave
            .padding(.horizontal) // Espacio a los lados de la barra completa

            // 2. El botón "+" flotante
            Button {
                addAction() // Ejecuta la acción de añadir
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .padding(18) // Hace el área táctil más grande y el círculo
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            // Ajusta la posición Y para que "suba"
            // El valor exacto puede necesitar ajuste según el padding y tamaño del botón
            .offset(y: -35) // Empuja el botón hacia arriba
        }
        // Asegura que la ZStack no tome altura innecesaria por sí misma
        .frame(height: 70 + bottomSafeArea()) // Altura fija estimada para la barra + safe area
    }

    // Helper para obtener la altura del área segura inferior
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