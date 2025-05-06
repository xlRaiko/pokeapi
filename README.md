*// Resumen general de la API //*

El proyecto es un juego interactivo de consola inspirado en Pokémon, donde los usuarios pueden:

* Registrarse y realizar un test de personalidad para recibir un Pokémon inicial.
* Iniciar sesión para acceder al juego.
* Gestionar un inventario de Pokémon (máximo 6 en el equipo, el resto en la caja).
* Explorar rutas para encontrar y capturar Pokémon salvajes.
* Combatir Pokémon salvajes usando movimientos con daño calculado según tipos y estadísticas.
* Ganar experiencia para subir de nivel.
* Liberar Pokémon o consultar sus tipos y fortalezas.
* Usar comandos para acciones rápidas como obtener Pokémon, añadir experiencia, etc.

*// Sistema de experiencia en el juego //*

* Un total de 10 niveles equivalente a 100 exp por nivel para aumentarlo.
* Obtención de 5 exp por captura de pokemon.
* Obtencion de 3 exp por pokemon debilitado.

*// Rutas del juego //*

Por cada nivel que obtenga el usuario, le permitirá el acceso a nuevas rutas dentro de la API para encontrarse con nuevos pokemons.
Los pokemons de cada ruta no son aleatorios, están colocados de manera manual.

El listado de rutas disponibles son:

* ⛺ Pradera soleada (Default -> Nivel 1).
* 🌳 Bosque frondoso (Nivel 2).
* 🗻 Monte Rocoso (Nivel 3).
* 🌋 Volcán del desierto (Nivel 4).
* 🏭 Central eléctrica abandonada (Nivel 5).
* 🛕 Ruinas antiguas (Nivel 6).
* 🌊 Mar tranquilo (Nivel 7).
* 🕌 Templo del valle (Nivel 8).
* 🏡 Guardería (Nivel 9).
* 🕋 Dimensión extraña (Nivel 10).

*// Funciones de la API //*

* Dart como lenguaje principal.
* MySQL para almacenar usuarios, Pokémon, rutas y configuraciones.
* PokeAPI para datos de Pokémon (estadísticas, tipos, movimientos, habilidades).
* Interfaz de consola con menús interactivos y comandos.

*// Menú de comandos ocultos para Debug //*

Existe un menú cuando un usuario está registrado oculto para comandos, permitiendo forzar opciones dentro de la API, para acceder a datos de la misma. Se puede acceder desde el primer menú del juego tras logearse utilizando la opción 6 (oculta). Te abrirá un panel de información sobre comandos.

Las funciones disponibles en el menú de comandos Debug son:

* :obtener [id] → Obtiene información del Pokémon con el ID especificado.
* :verinventario → Muestra tu inventario de Pokémon.
* :capturar [id] → Intenta capturar un Pokémon salvaje.
* :liberar [id] → Libera un Pokémon de tu equipo.
* :exp [cantidad] → Otorga experiencia al usuario.
* :dexp [cantidad] → Retira experiencia al usuario.