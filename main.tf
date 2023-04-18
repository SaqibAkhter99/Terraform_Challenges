resource "docker_image" "php-httpd-image" {
  name = "php-httpd:challenge"
  build {
    path = "lamp_stack/php_httpd"
    label = {
      challenge : "second"
   }
  }
}
resource "docker_image" "mariadb-image" {
  name = "mariadb:challenge"
  build {
    path = "lamp_stack/custom_db"
    label = {
      challenge : "second"
   }
  }
}

resource "docker_volume" "mariadb_volume"{
  name = "mariadb-volume"
}


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
    "MYSQL_ROOT_PASSWORD = ",
    "MYSQL_DATABASE = ",
  ]

  volumes {
    volume_name      = "mariadb-volume"
    container_path = "/var/lib/mysql"
  }
}

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
    ip = " 0.0.0.0"
  }

  network_mode = docker_network.private_network.name

  volumes {
    host_path = "/root/code/terraform-challenges/challenge2/lamp_stack/website_content/"
    container_path = "/var/www/html"
  }
}