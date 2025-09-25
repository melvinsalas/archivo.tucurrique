# archivo.tucurrique

Este repositorio se publica con GitHub Pages usando el stack oficial de Jekyll (gem github-pages). Para desarrollar en Windows sin pelear con dependencias nativas, puedes levantar el sitio dentro de un contenedor Docker basado en Linux.

## Requisitos

- Docker Desktop 4.x o compatible
- Extension de Docker Compose (`docker compose`) o el binario clasico `docker-compose`

## Servir localmente con Docker

1. Abre una terminal en la raiz del repositorio.
2. Ejecuta `docker compose up` (o `docker-compose up`). El compose construye una imagen ligera sobre `jekyll/jekyll:pages` e instala las toolchains (gcc/make) necesarias para compilar las gemas de Ruby. La primera vez tardara un poco porque instalara las gemas dentro del volumen `bundle`.
3. Visita <http://localhost:4000>. El livereload se expone en el puerto 35729.
4. Cuando termines, usa `Ctrl+C` para detener el contenedor.

El contenedor corre un entorno totalmente Linux, el mismo que usa GitHub para publicar el sitio, asi que no modifica el flujo de CI: GitHub seguira compilando directamente desde la rama `main`, mientras que Docker se limita al desarrollo local.

Si cambias gemas o ejecutas `bundle update`, los cambios se reflejan al reiniciar el contenedor y permanecen aislados dentro del volumen `bundle`.
