# Istio-APISIX-mTLS-K8S
Project Overview
This project demonstrates how to set up a Kubernetes environment with Istio and API SIX to implement secure communication between services using mutual TLS (mTLS). The setup includes:

API Gateway (API SIX): Acts as a secure entry point for incoming traffic.
Istio: Provides mTLS for secure service-to-service communication.
Kubernetes: Hosts the services and manages containerized applications.
Goals and Objectives
The primary objectives of this project are:

Secure Communication: Implement mutual TLS (mTLS) to ensure secure communication between services.
API Gateway Integration: Use API SIX as an API gateway to handle SSL termination and route traffic to backend services.
Service Management: Utilize Kubernetes for deploying and managing containerized applications.
Traffic Management: Use Istio's capabilities for traffic management, security, and observability.
Project Architecture

Browser/Client: Initiates an SSL connection to the API gateway.
API Gateway (API SIX): Handles SSL termination and forwards requests to services using mTLS.
Service 1 (srv1): A backend service deployed on Kubernetes.
Service 2 (srv2): Another backend service deployed on Kubernetes.
Istio: Provides service mesh capabilities, including mTLS for secure service-to-service communication within the Kubernetes cluster.
Prerequisites
A running Kubernetes cluster (EKS, GKE, AKS, or Minikube).
kubectl configured to interact with your Kubernetes cluster.
Docker installed on your local machine for building images.
Helm installed for managing Kubernetes packages.
Setup Instructions
Step 1: Install Istio
Download Istio:


curl -L https://istio.io/downloadIstio | sh -
cd istio-1.13.2
export PATH=$PWD/bin:$PATH
Install Istio:

istioctl install --set profile=demo -y
Label the default namespace for automatic sidecar injection:


kubectl label namespace default istio-injection=enabled
Step 2: Install API SIX
Create a namespace for API SIX:

kubectl create namespace apisix
Add the API SIX Helm repository:


helm repo add apisix https://charts.apiseven.com
helm repo update
Install API SIX:


helm install apisix apisix/apisix --namespace apisix
Step 3: Deploy Backend Services (srv1 and srv2)
Create Dockerfiles and application files for srv1 and srv2:

# kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.3.1
# Apply the cert-manager-issuer.yml manifest to create the Let's Encrypt ClusterIssuer:

kubectl apply -f cert-manager-issuer.yml
# Create Certificate
Apply the cert-manager-certificate.yml manifest to create the certificate for APISIX:

kubectl apply -f cert-manager-certificate.yml

kubectl apply -f helloworld1-deployment.yml
kubectl apply -f helloworld2-deployment.yml
kubectl apply -f apisix-gateway.yml
kubectl apply -f istio-mtls.yml
# Testing mTLS Communication
Check if services are running:
kubectl get pods
kubectl get services
# Access the services via APISIX:

Use a tool like curl to make requests to the APISIX gateway:

curl -k https://<APISIX_GATEWAY_IP>/helloworld1/
curl -k https://<APISIX_GATEWAY_IP>/helloworld2/
# Verify Certificates
Check that the certificates have been issued and are being used by the services

kubectl describe certificate apisix-cert -n apisix
kubectl get secret apisix-cert-tls -n apisix
# Verify mTLS is Working
To confirm that mTLS is working, you can follow these steps:

a. Enable mTLS Logging
Ensure that Istio is logging mTLS traffic. You can enable mTLS traffic logging in Istio by updating the Istio config:

kubectl edit configmap istio -n istio-system

# Add this below configuration to debug:
data:
  mesh: |
    accessLogFile: "/dev/stdout"
    accessLogFormat: '[%START_TIME%] %REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL% %RESPONSE_CODE% %RESPONSE_FLAGS% %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %UPSTREAM_HOST%'
# Test With Invalid Certificates
To further validate mTLS, you can attempt to make a request with invalid or no certificates and confirm that the request is denied.

curl -k --cacert invalid_cert.pem https://<APISIX_GATEWAY_IP>/helloworld1/
# Use a Client Certificate
Generate a client certificate and use it to make a request, verifying that the request succeeds when a valid client certificate is used.

# Generate a client certificate:

# Follow the steps to create a client certificate using OpenSSL or a similar tool.

openssl req -new -newkey rsa:2048 -nodes -keyout client.key -out client.csr
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365

# Make a request using the client certificate:

curl -k --cert client.crt --key client.key https://<APISIX_GATEWAY_IP>/helloworld1/
