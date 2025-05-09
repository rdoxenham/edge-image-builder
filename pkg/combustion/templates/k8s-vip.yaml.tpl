---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: api-ip
  namespace: metallb-system
spec:
  addresses:
  {{- if .APIAddress4 }}
    - {{ .APIAddress4 }}/32
  {{- end }}
  {{- if .APIAddress6 }}
    - {{ .APIAddress6 }}/128
  {{- end }}
  avoidBuggyIPs: true
  serviceAllocation:
    namespaces:
      - default
    serviceSelectors:
      - matchExpressions:
        - {key: "serviceType", operator: In, values: [kubernetes-vip]}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: api-ip-l2-adv
  namespace: metallb-system
spec:
  ipAddressPools:
  - api-ip
---
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-vip
  namespace: default
  labels:
    serviceType: kubernetes-vip
spec:
  {{- if and .APIAddress4 .APIAddress6 }}
  ipFamilyPolicy: RequireDualStack
  ipFamilies:
    - IPv4
    - IPv6
  {{- else if .APIAddress6 }}
  ipFamilyPolicy: SingleStack
  ipFamilies:
    - IPv6
  {{- end }}
  ports:
{{- if .RKE2 }}
  - name: rke2-api
    port: 9345
    protocol: TCP
    targetPort: 9345
{{- end }}
  - name: k8s-api
    port: 6443
    protocol: TCP
    targetPort: 6443
  type: LoadBalancer
