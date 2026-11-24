# INFORME RA3 · Administración de gestores de contenidos

Nombre: Adrián Pascual
Fecha: 11/11/2026

## 1. Usuarios y perfiles

WordPress asigna un rol a cada usuario y cada rol es un conjunto de capacidades.
La capacidad que permite publicar es `publish_posts` y la que permite subir
ficheros es `upload_files`. El rol Colaborador solo tiene `read`, `edit_posts`
y `delete_posts`, por eso no puede publicar ni subir imágenes.

| Usuario | Rol | Puede | No puede | Comprobado |
|---|---|---|---|---|
| admin | Administrador | Todo: ajustes, plugins, temas, usuarios | - | Sí |
| coord.web | Editor | Publicar y editar entradas y páginas de cualquiera, moderar comentarios | Ver Plugins ni Ajustes en el menú | Sí |
| profe.redes | Autor | Escribir, publicar y borrar sus entradas, subir imágenes | Editar entradas de otros | Sí |
| alumna.fct | Colaborador | Escribir entradas y enviarlas a revisión | Publicar ni subir imágenes (el botón dice "Enviar para revisión") | Sí |
| familia.garcia | Suscriptor | Ver y editar su perfil | Escribir contenido | Sí |
| revisor.fp | Revisor (rol propio, clon de Editor) | Revisar y publicar lo de otros | Borrar nada (sin capacidades delete_*, sin enlace Papelera) | Sí |

### Rol a medida: Revisor
Creado con `./wp role create revisor "Revisor" --clone=editor`. Después se le
quitaron 9 capacidades (delete_posts, delete_others_posts, delete_published_posts,
delete_private_posts, delete_pages, delete_others_pages, delete_published_pages,
delete_private_pages y manage_categories) con `./wp cap remove`. La comprobación
con `./wp cap list revisor | grep delete` no devuelve nada.

### Registro cerrado
- `users_can_register` = 0: nadie puede registrarse solo.
- `default_role` = subscriber: si se abriera el registro, entraría sin privilegios.
Un registro abierto con rol Administrador permitiría a cualquiera crearse una
cuenta con control total, uno de los fallos de configuración más graves.

## 2. Módulos (plugins)

Criterios: instalaciones activas, fecha de última actualización (se desconfía
de más de un año sin tocar), valoración (sobre 100) y soporte. Datos obtenidos
con `./wp plugin search` el 11/11/2026.

### R1. Formulario de contacto que guarde los mensajes

| Plugin | Instalaciones | Valoración | Última actualización |
|---|---|---|---|
| Contact Form 7 (+ Flamingo) | 10.000.000 | 80 | 10/11/2026 |
| WPForms Lite | 5.000.000 | 96 | 05/11/2026 |

**Elegido: Contact Form 7 + Flamingo.** Es el más instalado y se actualiza a
diario. Flamingo guarda cada envío en la base de datos sin coste. Su valoración
es la más baja (80), pero es suficiente para el requisito. Aviso: no he
verificado si WPForms Lite guarda las entradas en su versión gratuita.

### R2. Aviso de cookies (LSSI y RGPD)

| Plugin | Instalaciones | Valoración | Última actualización |
|---|---|---|---|
| CookieYes (cookie-law-info) | 1.000.000 | 96 | 27/10/2026 |
| Complianz (complianz-gdpr) | 1.000.000 | 94 | 04/11/2026 |

**Elegido: CookieYes.** Mismas instalaciones que Complianz y mejor valoración
(96 frente a 94). Tiene un asistente más sencillo, está en español y permite
botones Aceptar y Rechazar con el mismo peso visual. Complianz es más completo
pero también más pesado de configurar.

### R3. Registro de actividad de los usuarios

| Plugin | Instalaciones | Valoración | Última actualización |
|---|---|---|---|
| Simple History | 300.000 | 98 | 17/10/2026 |
| WP Activity Log | 300.000 | 94 | 05/11/2026 |

**Elegido: Simple History.** Mismas instalaciones que su alternativa y mejor
valoración (98 frente a 94). Es más sencillo y suficiente para registrar accesos,
fallos de login y cambios de contenido.

### Configuración realizada
- R1: campo desplegable `ciclo` (ASIR | DAW | SMR) con `skip_mail: on`, formulario
  colocado en la página Contacto. Los mensajes llegan a Flamingo con el campo `ciclo`.
- R2: instalado desde el panel, idioma español, botones Aceptar y Rechazar con el
  mismo peso visual y enlace a la página "Política de cookies". El aviso aparece
  en ventana privada y no vuelve a salir tras aceptarlo.
- R3: instalado con WP-CLI. Registró el intento fallido de login de alumna.fct.

### Limpieza
Se desactivaron y eliminaron Akismet y Hello Dolly. Un plugin inactivo sigue
siendo código en disco y puede ser explotable si tiene una vulnerabilidad.
Plugins finales activos: contact-form-7, flamingo, simple-history y cookie-law-info.
