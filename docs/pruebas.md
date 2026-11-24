# Pruebas de funcionamiento y rendimiento

Fecha: 23/11/2026 · Entorno: VM Ubuntu (VirtualBox) · IP de la VM: 10.0.2.15

| Prueba | Resultado | ¿Correcto? |
|---|---|---|
| Servicios en marcha | docker compose ps: nginx, wordpress y db en estado Up (wpcli no aparece: solo existe mientras ejecuta un comando) | Sí |
| Sitio y panel | / carga el sitio y /wp-admin/ permite entrar como adrian (tras corregir absolute_redirect en nginx) | Sí |
| Subida de ficheros | Captura PNG de 2,6 MB subida desde Medios sin error (supera el límite de 2 MB de PHP por defecto: uploads.ini funciona); sigue accesible tras down/up | Sí |
| Enlaces permanentes | curl a /entrada-de-prueba/ devuelve HTTP 200, no 404 | Sí |
| Persistencia (down/up) | docker compose down y up -d sin -v: siguen las entradas 16, 4 y 1 | Sí |
| Seguridad (403) | curl -I /xmlrpc.php devuelve 403 Forbidden | Sí |

## Rendimiento

- Tiempos de respuesta en el aula (5 medidas): 0,098 s · 0,052 s · 0,048 s · 0,053 s · 0,050 s
- Memoria por contenedor (docker stats --no-stream):

| Contenedor | Memoria | CPU |
|---|---|---|
| nginx | 3,84 MiB | 0,00 % |
| wordpress | 81,9 MiB | 0,01 % |
| db | 97,98 MiB | 0,02 % |

- Interpretación: la primera petición tarda casi el doble que las siguientes
  porque PHP-FPM compila los scripts y MariaDB lee de disco (cachés en frío).
  Después todo queda en memoria y los tiempos se estabilizan en torno a 50 ms.
  nginx consume muy poco porque solo sirve ficheros y reenvía el PHP; MariaDB y
  PHP-FPM concentran la memoria. Los tres suman unos 184 MiB de 1,9 GiB.
  Es una VM con un solo usuario: con carga concurrente los valores cambiarían.

## Publicación

- Dirección desde la que accedió mi compañero/a: PENDIENTE (http://10.0.2.15:8080)
- Dirección pública en Codespaces (paso 4, opcional): no realizado
- Tiempos desde Codespaces y comparación con el aula: no realizado

## Incidencias resueltas

- Error `SSL_ERROR_RX_RECORD_TOO_LONG`: el navegador forzaba https sobre un
  nginx que solo habla http. Se solucionó escribiendo http:// a mano.
- `/wp-admin` redirigía a http://localhost/wp-admin/ (sin el puerto 8080):
  se corrigió con `absolute_redirect off;` en nginx/default.conf.
- La base de datos estaba vacía: se instaló WordPress con `wp core install`.
