# Terraform LAMP Stack Challenge (KodeKloud)

This repository contains a Terraform configuration to deploy a **LAMP (Linux, Apache, MySQL, PHP) stack** using **Docker**. The challenge was part of KodeKloud's Terraform practice.

## Overview

The Terraform configuration does the following:

- Builds and deploys a **PHP + Apache HTTPD** container.
- Builds and deploys a **MariaDB** database container.
- Deploys **phpMyAdmin** for database management.
- Creates a **Docker network** for communication between services.
- Mounts persistent storage for the database.

## Architecture

```plaintext
+-----------------------+         +----------------------+
|   PHP + Apache       | <--->   |   MariaDB Database   |
|   (php-httpd)        |         |   (mariadb)          |
+-----------------------+         +----------------------+
         |
         |
         v
+----------------------------------+
|        phpMyAdmin (GUI)         |
|   (Database Management Tool)     |
+----------------------------------+
```

## Terraform Configuration

### **Docker Images**
```hcl
resource "docker_image" "php-httpd-image" {
  name = "php-httpd:challenge"
  build {
    path = "lamp_stack/php_httpd"
    label = {
      challenge = "second"
    }
  }
}

resource "docker_image" "mariadb-image" {
  name = "mariadb:challenge"
  build {
    path = "lamp_stack/custom_db"
    label = {
      challenge = "second"
    }
  }
}
```

### **Docker Volume**
```hcl
resource "docker_volume" "mariadb_volume" {
  name = "mariadb-volume"
}
```

### **Docker Network**
```hcl
resource "docker_network" "private_network" {
  name        = "my_network"
  driver      = "bridge"
  labels {
    label = "challenge"
    value = "second"
  }
  internal    = false
  attachable  = true
}
```

### **MariaDB Container**
```hcl
resource "docker_container" "mariadb" {
  name  = "db"
  image = "mariadb:challenge"
  hostname = "db"

  labels {
    label = "challenge"
    value = "second"
  }

  ports {
    internal = 3306
    external = 3306
    protocol = "tcp"
  }

  network_mode = docker_network.private_network.name

  env = [
    "MYSQL_ROOT_PASSWORD=",
    "MYSQL_DATABASE=",
  ]

  volumes {
    volume_name      = "mariadb-volume"
    container_path = "/var/lib/mysql"
  }
}
```

### **phpMyAdmin Container**
```hcl
resource "docker_container" "phpmyadmin" {
  name  = "db_dashboard"
  image = "phpmyadmin/phpmyadmin"
  hostname = "phpmyadmin"

  labels {
    label = "challenge"
    value = "second"
  }

  ports {
    internal = 80
    external = 8081
    protocol = "tcp"
  }

  network_mode = docker_network.private_network.name

  depends_on = [
    docker_container.mariadb
  ]

  links = [
    "mariadb:db"
  ]
}
```

### **PHP + Apache Container**
```hcl
resource "docker_container" "php_httpd" {
  name  = "webserver"
  image = "php-httpd:challenge"
  hostname = "php-httpd"

  labels {
    label = "challenge"
    value = "second"
  }

  ports {
    internal = 80
    external = 80
    ip = "0.0.0.0"
  }

  network_mode = docker_network.private_network.name

  volumes {
    host_path = "/root/code/terraform-challenges/challenge2/lamp_stack/website_content/"
    container_path = "/var/www/html"
  }
}
```

## Prerequisites

Ensure the following are installed:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Docker](https://www.docker.com/get-started)

## Usage

### 1. Clone the Repository
```sh
git clone https://github.com/yourusername/terraform-lamp-kodekloud.git
cd terraform-lamp-kodekloud
```

### 2. Initialize Terraform
```sh
terraform init
```

### 3. Apply Terraform Configuration
```sh
terraform apply -auto-approve
```

This will:
- Build the required Docker images.
- Create a Docker network.
- Deploy the PHP/Apache, MariaDB, and phpMyAdmin containers.

### 4. Access the Services
- **Web Server (PHP + Apache):** [http://localhost:80](http://localhost:80)
- **phpMyAdmin:** [http://localhost:8081](http://localhost:8081)

### 5. Destroy the Environment
To remove all resources:
```sh
terraform destroy -auto-approve
```

## Configuration

- The **MariaDB container** exposes port `3306`.
- The **PHP webserver container** exposes port `80`.
- The **phpMyAdmin container** runs on port `8081`.

## Issues & Troubleshooting

- If ports are already in use, update the `ports` section in `docker_container` definitions.
- Ensure Docker is running before applying Terraform.

## License

This project is licensed under the **MIT License**.

---

**Author:** [Saqib Akhter](https://github.com/SaqibAkhter99)
