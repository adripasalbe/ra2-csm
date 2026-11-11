# INFORME RA3 · Administración de gestores de contenidos

Nombre: Adrian Pascual

## 1. Usuarios y perfiles

WordPress asigna un rol a cada usuario y cada rol es un conjunto de capacidades.
La capacidad que permite publicar es `publish_posts` y la que permite subir
ficheros es `upload_files`. El rol Colaborador solo tiene `read`, `edit_posts`
y `delete_posts`, por eso no puede publicar ni subir imágenes.

| Usuario | Rol | Puede | No puede | Comprobado |
|---|---|---|---|---|
| admin | Administrador | Todo: ajustes, plugins, temas, usuarios | - | COMPLETAR |
| coord.web | Editor | Publicar y editar entradas y páginas de cualquiera, moderar comentarios | Ver Plugins ni Ajustes en el menú | COMPLETAR |
| profe.redes | Autor | Escribir, publicar y borrar sus entradas, subir imágenes | Editar entradas de otros | COMPLETAR |
| alumna.fct | Colaborador | Escribir entradas y enviarlas a revisión | Publicar ni subir imágenes (botón "Enviar para revisión") | COMPLETAR |
| familia.garcia | Suscriptor | Ver y editar su perfil | Escribir contenido | COMPLETAR |
| revisor.fp | Revisor (rol propio, clon de Editor) | Revisar y publicar lo de otros | Borrar nada (sin capacidades delete_*, sin Papelera) | COMPLETAR |

### Rol a medida: Revisor
Creado con `./wp role create revisor "Revisor" --clone=editor` y quitándole 9
capacidades de borrado y `manage_categories` con `./wp cap remove`.

### Registro cerrado
- `users_can_register` = 0 (nadie puede registrarse solo)
- `default_role` = subscriber (si se abriera el registro, entraría sin privilegios)
Un registro abierto con rol Administrador permitiría a cualquiera crearse una
cuenta con control total.

## 2. Módulos (plugins)

| Requisito | Plugins comparados | Elegido | Motivo |
|---|---|---|---|
| R1. Formulario de contacto que guarde mensajes | Contact Form 7 + Flamingo / COMPLETAR (otro) | Contact Form 7 + Flamingo | COMPLETAR |
| R2. Aviso de cookies (LSSI y RGPD) | COMPLETAR 1 / COMPLETAR 2 | COMPLETAR | COMPLETAR |
| R3. Registro de actividad | Simple History / COMPLETAR (otro) | Simple History | COMPLETAR |

Criterios usados: instalaciones activas, última actualización, compatibilidad
con la versión de WordPress instalada, valoraciones y soporte.

### Datos de la comparación de cookies
COMPLETAR: pega aquí la tabla de `./wp plugin search cookie`.

### Configuración realizada
- R1: campo desplegable `ciclo` (ASIR | DAW | SMR), `skip_mail: on`, formulario
  en la página Contacto. Los mensajes aparecen en Flamingo.
- R2: COMPLETAR (idioma, botones Aceptar/Rechazar, enlace a política de cookies).
- R3: instalado con WP-CLI, registra accesos, fallos de login y cambios.

### Limpieza
Desactivados y eliminados Akismet y Hello Dolly: un plugin inactivo sigue siendo
código en disco y puede ser explotable si tiene una vulnerabilidad.
