# LB3_M300
## Inhaltsverzeichnis
- [LB3_M300](#LB3M300)
  - [Inhaltsverzeichnis](#Inhaltsverzeichnis)
  - [Container](#Container)
  - [Docker](#Docker)
    - [Befehle](#Befehle)
  - [Microservices](#Microservices)
  - [Sicherheitsaspekte](#Sicherheitsaspekte)
  - [Aufbau](#Aufbau)
  - [Testing](#Testing)
  - [Reflexion](#Reflexion)
  
## Container
Ein Container ist eine Standard-Softwareeinheit, die Code und alle Abhängigkeiten zusammenfasst, sodass die Anwendung schnell und zuverlässig von einer Computerumgebung zur anderen ausgeführt werden kann. Ein Docker-Container-Image ist ein kompaktes, eigenständiges, ausführbares Softwarepaket, das alles enthält, was zum Ausführen einer Anwendung erforderlich ist: Code, Laufzeit, Systemtools, Systembibliotheken und Einstellungen.

## Docker
Docker handelt es sich um eine Open-Source-Software, mit der sich Anwendungen ähnlich wie bei einer Betriebssystemvirtualisierung in Containern isolieren lassen.

Docker-Container, die mit Docker Engine ausgeführt werden:
- **Standard**: Docker hat den Industriestandard für Container geschaffen, damit diese überall hin transportiert werden können
- **Lightweight**: Container nutzen den Betriebssystemkern des Computers gemeinsam und erfordern daher kein Betriebssystem pro Anwendung, wodurch die Servereffizienz gesteigert und die Server- und Lizenzkosten gesenkt werden
- **Secure**: Applikation sind sicherer in Containers und Docker stellt die stärksten Standardisolationsfunktionen in der Branche dar. 

### Befehle
|Befehl | Erklärung |
|---|---|
|docker run|Mit diesem Befehl kann ein Container gestartet werden|
|docker exec|Mit diesem Befehl kann man auf ein Container zugegreifen. Sozusagen das SSH um auf die Container zu gelangen. Bei dem Zugriff muss zwingen ein Commandline Interpreter mitgegeben werden. Z. B. docker exec -it seafile bash|
|docker ps|Dieser Befehl listet alle laufende Container auf|
|docker stop|Mit diesem Befehl werden Container gestoppt Hierfür muss entweder die ID des Containers verwendet werden oder der Name|
|docker-compose up|Dieser Befehl startet eine Docker-compose Umgebung|
|docker-compose down|Dieser Befehl stoppt eine Docker-compose Umgebung|


## Microservices
![Microservices](images/Screenshot_1.jpg)

Unter Microservices versteht man Dienste, die jeweils eine kleine Aufgabe erfüllen. Die Prozesse lassen sich wie Module so miteinander verbinden, dass sich daraus eine beliebig komplexe Software ergibt. 

Microservices ermöglichen es, komplexe Anwendungen mit Hilfe einer Architektur bestehend aus vielen kleinen voneinander entkoppelten Diensten und Prozessen zu realisieren. Die Microservices kommunizieren über Schnittstellen und stellen der Applikation jeweils einzelne Funktionen und Dienste zur Verfügung. Selbst komplexe Anwendungssoftware kann auf Basis von Microservices modular entwickelt und umgesetzt werden.

## Sicherheitsaspekte


## Aufbau
In einem Ordner ein Dockerfile erstellen und folgendes eingetragen:

    FROM php:7.1-apache

    RUN docker-php-ext-install mysqli


Als nächstes ein Compose File erstellen:

    version: '3.3'

    services:

    # Hier werden Webserver und php Config definiert
    php:
        build: php
        ports:
        - "80:80"
        - "443:443"
        restart: on-failure
    # Hier wird angegeben, wo das Indexfile für den Webserver ist. Angabe der Volumes wird das Index-File fortlaufend synchronisiert.
        volumes:
        - ./php/www:/var/www/html
        cpus: 0.5
        mem_limit: 512m

    # Hier wird der grafische Zugang zum MySQL Server konfiguriert.
    phpmyadmin:
        image: phpmyadmin/phpmyadmin
        links:
            - db:db
    # Hier wird angegeben, dass phpmyadmin über Port 8080 lauft, weil nicht zwei Services auf den gleichen Port laufen können.
        ports:
            - 8080:80
        restart: on-failure
    # Hier wird das Passwort für den Root-User auf phpmyadmin gesetzt.
        environment:
            MYSQL_ROOT_PASSWORD: test123
        cpus: 1
        mem_limit: 1024m

    # Hier wird die MySQL Datenbank erstellt.
    db:
        image: mysql:5.7
        ports:
        - "3306:3306"
        volumes:
        - /var/lib/mysql
        restart: on-failure
    # Hier wird das Passwort für den Root-Zugang definiert.
        environment:
        - MYSQL_ROOT_PASSWORD=test123
        - MYSQL_DATABASE=database
        cpus: 1
        mem_limit: 1024m
        db_owncloud:
    container_name: database_owncloud
    image: mysql:5.7
    volumes:
    - ./db_data_owncloud:/var/lib/mysql
    restart: on-failure
    environment:
    MYSQL_ROOT_PASSWORD: someowncloud
    MYSQL_DATABASE: owncloud
    MYSQL_USER: owncloud
    MYSQL_PASSWORD: owncloud
    networks:
    - internal
    labels:
    - "traefik.enable=false"
    ports:
    - "3307:3306"
    deploy:
    resources:
        limits:
        cpus: "0.5"
        memory: 512M
    
    db_owncloud:
    container_name: database_owncloud
    image: mysql:5.7
    volumes:
    - ./db_data_owncloud:/var/lib/mysql
    restart: on-failure
    environment:
    MYSQL_ROOT_PASSWORD: someowncloud
    MYSQL_DATABASE: owncloud
    MYSQL_USER: owncloud
    MYSQL_PASSWORD: owncloud
    networks:
    - internal
    labels:
    - "traefik.enable=false"
    ports:
    - "3307:3306"
    deploy:
    resources:
        limits:
        cpus: "0.5"
        memory: 512M

    owncloud:
    depends_on:
    - db_owncloud
    container_name: owncloud
    image: owncloud:10.0
    restart: always
    labels:
    - "traefik.backend=owncloud"
    - "traefik.enable=true"
    - "traefik.frontend.rule=Host:owncloud.abc.ch"
    - "traefk.port=8000"
    - "traefik.docker.network=proxy"
    networks:
    - internal
    - proxy

    cadvisor:
    image: google/cadvisor:latest
    volumes:
        - "/:/rootfs:ro"
        - "/var/run:/var/run:rw"
        - "/sys:/sys:ro"
        - "/var/lib/docker/:/var/lib/docker:ro"
    publish:
    - "8081:8081"
    container_name: cadvisor

    volumes:
    db_data: {}

    networks:
    proxy:
    external: true
    internal:
    external: false
    
    wordpress_db:
    db_wordpress:
    container_name: database_wordpress
    image: mysql:5.7
    volumes:
    - ./db_data_wordpress:/var/lib/mysql
    restart: on-failure
    environment:
    MYSQL_ROOT_PASSWORD: somewordpress
    MYSQL_DATABASE: wordpress
    MYSQL_USER: wordpress
    MYSQL_PASSWORD: wordpress
    networks:
    - internal
    labels:
    - "traefik.enable=false"
    ports:
    - "3306:3306"
    deploy:
    resources:
        limits:
        cpus: "0.5"
        memory: 512M

    
    wordpress:
    container_name: wordpress
    depends_on: db_wordpress
    - db_wp
    image: wordpress:5.2
    restart: on-failure
    environment:
    WORDPRESS_DB_HOST: db_wp:3306
    WORDPRESS_DB_USER: wordpress
    WORDPRESS_DB_PASSWORD: wordpress
    WORDPRESS_DB_NAME: wordpress
    labels:
    - "traefik.backend=wordpress"
    - "traefik.enable=true"
    - "traefik.frontend.rule=Host:wordpress.test.ch"
    - "traefik.port=80"
    - "traefik.docker.network=proxy"
    networks:
    - internal
    - proxy 
    deploy:
    resources:
        limits:
        cpus: "0.5"
        memory: 512M

    reverse-proxy:
    container_name: reverse-proxy01
    restart: on-failure
    image: traefik:1.7
    command: --api
    ports:
    - "80:80"
    - "8080:8080"
    - "8000:8000"
    - "443:443"
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - ./traefik:/etc/traefik
    - ./traefik/Certs:/vagrant/M300-Services/LB3/Dockerconfig/traefik/Certs
    networks:
    - proxy
    deploy:
    resources:
        limits:
        cpus: "0.5"
        memory: 512M   
    
    cadvisor:
    image: google/cadvisor:latest
    restart: on-failure
    volumes:
    - "/:/rootfs:ro"
    - "/var/run:/var/run:rw"
    - "/sys:/sys:ro"
    - "/var/lib/docker/:/var/lib/docker:ro"
    ports:
    - "8081:8080"
    container_name: cadvisor
    networks:
    - internal
    labels:
    - "traefik.enable=false"
    deploy:
    resources:
        limits:
        cpus: "0.5"
        memory: 512M

    active-notification:
    container_name: active-notification
    restart: on-failure
    image: quaide/dem:latest
    volumes:
    - "/var/run/docker.sock:/var/run/docker.sock"
    - "./active-notification/conf.yml:/app/conf.yml"
    networks:
    - internal
    labels:
    - "traefik.enable=false"
    deploy:
    resources:
        limits:
        cpus: "0.5"
        memory: 512M

## Testing
Das Testing wir mit einem Testing Protokoll durchgeführt. Dabei wird er SOLL / IST Zustand Verglichen und erläutert wie getestet wurde.

| SOLL-Zustand | IST-Zustand	| Test |
|---|---|--|
|3 Container wurden per Befehl installiert|Die 3 Container wurden erstellt und werden ausgeführt|In Powershell wurde der Befehl "docker-compose -f "C:\myrep\my_M300\Docker\LB2\docker-compose.yml" up -d --build" ausgeführt|
|Das Netzwerk "Net1" wurde erstellt|Das Netzwerk wurde während dem Ausführen des Befehls erstellt|Mit dem Befehl: Docker Network ls werden alle Docker Netzwerke angezeigt|
|Die Portverlinkung von PHPMyAdmin von Port 80 auf 8080 ist gewährleistet|Mit http://localhost:8080 kann auf das Webinterface von PHPMyAdmin zugegriffen werden|Im Browser die Adresse http://localhost:8080 öffnen|
|Mit dem Gesetzten User Login kann man sich anmelden|Mit dem Benutzername User und Passwort 1234 kann eingelogt werden|In der Anmeldemaske von PHPMyAdmin werden die Login Daten eingegeben|
|Die Portverlinkung von Wordpress von Port 80 auf 8081 ist gewährleistet|Mit http://localhost:8081 kann auf Wordpress zugegriffen werden|Im Browser die Adresse http://localhost:8081 öffnen|

## Reflexion
Docker ist nicht so ein einfaches Tool und es braucht seine Zeit bis um es zu verstehen. Ich jedenfalls brauchte sehr lange und auch bis jetzt verstehe ich es nicht so richtig. Trotzdem hat es mir sehr viel spass gemacht damit herumzuspielen und zu testen. Es gab natürlich _Ups and Downs_, aber schlussendlich hab ich ein wenig mehr dazu gelernt.