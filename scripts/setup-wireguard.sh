#!/usr/bin/env bash
# Script para configurar WireGuard e acessar K3s

set -e

echo "🔧 Configurando WireGuard VPN..."

# 1. Criar configuração do WireGuard
sudo mkdir -p /etc/wireguard
sudo tee /etc/wireguard/wg0.conf > /dev/null << 'EOF'
[Interface]
PrivateKey = GAjRpOC3tcs895nuw06ouVzOZvB2bXuyOrS14qzBNVg=
Address = 10.100.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = jT7vP+H2VQduuI4wmezMFLwsq63SoHB8i7mLnfYWrhw=
Endpoint = 38.224.145.102:51820
AllowedIPs = 10.100.0.0/24, 192.168.1.0/24
PersistentKeepalive = 25
EOF

sudo chmod 600 /etc/wireguard/wg0.conf
echo "✅ Configuração WireGuard criada em /etc/wireguard/wg0.conf"

# 2. Conectar à VPN
echo "🔗 Conectando à VPN..."
sudo wg-quick up wg0

# 3. Testar conexão
echo "🧪 Testando conexão VPN..."
if ping -c 2 10.100.0.1 &> /dev/null; then
    echo "✅ Conexão VPN OK!"
else
    echo "❌ Falha na conexão VPN"
    exit 1
fi

# 4. Copiar kubeconfig
echo "📥 Copiando kubeconfig do K3s..."
mkdir -p ~/.kube
ssh fullzer4@10.100.0.1 "cat /etc/rancher/k3s/k3s.yaml" | \
    sed "s/127.0.0.1/10.100.0.1/" > ~/.kube/k3s-config
chmod 600 ~/.kube/k3s-config
echo "✅ Kubeconfig copiado para ~/.kube/k3s-config"

# 5. Testar kubectl
echo "🧪 Testando conexão com K3s..."
export KUBECONFIG=~/.kube/k3s-config
if kubectl get nodes &> /dev/null; then
    echo "✅ K3s conectado com sucesso!"
    echo ""
    echo "📊 Nodes do cluster:"
    kubectl get nodes
else
    echo "❌ Falha ao conectar no K3s"
    exit 1
fi

echo ""
echo "✅ Setup completo!"
echo ""
echo "Para usar kubectl, execute:"
echo "  export KUBECONFIG=~/.kube/k3s-config"
echo "  kubectl get nodes"
echo ""
echo "Para abrir k9s:"
echo "  k9s"
echo ""
echo "Para desconectar da VPN:"
echo "  sudo wg-quick down wg0"
