# DevShare: preparar el backend

La app usa el cliente oficial de Supabase para autenticación, Postgres, Storage y Realtime. No guardes una `service_role` key en Flutter; la app solo debe usar la publishable/anon key.

## Conectar un proyecto

1. Crea el proyecto Supabase.
2. En **SQL Editor**, ejecuta `supabase/migrations/0001_devshare.sql` una vez. Esto crea perfiles, publicaciones, comentarios, likes, comunidades y membresías, cursos y avance, conversaciones, mensajes, amistades, actividad, eventos y buckets/policies de Storage.
3. Copia `.env.example` a `.env` y reemplaza `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY` con los valores del proyecto.
4. Ejecuta `flutter pub get` y luego `flutter run -d edge` (o el destino de tu plataforma).

## Tablas y operaciones disponibles en repositorios

- `AuthRepository`: registro, login, logout, recuperación y stream de sesión.
- `PostsRepository`: paginar/listar, crear, editar, borrar, subir multimedia, likes y comentarios; valida enlaces `youtube.com`, `youtu.be`, Shorts, embeds y lives.
- `FeatureRepository`: CRUD y membresías de comunidades, CRUD de cursos/progreso, perfil, amistades, eventos/RSVP, conversaciones y mensajes en tiempo real, actividad.
- `YoutubePostPlayer`: reproductor embebido con indicador de transmisión en vivo.

RLS está activado en las tablas de la migración. Los objetos de Storage usan la carpeta con el UUID del usuario; conserva ese formato cuando cargues archivos.

## Límite de seguridad

El cliente Flutter no crea tablas porque una publishable key nunca debe tener privilegios administrativos. La migración es la instalación del esquema y debe aplicarse una vez al proyecto; después, la app usa las credenciales del `.env`.
