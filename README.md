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
# Doker-4
Чтобы сменить базовое имя проекта, нужно использовать команду:
docker-compose -p "proj" up -d
# Monitoring-1
    Пункт 1 Запустили Prometheus из готового образа
    Пункт 2 Создали свой образ Prometheus
    Пункт 3 Запустили микросервисы с мониторингом
    Пункт 4 Добавили Exporters
Образы на DockerHub (https://hub.docker.com/u/gruzdevwertnn)
# Kubernetes-1

Установка ВМ ubuntu1804

yc compute instance create \
  --name worker \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=45,type=network-ssd \
  --memory 4 \
  --cores 4 \
  --ssh-key ~/.ssh/x.pub

yc compute instance create \
  --name master \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=45,type=network-ssd \
  --memory 4 \
  --cores 4 \
  --ssh-key ~/.ssh/x.pub

Получаем адреса

    worker address: 158.160.116.245
    master address: 158.160.127.58

Заходим на воркер

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/engineer
    ssh yc-user@158.160.116.245

Ставим докер 19.03

    sudo apt-get update
    sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install docker-ce=5:19.03.12~3-0~ubuntu-bionic docker-ce-cli=5:19.03.12~3-0~ubuntu-bionic containerd.io

Ставим кубер 1.19

    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -            
    sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" 
    sudo apt install kubectl=1.19.14-00 kubelet=1.19.14-00 kubeadm=1.19.14-00

Делаем то же самое на мастере

Инициализируем мастер где 158.160.127.58 - мастер

    sudo kubeadm init --apiserver-cert-extra-sans=158.160.127.58 --apiserver-advertise-address=0.0.0.0 --control-plane-endpoint=158.160.127.58 --pod-network-cidr=10.244.0.0/16

В результате получаем команду, которую выполняем на воркере

Then you can join any number of worker nodes by running the following on each as root:

    sudo kubeadm join 158.160.127.58:6443 --token lrm8su.4n7nhhunqrv6g2je \
    --discovery-token-ca-cert-hash sha256:1111111111111111111111111111111111111111111111111111111111111111

Выполняем команды на мастере

    mkdir $HOME/.kube/
    sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $USER $HOME/.kube/config

Теперь можно посмотреть ноды

    kubectl get nodes

Смотрим описание

    kubectl describe node fhmh0n0e7jmkeoojeubk 
    kubectl describe node fhmrd2jm0lloqod8n97d

Ставим калико (мастер нода)

    curl https://docs.projectcalico.org/archive/v3.15/manifests/calico.yaml -O


    vim calico.yaml

Листаем в почти в самый низ кнопкой PgDn (Page Down)

Раскомментируем и меняем строки

            - name: CALICO_IPV4POOL_CIDR
              value: "10.244.0.0/16"

Применяем

    kubectl apply -f calico.yaml

Проверяем 

    kubectl get nodes

Создаем на мастере файлы из задания
Пробуем запустить

    kubectl apply -f ui-deployment.yml
    kubectl apply -f  post-deployment.yml
    kubectl apply -f  comment-deployment.yml
    kubectl apply -f  mongo-deployment.yml

Проверяем

    kubectl get pods

# Kubernetes-3

Создаём кубернетис кластер на яндексе (1.15)
Создаём группу хостов на HDD (на SSD не создавалось)
Подключаемся:

    yc managed-kubernetes cluster get-credentials test-k8s --external --force

Проверяем:

    kubectl config current-context

Деплоим:

    kubectl apply -f ./reddit

Создаём ui-service.yml

    kubectl apply -f ui-service.yml -n dev

Качаем ингресс:

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

Запускаем:

    kubectl apply -f ui-ingress.yml -n dev
    kubectl get ingress.networking.k8s.io/ui

Записываем ip 158.160.150.30
Создаём сертификаты:

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=158.160.150.30"
    kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev
    kubectl describe secret ui-ingress -n dev

Добавляем файлы tls.key tls.crt в гит игнор
Отключаем http трафик
Создаём файлы политик и применяем их:

    kubectl apply -f mongo-network-policy.yml -n dev

Создаём файлы для хранилища
Создаём хранилище:

    yc compute disk create \
    --name k8s \
    --size 4 \
    --description "disk for k8s"

Записываем id: fhmd43iqp8m1p0gnrd8p
Запускаем:

    kubectl apply -f mongo-deployment.yml -n dev

# Kubernetes-4

Запускаем кубер на яндекс облаке 1.26 (на hdd) имя - test-k8s

Подключаемся

    yc managed-kubernetes cluster get-credentials test-k8s --external --force

Проверяем подключение

    kubectl config current-context

В результате должно быть test-k8s

Устанавливаем ингресс

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

Добавляем репозиторий Гитлаба и обновляем

    helm repo add gitlab https://charts.gitlab.io/
    helm repo update

Устанавливаем gitlab community edition, пока без сертификата

    helm upgrade --install gitlab gitlab/gitlab \
      --namespace gitlab --create-namespace \
      --timeout 600s \
      --set global.hosts.https=false \
      --set certmanager-issuer.email=example@nn.ru \
      --set global.kas.enabled=true \
      --set global.edition=ce \
      --set global.time_zone=Europe/Moscow \
      --set postgresql.image.tag=13.6.0

Ждём окончания установки, смотрим адрес ингресс

    kubectl get ingress -n gitlab

Обновляем, добавляем сертификат

    helm upgrade --install gitlab gitlab/gitlab \
      --namespace gitlab --create-namespace \
      --timeout 600s \
      --set global.hosts.externalIP=158.160.151.226 \
      --set global.hosts.domain=158.160.151.226.sslip.io \
      --set global.hosts.https=true \
      --set global.ingress.configureCertmanager=true \
      --set certmanager-issuer.email=myemail@mail.ru \
      --set global.kas.enabled=true \
      --set global.edition=ce \
      --set global.time_zone=Europe/Moscow \
      --set postgresql.image.tag=13.6.0

Ждём окончания установки и смотрим админский пароль

    kubectl get secret --namespace=gitlab gitlab-gitlab-initial-root-password -o json | jq '.data | map_values(@base64d)'

Заходим на https://gitlab.158.160.151.226.sslip.io   под root и пароль выше.


