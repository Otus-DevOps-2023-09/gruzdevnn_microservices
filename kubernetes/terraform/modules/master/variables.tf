variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable kub_disk_image {
  description = "Disk image for kubernetes master"
  default = "kubernetes-base"
}
variable subnet_id {
  description = "Subnets for modules"
}
