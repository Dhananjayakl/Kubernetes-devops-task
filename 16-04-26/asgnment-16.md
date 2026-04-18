Assignment:
1. Create an EKS node group and apply a taint (key=value:NoSchedule) to a node, then deploy a pod and observe scheduling behavior.
2. Modify a deployment to include tolerations so that pods can be scheduled on tainted nodes.
3. Create a ConfigMap from a YAML file and mount it as a volume inside a pod.
4. Inject ConfigMap values as environment variables into a container and verify them inside the pod.
5. Create a Secret using base64-encoded values and consume it as environment variables in a pod.
6. Mount a Secret as a volume inside a container and verify the file contents.
7. Deploy a StatefulSet with 3 replicas using a headless service and verify stable pod hostnames.
8. Attach persistent volumes to a StatefulSet and verify data persistence after pod restart.
9. Deploy an application using StatefulSet that reads configuration from ConfigMap and sensitive data from Secrets.
10. Schedule a StatefulSet pod on a tainted node by applying appropriate tolerations and verify successful deployment.
11. Explore on Taints and tolarations in EKS.