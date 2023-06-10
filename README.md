# El dream

Vamos armar un boilerplate para configurar de forma generica terraform, docker, nginx, ECR, EC2 y activar un Despliegue continuo, en detalle:

- Vamos a tener una config de Terraform para levantar Infra de ECR y EC2 con EIP (Elastic IP)
- Dentro de la instancia de EC2 se va a instalar y configurar:
  - Nginx ( HTTP → HTTP\***\*S\*\*** )
  - Docker y docker-compose ( para levantar la API o el servicio web registrado en ECR )
  - certbot para generar certificados para el Nginx
- Se crea una configuracion de Github Action para el CI de las imagenes docker, y registrarlas en AWS ECR
- Correr script dentro de instancia EC2 para actualizar el docker-compose y poner a correr la nueva version del contenedor deployado en AWS ECR
- se puede crear un endpoint o un servicio en nginx que escuche alguna llamada y que esta ejecute el script de bash para volver a ejecutar docker-compose
- se puede levantar un crontab en el cual cada minuto compruebe si hay diferencias entre el ultimo hash corriendo y el ultimo hash en ECR. Si hay diferencias, entonces actualiza.
- crear un servicio HTTP, donde tenga endpoints para gestionar la imagen actual, ejemplo:

```jsx

/*
 * POST /
 **/

// actualiza la imagen de docker
{
	"totp": 102030,
	"action": "upgrade",
	"imageId": "2767693332e5" // optional, default is the latest
}

// actualiza la imagen de docker pa'tra
{
	"totp": 102030,
	"action": "docker compose rollback",
	"imageId": "04ff3864d734" // optional, default is the previus of latest
}

// reinicia docker compose
{
	"totp": 102030,
	"action": "docker compose restart"
}

// detiene docker compose
{
	"totp": 102030,
	"action": "docker compose stop"
}

// devuelve listado de imagenes
{
	"totp": 102030,
	"action": "docker images"
}

```

En caso de crear esta ultima opcion, deberia de configurarse algun hash aleatorio para el TOTP 👍

# El Paso a paso

- [ ] crear un servicio “gestor remoto de contenedor con TOTP”
  1. el servicio puede correr en cualquier puerto que no sea 443 o 80 ( configurable )
  2. se debe confiugrar un TOTP_SECRET en Github Secrets. Este mismo se va a usar para implementarse en este servicio de gestion remota de contenedores y en el CD
  3. el servicio solo ejecuta ciertas funciones basicas como: upgrade, rollback, restart y stop
- [ ] crear un script de bash para correr dentro de un AMI o Ubuntu e instalar y configurar:
  1. instalar nginx, certbot y docker
  2. ejecutar certbot
  3. configurar nginx
  4. descargar el gestor remoto de contenedor con TOTP
  5. asignar subdominio `manage.<dominio.com>` , ejemplo: `manage.api.palta.app`
- [ ] crear files para levantar infra con terraform:
  1. crear EC2
  2. levantar registro en ECR
  3. crear sg con permisos inbound en puertos 80, 443 y 22
  4. asignar EIP a EC2
  5. darle permisos a instancia EC2 para acceder a ECR
  6. dentro de EC2 correr script creado en el punto 1

En el boilerplate debe haber un lugar donde poder configurar ciertas variables a tener en cuenta como por ejemplo:

- nombre del servicio
- dominio del servicio

_Notas o links de ref:_

https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/

https://www.nginx.com/resources/wiki/start/topics/examples/full/
