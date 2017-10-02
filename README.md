# DenyTor
[Security] Application with PowerShell able to isolate Windows servers from DeepWeb, a solution that makes our servers inaccessible from ToR.
╔═════════════════════════════════════════════════════════════════════════════════╗
║                          DENYTOR - INFORMACIÓN Y AYUDA                          ║
╠═════════════════════════════════════════════════════════════════════════════════╣
║ DenyTOR es una herramienta ideada y desarrollada por Dani Alonso                ║
║ Microsoft MVP, Experto en soluciones cloud, seguridad telemática empresarial y  ║
║ perito judicial informático forense.                                            ║
║                                                                                 ║
║ Website: https://blogs.itpro.es/DaniAlonso     Twitter: @_DaniAlonso            ║
╠═════════════════════════════════════════════════════════════════════════════════╣
║ Esta herramienta establece conexión con un servicio alojado en Microsoft        ║
║ Azure, que monitorizan en tiempo real la arquitectura de la red TOR. En el      ║
║ análisis identifica todos los nodos de salida generándo una lista completa,     ║
║ la cual este script se encargará de importarla y procesarla desatendidamente.   ║
║                                                                                 ║
║ Una vez obtenida la lista de los nodos de la red TOR, el script creará reglas   ║
║ de entrada y salida en el firewall de Windows según nuestras necesidades.       ║
║ Podremos establecer la protección de nuestro servidor cuando se conecte a una   ║
║ red inalámbrica [3], pública [2], o en todas las redes [1]. Para una mayor      ║
║ protección, se recomienda la opción [1]. Puedes cambiar de opción en cualquier  ║
║ momento.                                                                        ║
║                                                                                 ║
║ Para observar los resultados, puedes abrir la herramienta 'Firewall de Windows  ║
║ con seguridad avanzada', y ver las reglas de entrada y salida.                  ║
║ Ahí encontrarás las reglas DenyTOR-#00x, que albergan una serie de direcciones  ║
║ IP remotas correspondientes a los nodos de salida TOR.                          ║
║                                                                                 ║
║ No edites manualmente las reglas DenyTOR desde el Firewall de Windows. Se       ║
║ sobreescribirán cuando ejecutes nuevamente otra opción en DenyTOR.              ║
║                                                                                 ║
║ La opción [4] deshabilitará la protección TOR eliminando todas estas reglas.    ║
╠═════════════════════════════════════════════════════════════════════════════════╣
║ Pulsa 'ENTER' para salir de la ayuda.                                           ║
╚═════════════════════════════════════════════════════════════════════════════════╝
