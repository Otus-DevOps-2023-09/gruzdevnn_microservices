# gruzdevnn_microservices
gruzdevnn microservices repository
# Doker-3
Используем монго версии 4 для корректной работы
sudo docker pull mongo:4
sudo docker network create reddit
sudo docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:4
sudo docker run -d --network=reddit --network-alias=post gruzdevwertnn/post:1.0
sudo docker run -d --network=reddit --network-alias=comment gruzdevwertnn/comment:1.0
sudo docker run -d --network=reddit -p 9292:9292 gruzdevwertnn/ui:1.0
