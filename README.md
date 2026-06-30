**🇪🇸 Español** | [🇬🇧 English](README.en.md)

# Voto automático para el servidor Solsticio de Project Zomboid

Esta pequeña herramienta vota por nuestro servidor **Solsticio** en
top-games.net **por ti, automáticamente, cada 2 horas** — así nunca se te
olvida y el servidor sube en el ranking. Pones tu nombre una vez y te olvidas.

La página de voto tiene una verificación "Verify you are human" (Cloudflare
Turnstile) que normalmente bloquea a los robots. Esta herramienta la pasa de
forma honesta — usando una ventana real de Chrome — así que tu voto cuenta
igual que si hicieras clic a mano.

---

## Cómo configurarlo (unos 5 minutos, sin programar)

### Paso 1 — Instala Python (una sola vez)
- Entra en **https://www.python.org/downloads/** y pulsa el botón grande
  **Download**.
- Ejecuta el instalador. **MUY IMPORTANTE:** en la primera pantalla marca la
  casilla **“Add Python to PATH”** y luego pulsa **Install Now**.

### Paso 2 — Descarga esta herramienta
- Arriba en esta página pulsa el botón verde **`< > Code`** → **Download ZIP**.
- **Clic derecho en el ZIP → Extraer todo.** Pon la carpeta en un sitio fijo,
  por ejemplo en Documentos.

### Paso 3 — Instálala (y elige tu idioma)
- Haz doble clic en **`1-INSTALL.bat`**.
- Primero te pregunta **[S] Español / [E] English** — pulsa tu opción. A partir
  de ahí todas las ventanas estarán en tu idioma.
- Instala todo y dice *Listo*. Ciérrala.
- (Si Windows muestra un recuadro azul de "protegió tu PC", pulsa **Más
  información → Ejecutar de todas formas**.)

### Paso 4 — Pon tu nombre
- Abre **`username.txt`** (doble clic → se abre en el Bloc de notas).
- Reemplaza `YOUR_USERNAME_HERE` por **tu nombre de usuario de top-games** y
  **guarda** (Ctrl+S).

### Paso 5 — Pruébalo una vez
- Haz doble clic en **`2-TEST-vote-now.bat`**.
- Se abre una ventana de Chrome unos segundos y vota. Cuando diga
  **“Voto CONFIRMADO”**, ¡funciona! 🎉
  *(Si dice “En enfriamiento”, ya votaste en las últimas 2 horas — es normal,
  intenta más tarde.)*

### Paso 6 — Activa el voto automático
- Haz doble clic en **`3-SCHEDULE-every-2h.bat`**.
- Si puedes votar, **vota al instante**; si estás en enfriamiento, programa el
  **primer voto para justo cuando termine**. Luego vota solo cada ~2 horas.
- (Abre Chrome unos segundos para hacerlo — es normal.)

Para desactivarlo más adelante, haz doble clic en **`4-STOP-scheduling.bat`**.

---

## Botones (para el día a día)

| Botón | Qué hace |
|---|---|
| **`2-TEST-vote-now.bat`** | Vota **ahora mismo**. Dice *VOTO CONFIRMADO* (y reinicia el reloj a ~2h2m) o *EN ENFRIAMIENTO* con el enlace para ver cuánto falta. |
| **`PAUSE.bat`** | Pausa el voto automático (sin borrarlo). |
| **`RESUME.bat`** | Reanuda el voto automático y muestra la próxima vez. |
| **`STATUS.bat`** | Muestra si está activo, la última/próxima vez y el registro. |
| **`4-STOP-scheduling.bat`** | Quita por completo el voto automático. |

> ¿Pausar o detener? **`PAUSE`** lo apaga un rato y **`RESUME`** lo vuelve a
> encender. **`4-STOP`** lo borra del todo (tendrías que usar `3-SCHEDULE` otra
> vez). Hay un resumen rápido en **`BUTTONS.txt`**.

---

## Cómo funciona el horario

Top-Games permite un voto por persona aproximadamente **cada 2 horas**. La
herramienta lo gestiona sola:

- Al ejecutar **`3-SCHEDULE-every-2h.bat`**, **vota enseguida si puedes**. Si aún
  estás dentro de la espera de 2 horas, lee *exactamente* cuánto falta y programa
  el **primer voto para el momento en que termine** (+90 segundos de margen).
- Después vota solo **cada ~2 horas** (2h más 90 segundos de margen, para no caer
  un pelín antes de tiempo y perder un ciclo).
- **Nunca vota dos veces**: si una ejecución cae mientras todavía esperas,
  simplemente no hace nada y la siguiente lo recupera.
- ¿Quieres votar *ahora mismo*? Usa **`2-TEST-vote-now.bat`** — vota al instante
  y reajusta el siguiente voto automático a ~2 horas después.
- Ejecuta **`STATUS.bat`** cuando quieras para ver el último voto, el próximo y
  el registro.

---

## Ten en cuenta
- **Deja el PC encendido y con la sesión iniciada.** El voto necesita una
  ventana real, así que una pequeña ventana de Chrome aparecerá unos segundos
  cada 2 horas — es normal, ignórala.
- **Mantén cualquier VPN APAGADA.** Votar con VPN hace que falle la
  verificación.

## ¿Algo salió mal?
- **Dice que no encuentra Python** → te saltaste la casilla “Add Python to PATH”
  en el Paso 1. Vuelve a ejecutar el instalador de Python (Modify) y márcala.
- **La prueba dice exit code 2** → asegúrate de que la VPN está apagada y prueba
  de nuevo un poco más tarde.
- Todo lo que pasa se guarda en **`vote.log`** — ábrelo para ver el historial.

---

## ¿Necesitas ayuda?

Si no funciona, con gusto te ayudamos:

- **Abre un issue** (pestaña **Issues** arriba en esta página → **New issue**)
  y **adjunta tu archivo `vote.log`**. Nos dice exactamente qué falló.
  *(El log solo contiene fechas y mensajes de estado — sin contraseñas ni datos
  personales.)*
- **O escríbeme por Discord:** **`michaelizer1`**.

## ⭐ ¿Te gustó?

Si te sirvió, ¡dale una estrella! Pulsa el botón **Star** ⭐ arriba a la derecha
de esta página. Es gratis, no cuesta nada y nos ayuda un montón. 🙌

---

*Solo para jugadores del servidor. Simplemente hace el mismo voto de una vez
cada 2 horas que podrías hacer a mano, con un temporizador. Licencia MIT.*
