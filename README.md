# ODOO BACKUP SCRIPT

`backup.sh` es un script que permite hacer respaldos de una instancia de odoo, especificamente un dump de su base de datos y filestore, ambos comprimidos cada uno en un archivo comprimido `tar` con el objetivo de tener la capacidad de restaurar esta instancia a partir de estos. El mismo script elimina los backups comprimidos viejos con fecha de creación de más de X días.

Nota: este script fue realizado como una solución practica y provisional, se deberían agregar posteriores validaciones para asegurar la integridad y el éxito del proceso, backup incremental del filestore, notificación via email, manejo de errores y la capacidad de guardar los respaldos en un servidor FTP remoto.

Se configura asignando distintas variables de shell presentes en el cuerpo del script:

```
DB_BK_DIR="$SCRIPT_DIR/db_backups"
FS_BK_DIR="$SCRIPT_DIR/fs_backups"

DB_NAME="mesquita-prod-18.0"
RETENTION_DAYS=14
FILESTORE_DIR="$HOME/produccion/mesquita-18.0/data/filestore/mesquita-prod-18.0"
```

La idea del script es que sea ejecutado vía cron, configurando su programación horaria (scheduling) utilizando el comando `crontab`. 

Ejemplo (one-liner): agregar el script a `crontab` para que se ejecute todos los días a las 23 horas:

(CUIDADO: se esta asumiendo que el script esta ubicado en `/home/odoo-backup-script/backup.sh`)

```
(crontab -l; echo "0 23 * * * /home/odoo-backup-script/backup.sh") | crontab -
```

## CHANGELOG

### 24/09/25

Creacion de repositorio publico en [https://github.com/mezka/odoo-backup-script](https://github.com/mezka/odoo-backup-script) para poder descargar via `git` con `ssh` (usando agent forwarding e.g. `ssh -A user@your-vps`) o `wget`.

Agregado backup del filestore.

Deja de utilizar paths absolutos y utiliza todos paths relativos que se basan de calcular la variable $SCRIPT_DIR al momento de la ejecución

### 22/08/25

OVH me permite contratar un backup general a nivel de disco de 7 dias, lo cual hice, que unicamente permite restaurar toda la imagen completa, lo cual considero insuficiente.

Este es un script basico para poder tener backups automaticos de la base de datos que se corre via crontab de usuario odoo todos los dias a las 23:00AM.

Se rotan los archivos comprimidos de los dumps comprimidos resultantes cada 30 días, obviamente esta solucion no es suficiente ya que no hay un backup del entorno de archivos/filestore de Odoo, es unicamente local, y los achivos no se generan en base a diferencias entre los dump, pero a idea es ir extendiendolo hacia una solucion mas adecuada.