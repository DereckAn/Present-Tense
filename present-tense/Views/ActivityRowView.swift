//
//  ActivityRowView.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/28/25.
//


import SwiftUI

struct ActivityRowView: View {
    let activity: ActivityLog

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(activity.timestamp, formatter: DayLogViewModel.timeFormatter)
                .font(.system(.body, design: .monospaced)) // Fuente monoespaciada para alinear tiempos
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing) // Ancho fijo para alinear

            Text(activity.description)
                .frame(maxWidth: .infinity, alignment: .leading) // Ocupa el espacio restante
                .lineLimit(nil) // Permite múltiples líneas si la descripción es larga
        }
        .padding(.vertical, 4) // Un poco de espacio vertical
    }
}

// Preview para ActivityRowView
struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRowView(activity: ActivityLog(description: "Tomar un café y leer noticias importantes del día."))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}