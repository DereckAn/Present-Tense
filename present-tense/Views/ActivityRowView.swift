import SwiftUI

struct ActivityRowView: View {
    let activity: ActivityLog

    // --- Si NO modificaste el Modelo, usa estos valores fijos ---
    let fixedIconName = "figure.walk" // O "list.bullet", "pencil", etc.
    let fixedIconColor = Color.blue
    // --- Si SÍ modificaste el Modelo, comenta las líneas de arriba y usa activity.iconName / activity.iconColor ---

    var body: some View {
        HStack(alignment: .center, spacing: 12) { // Alinear al centro verticalmente

            // 1. Hora a la izquierda
            Text(activity.timestamp, formatter: DayLogViewModel.timeFormatter)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 55, alignment: .trailing) // Ancho fijo para alinear horas

            // 2. Icono Circular
            ZStack {
                Circle()
                    // Usa el color del modelo o el fijo
                    .fill(activity.iconColor /* ?? fixedIconColor */ ) // Descomenta ?? fixedIconColor si no modificaste el modelo
                    .frame(width: 40, height: 40) // Tamaño del círculo

                Image(systemName: activity.iconName /* ?? fixedIconName */ ) // Usa el icono del modelo o el fijo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20) // Tamaño del símbolo dentro del círculo
                    .foregroundColor(.white) // Color del símbolo
            }
            // Nota: La línea vertical conectora se omite aquí por simplicidad.
            // Se podría añadir como un .background o .overlay complejo.

            // 3. Descripción de la Actividad
            Text(activity.description)
                .font(.body) // Puedes probar .headline para más énfasis
                .lineLimit(2) // Limita a 2 líneas, por ejemplo
                .frame(maxWidth: .infinity, alignment: .leading) // Ocupa el espacio restante
                .padding(.leading, 5) // Pequeño espacio tras el icono

            // 4. (Opcional) Indicador/Botón derecho (como en la imagen)
            // Lo omitimos por ahora ya que no es parte de la funcionalidad base solicitada
            // Circle()
            //     .stroke(Color.secondary, lineWidth: 1.5)
            //     .frame(width: 25, height: 25)

        }
        .padding(.vertical, 8) // Espacio vertical para cada fila
    }
}

// Preview actualizada (asegúrate de que `ActivityLog` tenga datos de ejemplo si los necesitas)
#Preview {
    VStack(alignment: .leading) {
        ActivityRowView(activity: ActivityLog(description: "Despertar y meditar un poco", iconName: "sunrise.fill", iconColor: .orange))
        ActivityRowView(activity: ActivityLog(description: "Reunión importante sobre el proyecto Aquila con todo el equipo de desarrollo", iconName: "briefcase.fill", iconColor: .blue))
        ActivityRowView(activity: ActivityLog(description: "Comida ligera", iconName: "fork.knife", iconColor: .green))
         ActivityRowView(activity: ActivityLog(description: "Terminar reporte mensual")) // Usará defaults si no especificas
    }
    .padding()
}
