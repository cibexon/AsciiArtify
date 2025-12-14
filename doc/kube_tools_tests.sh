#!/bin/bash

echo "=== Демонстрація K3d для AsciiArtify ==="
sleep 1
echo "Дата: $(date)"
sleep 0.5
echo "Архітектура: $(uname -m)"
sleep 0.5
echo "CPU: $(nproc) ядер"
sleep 0.5
echo "Пам'ять: $(free -h | grep Mem | awk '{print $2}')"
sleep 1
echo ""

# Кольори
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Функції для виводу
print_step() {
    echo -e "${BLUE}▸${NC} $1"
    sleep 0.8
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
    sleep 0.5
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    sleep 0.8
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    sleep 0.5
}

print_header() {
    echo ""
    echo -e "${MAGENTA}══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════${NC}"
    sleep 1
}

# Функція для очікування готовності подів
wait_for_pods() {
    local selector=$1
    local namespace=${2:-default}
    local timeout=180

    print_info "Чекаємо готовності подів з селектором: $selector"

    local start_time=$(date +%s)

    # Спрощений перегляд статусу
    echo -ne "${YELLOW}⏳${NC} Очікування..."

    # Чекаємо до 180 секунд
    if kubectl wait --for=condition=ready --timeout=${timeout}s pod -n "$namespace" -l "$selector" >/dev/null 2>&1; then
        local elapsed=$(( $(date +%s) - start_time ))
        echo -e "\r${GREEN}✅${NC} Всі поди готові за ${elapsed} секунд"
        kubectl get pods -n $namespace -l "$selector"
        return 0
    else
        echo -e "\r${RED}✗${NC} Не всі поди готові за ${timeout} секунд"
        kubectl get pods -n $namespace -l "$selector"
        return 1
    fi
}

# Функція для тестування доступу до додатку
test_application_access() {
    local namespace=${1:-default}

    print_step "Тестування доступу до додатку"

    # Знаходимо под, який уже запущений
    local pod_name=""
    for i in {1..10}; do
        pod_name=$(kubectl get pods -n $namespace -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
        if [ -n "$pod_name" ]; then
            local pod_status=$(kubectl get pod -n $namespace $pod_name -o jsonpath='{.status.phase}' 2>/dev/null)
            if [ "$pod_status" = "Running" ]; then
                print_success "Знайдено запущений под: $pod_name"
                break
            fi
        fi
        sleep 2
    done

    if [ -z "$pod_name" ]; then
        print_warning "Не знайдено запущених подів"
        kubectl get pods -n $namespace
        return 1
    fi

    # Запускаємо port-forward
    print_info "Запуск port-forward до поду $pod_name"
    kubectl port-forward -n $namespace pod/$pod_name 8888:80 > /dev/null 2>&1 &
    local PF_PID=$!

    # Чекаємо, поки port-forward запуститься
    print_info "Чекаємо запуск port-forward..."
    sleep 8

    # Тестуємо через curl
    print_info "Виконуємо HTTP запит..."

    local success=false
    for attempt in {1..6}; do
        echo -e "${YELLOW}  Спроба ${attempt}/6...${NC}"
        if curl -s -f --max-time 10 http://localhost:8888 > /dev/null 2>&1; then
            success=true
            print_success "HTTP запит успішний!"
            break
        else
            print_warning "Запит невдалий, чекаємо..."
            sleep 5
        fi
    done

    if [ "$success" = true ]; then
        print_step "Отримуємо вміст сторінки..."

        local response=$(curl -s --max-time 10 http://localhost:8888)

        echo -e "${GREEN}📊 Аналіз відповіді:${NC}"
        sleep 0.5

        if echo "$response" | grep -qi "nginx"; then
            echo -e "${GREEN}  ✓ Містить 'nginx'${NC}"
        fi

        if echo "$response" | grep -qi "welcome"; then
            echo -e "${GREEN}  ✓ Стандартна сторінка Welcome${NC}"
        fi

        echo -e "${GREEN}📄 Початок вмісту (120 символів):${NC}"
        echo "$response" | head -c 120
        echo -e "\n${YELLOW}  ...${NC}"

        # Додатково перевіряємо через LoadBalancer
        print_step "Додаткове тестування через LoadBalancer..."
        print_info "Доступ через: http://localhost:8080"

        for i in {1..5}; do
            echo -e "${YELLOW}  Спроба $i...${NC}"
            if curl -s -f --max-time 5 http://localhost:8080 > /dev/null 2>&1; then
                print_success "LoadBalancer також працює!"
                break
            fi
            sleep 3
        done

    else
        print_warning "Не вдалося отримати доступ до додатку"

        # Перевіряємо логи
        print_info "Перевірка логів поду:"
        kubectl logs -n $namespace $pod_name --tail=15 2>/dev/null || echo "Не вдалося отримати логи"

        # Перевіряємо опис поду
        print_info "Останні події поду:"
        kubectl describe pod -n $namespace $pod_name | tail -10
    fi

    # Зупиняємо port-forward
    print_info "Зупинка port-forward..."
    kill $PF_PID 2>/dev/null || true
    sleep 2

    echo ""
}

# Основна демонстрація
main_demo() {
    print_header "ДЕМОНСТРАЦІЯ K3d ДЛЯ ASCIIARTIFY"

    # Частина 1: Запуск кластера
    print_step "1. Очищення попередніх кластерів"
    k3d cluster delete --all 2>/dev/null || true
    sleep 2

    print_step "2. Запуск K3d кластера"
    print_info "Конфігурація: 1 сервер, 2 агенти"
    print_info "Вбудований LoadBalancer на порту 8080"
    print_info "Очікування: ~60 секунд"
    sleep 2

    echo -e "${YELLOW}Запускаємо K3d...${NC}"
    k3d cluster create asciiartify-cluster \
        --servers 1 \
        --agents 2 \
        --port "8080:80@loadbalancer" \
        --wait

    if [ $? -ne 0 ]; then
        print_warning "Спробуємо простішу конфігурацію..."
        k3d cluster delete asciiartify-cluster 2>/dev/null || true
        k3d cluster create asciiartify-cluster \
            --servers 1 \
            --agents 1 \
            --port "8080:80@loadbalancer" \
            --wait
    fi

    if [ $? -eq 0 ]; then
        print_success "K3d кластер створено успішно!"
        sleep 1

        print_step "3. Перевірка стану кластера"
        kubectl cluster-info
        sleep 1
        kubectl get nodes
        sleep 1

        # Частина 2: Створення додатку
        print_header "РОЗГОРТАННЯ ДОДАТКУ"

        print_step "4. Створення Deployment та Service"

        cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: asciiartify-demo
  labels:
    app: asciiartify
spec:
  replicas: 3
  selector:
    matchLabels:
      app: asciiartify
  template:
    metadata:
      labels:
        app: asciiartify
    spec:
      containers:
      - name: web
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: asciiartify-service
spec:
  selector:
    app: asciiartify
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: asciiartify-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
  - host: asciiartify.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: asciiartify-service
            port:
              number: 80
EOF

        print_success "Додаток створено"
        sleep 1

        # Частина 3: Очікування готовності
        print_step "5. Очікування запуску подів"
        wait_for_pods "app=asciiartify" "default"

        print_step "6. Перевірка всіх ресурсів"
        echo -e "${CYAN}Deployments:${NC}"
        kubectl get deployments
        echo ""
        echo -e "${CYAN}Services:${NC}"
        kubectl get services
        echo ""
        echo -e "${CYAN}Ingresses:${NC}"
        kubectl get ingress
        sleep 2

        # Частина 4: Тестування
        print_header "ТЕСТУВАННЯ ДОСТУПУ"

        # Тестуємо через port-forward
        test_application_access "default"

        # Додаткове тестування через LoadBalancer з Ingress
        print_step "7. Тестування через Ingress"
        print_info "Додаємо запис до /etc/hosts..."
        echo "127.0.0.1 asciiartify.local" | sudo tee -a /etc/hosts

        print_info "Тестуємо через Ingress: http://asciiartify.local:8080"

        local ingress_success=false
        for i in {1..8}; do
            echo -e "${YELLOW}  Спроба $i...${NC}"
            if curl -s -f -H "Host: asciiartify.local" --max-time 10 http://localhost:8080 > /dev/null 2>&1; then
                ingress_success=true
                print_success "Ingress працює!"

                # Отримуємо трохи вмісту
                local ingress_response=$(curl -s -H "Host: asciiartify.local" http://localhost:8080)
                echo -e "${GREEN}  Відповідь через Ingress:${NC}"
                echo "$ingress_response" | head -c 100
                echo -e "\n${YELLOW}  ...${NC}"
                break
            fi
            echo -e "${YELLOW}  Чекаємо...${NC}"
            sleep 5
        done

        if [ "$ingress_success" = false ]; then
            print_warning "Ingress не відповідає"
            print_info "Перевірка Traefik ingress контролера:"
            kubectl get pods -n kube-system | grep traefik || echo "Traefik не знайдено"
        fi

        # Частина 5: Демонстрація Kubernetes можливостей
        print_header "ДЕМОНСТРАЦІЯ МОЖЛИВОСТЕЙ"

        print_step "8. Масштабування додатку"
        print_info "Збільшуємо кількість реплік до 5..."
        kubectl scale deployment asciiartify-demo --replicas=5
        sleep 3
        wait_for_pods "app=asciiartify" "default"

        print_step "9. Оновлення додатку"
        print_info "Оновлюємо образ на новішу версію..."
        kubectl set image deployment/asciiartify-demo web=nginx:1.25-alpine
        sleep 2
        print_info "Спостерігаємо за оновленням..."
        kubectl rollout status deployment/asciiartify-demo --timeout=60s

        print_step "10. Перевірка стану після оновлення"
        kubectl get pods -l app=asciiartify

        # Частина 6: Очищення
        print_header "ЗАВЕРШЕННЯ ДЕМО"

        print_step "11. Очищення тестових ресурсів"
        print_info "Видаляємо запис з /etc/hosts..."
        sudo sed -i '/asciiartify.local/d' /etc/hosts

        print_info "Видаляємо додаток..."
        kubectl delete deployment asciiartify-demo
        kubectl delete service asciiartify-service
        kubectl delete ingress asciiartify-ingress
        sleep 2

        print_step "12. Видалення кластера"
        k3d cluster delete asciiartify-cluster
        sleep 2

        print_success "Демонстрація завершена успішно!"

    else
        print_warning "Не вдалося запустити K3d кластер"
        print_info "Можливі причини:"
        print_info "  • Недостатньо пам'яті"
        print_info "  • Проблеми з мережею"
        print_info "  • Конфлікти портів"
    fi

    # Фінальні рекомендації
    print_header "РЕКОМЕНДАЦІЇ ДЛЯ ASCIIARTIFY"

    echo -e "${CYAN}🎯 КЛЮЧОВІ ПЕРЕВАГИ K3d:${NC}"
    echo "  • 🚀 Швидкий запуск (< 1 хвилини)"
    echo "  • 💾 Низьке споживання пам'яті (~500MB)"
    echo "  • 🔧 Вбудований LoadBalancer та Ingress"
    echo "  • 📱 Працює на ARM64 (ваша архітектура)"
    echo ""

    echo -e "${GREEN}📋 ПРАКТИЧНІ КРОКИ ДЛЯ ПОЧАТКУ:${NC}"
    echo ""
    echo "1. Встановіть K3d:"
    echo "   curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash"
    echo ""
    echo "2. Запустіть кластер для розробки:"
    echo "   k3d cluster create asciiartify-dev \\"
    echo "     --servers 1 --agents 2 \\"
    echo "     --port \"8080:80@loadbalancer\" \\"
    echo "     --volume \$(pwd):/app"
    echo ""
    echo "3. Розгорніть ваш ML додаток:"
    echo "   kubectl apply -f asciiartify-deployment.yaml"
    echo ""
    echo "4. Доступ через браузер:"
    echo "   http://localhost:8080"
    echo ""

    echo -e "${YELLOW}⚠️  ОБМЕЖЕННЯ ТА АЛЬТЕРНАТИВИ:${NC}"
    echo "  • K3d не підтримує GPU для ML"
    echo "  • Для CI/CD рекомендуємо Kind"
    echo "  • Для продакшн-тестів - збільшити ресурси"
    echo ""

    echo -e "${BLUE}🚀 КОМАНДА ДЛЯ ШВИДКОГО СТАРТУ:${NC}"
    echo "   k3d cluster create dev --servers 1 --agents 1 --port \"8080:80@loadbalancer\""
    echo ""

    print_success "Готово до розробки AsciiArtify! 🎨"
    echo ""
}

# Запуск головної демонстрації
main_demo
