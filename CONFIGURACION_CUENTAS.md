# Activar registro e inicio de sesión — DAW Planner

La web ya tiene el formulario de registro, inicio de sesión y sincronización por cuenta, pero **todavía necesita una base de datos Supabase**. GitHub Pages sirve páginas estáticas y no puede almacenar usuarios ni contraseñas de forma segura por sí solo.

## Pasos (solo el propietario de la web)

1. Visita https://supabase.com/dashboard y crea un proyecto nuevo.
2. En el proyecto, abre **SQL Editor** y ejecuta todo el contenido de [supabase.sql](supabase.sql). Esto crea la tabla de agendas, permisos RLS y guardado seguro con control de conflictos.
3. Abre **Authentication → Providers → Email** y mantén habilitado el registro con correo. Normalmente se requiere verificar el correo; cada usuario deberá confirmarlo antes de iniciar sesión.
4. En **Authentication → URL Configuration**, establece Site URL en \`https://maurinior.github.io/agenda/\` y añade esa dirección a los Redirect URLs permitidos.
5. Busca **Project URL** y **Publishable key** (en **Project Settings → API Keys** o en el cuadro **Connect** del dashboard). Abre [config.js](config.js) y pega únicamente esos valores en \`url\` y \`publishableKey\`.
6. Haz commit de \`config.js\`. No copies una **secret key**, **service_role**, contraseña ni token personal de GitHub. La publishable key se puede publicar en una web con RLS activado.
7. Entra en https://maurinior.github.io/agenda/, abre **Mi cuenta**, crea una cuenta y verifica el correo si Supabase lo solicita. Tu amigo podrá crear otra cuenta distinta con otro correo y contraseña.

## Tus exámenes anteriores NO se borran

- Los exámenes del navegador original permanecen intactos en la clave \`daw-planner-mauri-2026-v1\`.
- La primera vez que inicies sesión en cada cuenta, podrás **elegir** si importas esos exámenes locales. Nunca se transfieren automáticamente a la cuenta de tu amigo.
- Cada cuenta usa además su propia copia local bajo una clave derivada del ID del usuario.
- Antes de importar se guarda una copia de seguridad. Crea otra copia en **Exámenes → Exportar copia de seguridad** si quieres tenerla como archivo.
- La sincronización compara versiones y combina cambios. Si falla la red, puedes seguir guardando en el dispositivo y sincronizar cuando vuelva la conexión.
- El antiguo sistema de GitHub + token personal no debe usarse para compartir cuentas; el sistema nuevo usa Supabase con políticas RLS.

## Prueba de privacidad recomendada

1. Registra dos cuentas distintas: A y B (en correos distintos).
2. Inicia A, añade un examen, sal y entra en B; B no debe mostrar el examen de A.
3. Entra en A desde un segundo dispositivo; debes ver el examen de A.
4. Modifica una nota y comprueba que se sincroniza, y que B no puede verla.
5. Verifica que las políticas RLS siguen habilitadas antes de permitir registros públicos.

Documentación: https://supabase.com/docs/guides/auth, https://supabase.com/docs/guides/database/postgres/row-level-security
