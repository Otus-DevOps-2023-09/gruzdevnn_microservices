variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable "image_id" {
  description = "Disk image"
}
variable "subnet_id" {
  description = "Subnet"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable "privat_key_path" {
  # Описание переменной
  description = "Path to the privat key used for connection section"
}
variable "zone_app" {
  description = "Zone in yandex compute instance"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "kub_disk_image" {
  description = "Disk image for reddit app"
  default     = "kubernetes-base"
}

