Assignment:

1. Create a Pod running an nginx container.
2. Verify the Pod status is running.
3. Describe the Pod and list container details.
4. Access the Pod using port-forward.
5. Delete the Pod and recreate it using a YAML file.
6. Create a Pod with two containers (nginx and busybox).
7. Verify both containers are running inside the Pod.
8. Exec into one container and check communication with the other container.
9. Create a Deployment with 2 replicas using nginx image.
10. Verify the Pods created by the Deployment.
11. Scale the Deployment to 4 replicas.
12. Update the container image in the Deployment.
13. Perform a rollout restart of the Deployment.
14. Check rollout history of the Deployment.
15. Rollback the Deployment to the previous version.
16. Delete the Deployment.
17. Create a Deployment and expose it using a ClusterIP service.
18. Verify the ClusterIP service is created.
19 Access the ClusterIP service from another Pod.
20. Test DNS resolution using the service name.
21. Expose the Deployment using a NodePort service.
22. Identify the NodePort assigned.
23. Retrieve the Node IP of the cluster.
24. Access the application using Node IP and NodePort.
25. Create a LoadBalancer service for the Deployment.
26. Verify the external IP assigned to the service.
27. Access the application using the external IP.
28. Create an ExternalName service pointing to an external domain (e.g., api.github.com).
29. Verify DNS resolution of the ExternalName service from a Pod.
30. Access the external service using the Kubernetes service name.
31. Describe a Service and identify its selector and ports.
32. Check endpoints associated with a service.
33. Troubleshoot a service that is not routing traffic to Pods.
34. Verify labels and selectors between Pods and Services.
35. Create a frontend and backend application using Deployments.
36. Expose the backend using a ClusterIP service.
37. Expose the frontend using a NodePort or LoadBalancer service.
38. Verify communication between frontend and backend applications.